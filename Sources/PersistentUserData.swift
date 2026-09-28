import Foundation
import SwiftData

@Model
final class CustomExerciseData {
    var id: String
    var name: String
    var muscle: String
    var equipment: String
    var movement: String
    var sortOrder: Int

    init(id: String, name: String, muscle: String, equipment: String, movement: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.muscle = muscle
        self.equipment = equipment
        self.movement = movement
        self.sortOrder = sortOrder
    }
}

@Model
final class GymProfileData {
    var id: String
    var name: String
    var note: String
    var sortOrder: Int

    init(id: String, name: String, note: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.note = note
        self.sortOrder = sortOrder
    }
}

@Model
final class ScheduledWorkoutData {
    var id: String
    var date: Date
    var title: String
    var exerciseIDsJSON: String
    var planJSON: String?
    var gymID: String
    var skipped: Bool
    var sourceLabel: String?

    init(
        id: String,
        date: Date,
        title: String,
        exerciseIDsJSON: String,
        planJSON: String?,
        gymID: String,
        skipped: Bool,
        sourceLabel: String?
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.exerciseIDsJSON = exerciseIDsJSON
        self.planJSON = planJSON
        self.gymID = gymID
        self.skipped = skipped
        self.sourceLabel = sourceLabel
    }
}

@Model
final class PersistentDataBlob {
    var key: String
    var data: Data

    init(key: String, data: Data) {
        self.key = key
        self.data = data
    }
}

enum RepForgePersistence {
    static let container: ModelContainer = {
        let schema = Schema([
            WorkoutTemplate.self,
            WorkoutSession.self,
            ExerciseLog.self,
            WorkoutSet.self,
            UserProfile.self,
            BodyMeasurement.self,
            CustomExerciseData.self,
            GymProfileData.self,
            ScheduledWorkoutData.self,
            PersistentDataBlob.self
        ])

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData initialization failed: \(error)")
        }
    }()
}

enum SwiftDataUserStore {
    private static let legacyCustomExercisesKey = "repforge.customExercises.v1"
    private static let legacyGymsKey = "repforge.gyms.v1"
    private static let legacyScheduleKey = "repforge.schedule.v1"
    private static let legacyFavoritesKey = "repforge.exercise.favorites.v1"
    private static let legacyRecentsKey = "repforge.exercise.recents.v1"
    private static let legacyProgramDaysKey = "repforge.program.customDays.v1"

    private static func context() -> ModelContext {
        ModelContext(RepForgePersistence.container)
    }

    static func customExercises() -> [CustomExerciseRecord] {
        let context = context()
        let stored = (try? context.fetch(FetchDescriptor<CustomExerciseData>())) ?? []

        if !stored.isEmpty {
            return stored.sorted { $0.sortOrder < $1.sortOrder }.map {
                CustomExerciseRecord(
                    id: $0.id,
                    name: $0.name,
                    muscle: $0.muscle,
                    equipment: $0.equipment,
                    movement: $0.movement
                )
            }
        }

        guard let data = UserDefaults.standard.data(forKey: legacyCustomExercisesKey),
              let legacy = try? JSONDecoder().decode([CustomExerciseRecord].self, from: data),
              !legacy.isEmpty else {
            return []
        }

        saveCustomExercises(legacy)
        return legacy
    }

    static func saveCustomExercises(_ records: [CustomExerciseRecord]) {
        let context = context()
        let old = (try? context.fetch(FetchDescriptor<CustomExerciseData>())) ?? []
        for item in old { context.delete(item) }

        for (index, record) in records.enumerated() {
            context.insert(
                CustomExerciseData(
                    id: record.id,
                    name: record.name,
                    muscle: record.muscle,
                    equipment: record.equipment,
                    movement: record.movement,
                    sortOrder: index
                )
            )
        }

        try? context.save()
        UserDefaults.standard.removeObject(forKey: legacyCustomExercisesKey)
    }

    static func gyms() -> [GymProfile] {
        let context = context()
        let stored = (try? context.fetch(FetchDescriptor<GymProfileData>())) ?? []

        if !stored.isEmpty {
            return stored.sorted { $0.sortOrder < $1.sortOrder }.map {
                GymProfile(id: $0.id, name: $0.name, note: $0.note)
            }
        }

        if let data = UserDefaults.standard.data(forKey: legacyGymsKey),
           let legacy = try? JSONDecoder().decode([GymProfile].self, from: data),
           !legacy.isEmpty {
            saveGyms(legacy)
            return legacy
        }

        let initial = [
            GymProfile(
                id: GymProfileStore.defaultID,
                name: L10n.text("Main Gym", "Hoofdgym"),
                note: ""
            )
        ]
        saveGyms(initial)
        return initial
    }

    static func saveGyms(_ gyms: [GymProfile]) {
        guard !gyms.isEmpty else { return }

        let context = context()
        let old = (try? context.fetch(FetchDescriptor<GymProfileData>())) ?? []
        for item in old { context.delete(item) }

        for (index, gym) in gyms.enumerated() {
            context.insert(
                GymProfileData(
                    id: gym.id,
                    name: gym.name,
                    note: gym.note,
                    sortOrder: index
                )
            )
        }

        try? context.save()
        UserDefaults.standard.removeObject(forKey: legacyGymsKey)
    }

    static func scheduledWorkouts() -> [ScheduledWorkoutRecord] {
        let context = context()
        let stored = (try? context.fetch(FetchDescriptor<ScheduledWorkoutData>())) ?? []

        if !stored.isEmpty {
            return stored.compactMap { item in
                guard let idsData = item.exerciseIDsJSON.data(using: .utf8),
                      let ids = try? JSONDecoder().decode([String].self, from: idsData) else {
                    return nil
                }

                var plan: [ProgramExercise]?
                if let planJSON = item.planJSON,
                   let data = planJSON.data(using: .utf8) {
                    plan = try? JSONDecoder().decode([ProgramExercise].self, from: data)
                }

                return ScheduledWorkoutRecord(
                    id: item.id,
                    date: item.date,
                    title: item.title,
                    exerciseIDs: ids,
                    plan: plan,
                    gymID: item.gymID,
                    skipped: item.skipped,
                    sourceLabel: item.sourceLabel
                )
            }
            .sorted { $0.date < $1.date }
        }

        if let data = UserDefaults.standard.data(forKey: legacyScheduleKey),
           let legacy = try? JSONDecoder().decode([ScheduledWorkoutRecord].self, from: data),
           !legacy.isEmpty {
            saveScheduledWorkouts(legacy)
            return legacy.sorted { $0.date < $1.date }
        }

        return []
    }

    static func saveScheduledWorkouts(_ items: [ScheduledWorkoutRecord]) {
        let context = context()
        let old = (try? context.fetch(FetchDescriptor<ScheduledWorkoutData>())) ?? []
        for item in old { context.delete(item) }

        let encoder = JSONEncoder()

        for item in items {
            guard let idsData = try? encoder.encode(item.exerciseIDs) else { continue }
            let idsJSON = String(decoding: idsData, as: UTF8.self)

            let planJSON: String?
            if let plan = item.plan,
               let planData = try? encoder.encode(plan) {
                planJSON = String(decoding: planData, as: UTF8.self)
            } else {
                planJSON = nil
            }

            context.insert(
                ScheduledWorkoutData(
                    id: item.id,
                    date: item.date,
                    title: item.title,
                    exerciseIDsJSON: idsJSON,
                    planJSON: planJSON,
                    gymID: item.gymID,
                    skipped: item.skipped,
                    sourceLabel: item.sourceLabel
                )
            )
        }

        try? context.save()
        UserDefaults.standard.removeObject(forKey: legacyScheduleKey)
    }

    static func exerciseFavorites() -> [String] {
        loadBlob(
            key: "exercise.favorites",
            legacyKey: legacyFavoritesKey,
            defaultValue: []
        )
    }

    static func saveExerciseFavorites(_ values: [String]) {
        saveBlob(key: "exercise.favorites", value: values)
        UserDefaults.standard.removeObject(forKey: legacyFavoritesKey)
    }

    static func exerciseRecents() -> [String] {
        loadBlob(
            key: "exercise.recents",
            legacyKey: legacyRecentsKey,
            defaultValue: []
        )
    }

    static func saveExerciseRecents(_ values: [String]) {
        saveBlob(key: "exercise.recents", value: values)
        UserDefaults.standard.removeObject(forKey: legacyRecentsKey)
    }

    static func programDays() -> [String: ProgramDay] {
        loadBlob(
            key: "program.customDays",
            legacyKey: legacyProgramDaysKey,
            defaultValue: [:]
        )
    }

    static func saveProgramDays(_ value: [String: ProgramDay]) {
        saveBlob(key: "program.customDays", value: value)
        UserDefaults.standard.removeObject(forKey: legacyProgramDaysKey)
    }

    private static func loadBlob<T: Codable>(
        key: String,
        legacyKey: String,
        defaultValue: T
    ) -> T {
        let context = context()
        let blobs = (try? context.fetch(FetchDescriptor<PersistentDataBlob>())) ?? []

        if let blob = blobs.first(where: { $0.key == key }),
           let decoded = try? JSONDecoder().decode(T.self, from: blob.data) {
            return decoded
        }

        if let legacyData = UserDefaults.standard.data(forKey: legacyKey),
           let decoded = try? JSONDecoder().decode(T.self, from: legacyData) {
            saveBlob(key: key, value: decoded)
            UserDefaults.standard.removeObject(forKey: legacyKey)
            return decoded
        }

        if T.self == [String].self,
           let legacyStrings = UserDefaults.standard.stringArray(forKey: legacyKey),
           let encoded = try? JSONEncoder().encode(legacyStrings),
           let decoded = try? JSONDecoder().decode(T.self, from: encoded) {
            saveBlob(key: key, value: decoded)
            UserDefaults.standard.removeObject(forKey: legacyKey)
            return decoded
        }

        return defaultValue
    }

    private static func saveBlob<T: Codable>(key: String, value: T) {
        guard let data = try? JSONEncoder().encode(value) else { return }

        let context = context()
        let blobs = (try? context.fetch(FetchDescriptor<PersistentDataBlob>())) ?? []

        if let existing = blobs.first(where: { $0.key == key }) {
            existing.data = data
        } else {
            context.insert(PersistentDataBlob(key: key, data: data))
        }

        try? context.save()
    }
}
