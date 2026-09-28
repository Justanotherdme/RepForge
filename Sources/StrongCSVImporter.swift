import Foundation
import SwiftData

struct StrongImportSummary {
    let workoutsImported: Int
    let setsImported: Int
    let duplicateWorkoutsSkipped: Int
    let rowsSkipped: Int
    let customExercisesCreated: [String]
}

enum StrongCSVImportError: LocalizedError {
    case unreadableFile
    case invalidCSV
    case missingColumns([String])
    case noWorkoutRows

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return "The Strong CSV could not be read as text."
        case .invalidCSV:
            return "The selected file is not a valid Strong CSV export."
        case .missingColumns(let columns):
            return "The Strong CSV is missing required columns: \(columns.joined(separator: ", "))."
        case .noWorkoutRows:
            return "No Strong workout sets were found in this file."
        }
    }
}

enum StrongCSVImporter {
    private struct Row {
        var date: Date
        var workoutName: String
        var duration: String
        var exerciseName: String
        var setOrder: String
        var weight: Double
        var reps: Int
        var distance: Double
        var seconds: Double
        var notes: String?
        var workoutNotes: String?
        var rpe: Double?

        var isRestTimer: Bool {
            setOrder.trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare("Rest Timer") == .orderedSame
        }
    }

    private struct WorkoutKey: Hashable {
        var date: Date
        var title: String
    }

    private static let exerciseAliases: [String: String] = [
        "romanian deadlift (dumbbell)": "Dumbbell Romanian Deadlift",
        "seated row (cable)": "Seated Cable Row",
        "bicep curl (cable)": "Cable Biceps Curl",
        "triceps pushdown (cable - straight bar)": "Cable Triceps Straight Bar Pushdown",
        "triceps pushdown (cable – straight bar)": "Cable Triceps Straight Bar Pushdown",
        "triceps pushdown (cable — straight bar)": "Cable Triceps Straight Bar Pushdown"
    ]

    static func importCSV(
        data: Data,
        into context: ModelContext,
        gymID: String?,
        usesImperialUnits: Bool
    ) throws -> StrongImportSummary {
        guard let text = String(data: data, encoding: .utf8)
            ?? String(data: data, encoding: .windowsCP1252) else {
            throw StrongCSVImportError.unreadableFile
        }

        let table = parseCSV(text)
        guard let headerRow = table.first, table.count > 1 else {
            throw StrongCSVImportError.invalidCSV
        }

        var headers: [String: Int] = [:]
        for (index, raw) in headerRow.enumerated() {
            let key = normalizeHeader(raw)
            if !key.isEmpty { headers[key] = index }
        }

        let required = ["date", "workout name", "exercise name", "set order"]
        let missing = required.filter { headers[$0] == nil }
        guard missing.isEmpty else {
            throw StrongCSVImportError.missingColumns(missing)
        }

        var parsed: [Row] = []
        var rowsSkipped = 0

        for fields in table.dropFirst() {
            func value(_ name: String) -> String {
                guard let index = headers[name], index < fields.count else { return "" }
                return fields[index].trimmingCharacters(in: .whitespacesAndNewlines)
            }

            guard let date = parseDate(value("date")) else {
                rowsSkipped += 1
                continue
            }

            let exercise = value("exercise name")
            guard !exercise.isEmpty else {
                rowsSkipped += 1
                continue
            }

            parsed.append(
                Row(
                    date: date,
                    workoutName: nonEmpty(value("workout name")) ?? "Strong Workout",
                    duration: value("duration"),
                    exerciseName: exercise,
                    setOrder: value("set order"),
                    weight: number(value("weight")),
                    reps: Int(number(value("reps")).rounded()),
                    distance: number(value("distance")),
                    seconds: number(value("seconds")),
                    notes: nonEmpty(value("notes")),
                    workoutNotes: nonEmpty(value("workout notes")),
                    rpe: optionalNumber(value("rpe"))
                )
            )
        }

        guard parsed.contains(where: { !$0.isRestTimer }) else {
            throw StrongCSVImportError.noWorkoutRows
        }

        var workoutOrder: [WorkoutKey] = []
        var workoutRows: [WorkoutKey: [Row]] = [:]

        for row in parsed {
            let key = WorkoutKey(date: row.date, title: row.workoutName)
            if workoutRows[key] == nil { workoutOrder.append(key) }
            workoutRows[key, default: []].append(row)
        }

        let existingSessions = try context.fetch(FetchDescriptor<WorkoutSession>())
        var importedWorkouts = 0
        var importedSets = 0
        var duplicateWorkouts = 0
        var customCreated: [String] = []

        for key in workoutOrder {
            guard let rows = workoutRows[key] else { continue }

            let duplicate = existingSessions.contains {
                $0.title.caseInsensitiveCompare(key.title) == .orderedSame
                    && abs($0.startedAt.timeIntervalSince(key.date)) < 1
            }
            if duplicate {
                duplicateWorkouts += 1
                continue
            }

            var exerciseOrder: [String] = []
            var exerciseRows: [String: [Row]] = [:]
            for row in rows {
                if exerciseRows[row.exerciseName] == nil {
                    exerciseOrder.append(row.exerciseName)
                }
                exerciseRows[row.exerciseName, default: []].append(row)
            }

            var logs: [ExerciseLog] = []

            for (exerciseIndex, strongName) in exerciseOrder.enumerated() {
                guard let sourceRows = exerciseRows[strongName] else { continue }
                let setRows = sourceRows.filter { !$0.isRestTimer }
                guard !setRows.isEmpty else { continue }

                let resolution = resolveExercise(named: strongName, rows: setRows)
                if resolution.createdCustom {
                    customCreated.append(strongName)
                }

                let restSeconds = preferredRestSeconds(from: sourceRows)
                var sets: [WorkoutSet] = []

                for (fallbackIndex, row) in setRows.enumerated() {
                    let strongOrder = Int(row.setOrder.trimmingCharacters(in: .whitespacesAndNewlines))
                    let storedOrder = max(0, (strongOrder ?? (fallbackIndex + 1)) - 1)

                    let weightKg = usesImperialUnits
                        ? row.weight / 2.2046226218
                        : row.weight
                    let distanceKm = usesImperialUnits
                        ? row.distance / 0.6213711922
                        : row.distance

                    let set = WorkoutSet(
                        order: storedOrder,
                        weightKg: max(0, weightKg),
                        reps: max(0, row.reps),
                        completed: true,
                        rpe: row.rpe,
                        note: row.notes,
                        durationSeconds: row.seconds > 0 ? row.seconds : nil,
                        distanceKm: row.distance > 0 ? distanceKm : nil
                    )
                    set.completedAt = key.date
                    sets.append(set)
                    importedSets += 1
                }

                logs.append(
                    ExerciseLog(
                        exerciseID: resolution.exercise.id,
                        order: exerciseIndex,
                        sessionNote: nil,
                        restSeconds: restSeconds,
                        sets: sets
                    )
                )
            }

            guard !logs.isEmpty else {
                rowsSkipped += rows.count
                continue
            }

            let workoutNote = rows.compactMap(\.workoutNotes).first
            let duration = parseDuration(rows.first?.duration ?? "")
            let session = WorkoutSession(
                title: key.title,
                startedAt: key.date,
                exercises: logs,
                note: workoutNote,
                gymID: gymID
            )
            session.endedAt = key.date.addingTimeInterval(max(1, duration))
            context.insert(session)
            importedWorkouts += 1
        }

        try context.save()

        return StrongImportSummary(
            workoutsImported: importedWorkouts,
            setsImported: importedSets,
            duplicateWorkoutsSkipped: duplicateWorkouts,
            rowsSkipped: rowsSkipped,
            customExercisesCreated: Array(Set(customCreated)).sorted()
        )
    }

    private static func resolveExercise(named name: String, rows: [Row]) -> (exercise: ExerciseDefinition, createdCustom: Bool) {
        if let exact = ExerciseCatalog.findByName(name) {
            return (exact, false)
        }

        let aliasKey = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let mappedName = exerciseAliases[aliasKey],
           let mapped = ExerciseCatalog.findByName(mappedName) {
            return (mapped, false)
        }

        CustomExerciseStore.add(
            name: name,
            muscle: inferredMuscle(name),
            equipment: inferredEquipment(name),
            movement: inferredMovement(name, rows: rows)
        )

        if let created = ExerciseCatalog.findByName(name) {
            return (created, true)
        }

        // CustomExerciseStore only rejects duplicates/empty names, so this should
        // normally resolve through the exact-name lookup above.
        let fallback = ExerciseCatalog.all.first ?? ExerciseDefinition(
            id: "strong-\(UUID().uuidString)",
            name: name,
            muscle: "Other",
            equipment: "Other",
            movement: "other"
        )
        return (fallback, false)
    }

    private static func preferredRestSeconds(from rows: [Row]) -> Int? {
        let values = rows
            .filter(\.isRestTimer)
            .map { Int($0.seconds.rounded()) }
            .filter { $0 > 0 }

        guard !values.isEmpty else { return nil }

        let counts = Dictionary(grouping: values, by: { $0 }).mapValues(\.count)
        return counts.max {
            if $0.value == $1.value { return $0.key > $1.key }
            return $0.value < $1.value
        }?.key
    }

    private static func inferredEquipment(_ name: String) -> String {
        let value = name.lowercased()
        if value.contains("smith") { return "Machine" }
        if value.contains("cable") { return "Cable" }
        if value.contains("dumbbell") { return "Dumbbell" }
        if value.contains("barbell") { return "Barbell" }
        if value.contains("kettlebell") { return "Kettlebell" }
        if value.contains("machine") { return "Machine" }
        if value.contains("bodyweight") { return "Bodyweight" }
        if value.contains("ez") { return "EZ-Bar" }
        return "Other"
    }

    private static func inferredMovement(_ name: String, rows: [Row]) -> String {
        let value = name.lowercased()
        let timedCardio = rows.contains { $0.seconds > 0 || $0.distance > 0 }
            && rows.allSatisfy { $0.weight == 0 && $0.reps == 0 }
        if timedCardio { return "cardio" }
        if value.contains("squat") || value.contains("lunge") { return "squat" }
        if value.contains("deadlift") || value.contains("hip thrust") || value.contains("swing") { return "hinge" }
        if value.contains("row") || value.contains("pulldown") || value.contains("pull up") { return "pull" }
        if value.contains("curl") { return "curl" }
        if value.contains("pushdown") || value.contains("extension") { return "extension" }
        if value.contains("raise") { return "raise" }
        if value.contains("press") || value.contains("dip") { return "press" }
        if value.contains("plank") || value.contains("crunch") || value.contains("leg raise") { return "core" }
        return "other"
    }

    private static func inferredMuscle(_ name: String) -> String {
        let value = name.lowercased()
        if value.contains("reverse curl") { return "Forearms" }
        if value.contains("bicep") || value.contains("biceps") || value.contains("curl") { return "Biceps" }
        if value.contains("tricep") || value.contains("pushdown") { return "Triceps" }
        if value.contains("bench") || value.contains("chest") { return "Chest" }
        if value.contains("lateral raise") || value.contains("shoulder") || value.contains("overhead press") { return "Shoulders" }
        if value.contains("lat ") || value.contains("pulldown") || value.contains("row") { return "Back" }
        if value.contains("romanian deadlift") { return "Hamstrings" }
        if value.contains("deadlift") { return "Back" }
        if value.contains("squat") || value.contains("lunge") { return "Quadriceps" }
        if value.contains("calf") { return "Calves" }
        if value.contains("plank") || value.contains("crunch") || value.contains("leg raise") { return "Core" }
        return "Other"
    }

    private static func parseDuration(_ raw: String) -> TimeInterval {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !value.isEmpty else { return 0 }

        if value.contains(":") {
            let parts = value.split(separator: ":").compactMap { Double($0) }
            if parts.count == 3 { return parts[0] * 3600 + parts[1] * 60 + parts[2] }
            if parts.count == 2 { return parts[0] * 60 + parts[1] }
        }

        var total: Double = 0
        for token in value.split(whereSeparator: { $0.isWhitespace }) {
            if token.hasSuffix("h"), let number = Double(token.dropLast()) {
                total += number * 3600
            } else if token.hasSuffix("m"), let number = Double(token.dropLast()) {
                total += number * 60
            } else if token.hasSuffix("s"), let number = Double(token.dropLast()) {
                total += number
            }
        }
        return total
    }

    private static func parseDate(_ raw: String) -> Date? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)

        for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm", "yyyy-MM-dd"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) { return date }
        }

        return ISO8601DateFormatter().date(from: value)
    }

    private static func normalizeHeader(_ raw: String) -> String {
        raw.replacingOccurrences(of: "\u{feff}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static func nonEmpty(_ raw: String) -> String? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private static func number(_ raw: String) -> Double {
        optionalNumber(raw) ?? 0
    }

    private static func optionalNumber(_ raw: String) -> Double? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        if let direct = Double(value) { return direct }
        return Double(value.replacingOccurrences(of: ",", with: "."))
    }

    private static func parseCSV(_ text: String) -> [[String]] {
        let characters = Array(text)
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var insideQuotes = false
        var index = 0

        while index < characters.count {
            let character = characters[index]

            if character == "\"" {
                if insideQuotes,
                   index + 1 < characters.count,
                   characters[index + 1] == "\"" {
                    field.append("\"")
                    index += 1
                } else {
                    insideQuotes.toggle()
                }
            } else if character == "," && !insideQuotes {
                row.append(field)
                field = ""
            } else if (character == "\n" || character == "\r") && !insideQuotes {
                if character == "\r",
                   index + 1 < characters.count,
                   characters[index + 1] == "\n" {
                    index += 1
                }

                row.append(field)
                field = ""

                if row.contains(where: { !$0.isEmpty }) {
                    rows.append(row)
                }
                row = []
            } else {
                field.append(character)
            }

            index += 1
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            if row.contains(where: { !$0.isEmpty }) {
                rows.append(row)
            }
        }

        return rows
    }
}
