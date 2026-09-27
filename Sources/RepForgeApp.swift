import SwiftUI
import SwiftData
import Charts
import AVKit
import UIKit

// MARK: - Theme

enum AppPreferences {
    static var language: String {
        UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    static var measurementSystem: String {
        UserDefaults.standard.string(forKey: "measurementSystem") ?? "metric"
    }

    static var appearance: String {
        UserDefaults.standard.string(forKey: "appearance") ?? "dark"
    }

    static var themePreset: String {
        UserDefaults.standard.string(forKey: "themePreset") ?? "forge"
    }

    static var hapticsEnabled: Bool {
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    static var showPreviousSets: Bool {
        if UserDefaults.standard.object(forKey: "showPreviousSets") == nil { return true }
        return UserDefaults.standard.bool(forKey: "showPreviousSets")
    }

    static var defaultSets: Int {
        let value = UserDefaults.standard.integer(forKey: "defaultSets")
        return value == 0 ? 3 : max(1, min(6, value))
    }

    static var defaultRestSeconds: Int {
        let value = UserDefaults.standard.integer(forKey: "defaultRestSeconds")
        return value == 0 ? 90 : max(15, min(600, value))
    }

    static var autoRestTimer: Bool {
        if UserDefaults.standard.object(forKey: "autoRestTimer") == nil { return true }
        return UserDefaults.standard.bool(forKey: "autoRestTimer")
    }

    static var progressionStepKg: Double {
        let value = UserDefaults.standard.double(forKey: "progressionStepKg")
        return value == 0 ? 2.5 : max(0.25, min(20, value))
    }

    static var isImperial: Bool { measurementSystem == "imperial" }
    static var weightLabel: String { isImperial ? "lb" : "kg" }
    static var heightLabel: String { isImperial ? "in" : "cm" }
    static var distanceLabel: String { isImperial ? "mi" : "km" }

    static func displayWeight(_ kg: Double) -> Double {
        isImperial ? kg * 2.2046226218 : kg
    }

    static func storedWeightKg(_ displayed: Double) -> Double {
        isImperial ? displayed / 2.2046226218 : displayed
    }

    static func displayVolume(_ kgVolume: Double) -> Double {
        displayWeight(kgVolume)
    }

    static func displayHeight(_ cm: Double) -> Double {
        isImperial ? cm / 2.54 : cm
    }

    static func storedHeightCm(_ displayed: Double) -> Double {
        isImperial ? displayed * 2.54 : displayed
    }
}

enum L10n {
    static func text(_ english: String, _ dutch: String) -> String {
        AppPreferences.language == "nl" ? dutch : english
    }

    static var profile: String { text("Profile", "Profiel") }
    static var history: String { text("History", "Geschiedenis") }
    static var workout: String { text("Workout", "Training") }
    static var exercises: String { text("Exercises", "Oefeningen") }
    static var settings: String { text("Settings", "Instellingen") }
    static var done: String { text("Done", "Gereed") }
    static var startWorkout: String { text("Start Workout", "Start training") }
    static var addExercise: String { text("Add Exercise", "Oefening toevoegen") }
    static var finish: String { text("Finish", "Afronden") }
}

enum RFTheme {
    private static var explicitLight: Bool { AppPreferences.appearance == "light" }
    private static var systemMode: Bool { AppPreferences.appearance == "system" }

    static var bg: Color {
        if systemMode { return Color(uiColor: .systemBackground) }
        if explicitLight { return Color(red: 0.955, green: 0.965, blue: 0.975) }

        switch AppPreferences.themePreset {
        case "oled": return .black
        case "graphite": return Color(red: 0.075, green: 0.075, blue: 0.082)
        case "navy": return Color(red: 0.025, green: 0.055, blue: 0.095)
        case "emerald": return Color(red: 0.025, green: 0.080, blue: 0.065)
        case "orange": return Color(red: 0.105, green: 0.055, blue: 0.025)
        case "purple": return Color(red: 0.070, green: 0.040, blue: 0.105)
        default: return Color(red: 0.055, green: 0.070, blue: 0.078)
        }
    }

    static var surface: Color {
        if systemMode { return Color(uiColor: .secondarySystemBackground) }
        if explicitLight { return .white }

        switch AppPreferences.themePreset {
        case "oled": return Color(red: 0.055, green: 0.055, blue: 0.060)
        case "graphite": return Color(red: 0.125, green: 0.125, blue: 0.135)
        case "navy": return Color(red: 0.070, green: 0.105, blue: 0.155)
        case "emerald": return Color(red: 0.055, green: 0.145, blue: 0.110)
        case "orange": return Color(red: 0.175, green: 0.095, blue: 0.045)
        case "purple": return Color(red: 0.125, green: 0.075, blue: 0.180)
        default: return Color(red: 0.105, green: 0.135, blue: 0.150)
        }
    }

    static var raised: Color {
        if systemMode { return Color(uiColor: .tertiarySystemBackground) }
        if explicitLight { return Color(red: 0.90, green: 0.92, blue: 0.94) }

        switch AppPreferences.themePreset {
        case "oled": return Color(red: 0.095, green: 0.095, blue: 0.105)
        case "graphite": return Color(red: 0.165, green: 0.165, blue: 0.180)
        case "navy": return Color(red: 0.105, green: 0.145, blue: 0.205)
        case "emerald": return Color(red: 0.080, green: 0.190, blue: 0.145)
        case "orange": return Color(red: 0.220, green: 0.125, blue: 0.060)
        case "purple": return Color(red: 0.175, green: 0.105, blue: 0.245)
        default: return Color(red: 0.140, green: 0.175, blue: 0.190)
        }
    }

    static var field: Color {
        if systemMode { return Color(uiColor: .tertiarySystemFill) }
        if explicitLight { return Color.black.opacity(0.06) }
        return Color.black.opacity(AppPreferences.themePreset == "oled" ? 0.62 : 0.28)
    }

    static var accent: Color {
        switch AppPreferences.themePreset {
        case "emerald": return Color(red: 0.10, green: 0.78, blue: 0.48)
        case "orange": return Color(red: 1.0, green: 0.48, blue: 0.12)
        case "purple": return Color(red: 0.63, green: 0.43, blue: 1.0)
        default: return Color(red: 0.18, green: 0.63, blue: 1.0)
        }
    }

    static let success = Color(red: 0.16, green: 0.78, blue: 0.43)

    static var muted: Color {
        if systemMode { return Color.secondary }
        return explicitLight ? Color.black.opacity(0.50) : Color.white.opacity(0.52)
    }
}

enum Haptics {
    static func light() {
        guard AppPreferences.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard AppPreferences.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Exercise catalog

struct ExerciseDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let muscle: String
    let equipment: String
    let movement: String

    var instructions: [String] {
        switch movement {
        case "press":
            return ["Set a stable base and brace your trunk.", "Lower under control while keeping the working joints stacked.", "Press smoothly through the intended range without bouncing."]
        case "pull":
            return ["Set the shoulder blades before initiating the pull.", "Pull with the target muscles instead of jerking with momentum.", "Return slowly and keep tension through the full range."]
        case "squat":
            return ["Brace before each rep and keep your whole foot planted.", "Track the knees in line with the toes.", "Drive up while keeping the torso controlled."]
        case "hinge":
            return ["Push the hips back while keeping the spine neutral.", "Keep the load close to your body.", "Finish by extending the hips, not by leaning backward."]
        case "curl":
            return ["Keep the upper arm controlled.", "Curl without swinging the torso.", "Lower slowly until the elbow is fully extended."]
        case "extension":
            return ["Keep the upper arm stable.", "Extend through the elbow without using body momentum.", "Control the return and avoid snapping into lockout."]
        case "raise":
            return ["Use a controlled range with relaxed traps.", "Lead with the intended limb path.", "Lower more slowly than you lift."]
        case "core":
            return ["Brace as if preparing for impact.", "Move without losing rib-to-pelvis control.", "Stop the set when position starts to break down."]
        case "cardio":
            return ["Start at a sustainable pace.", "Use smooth, repeatable mechanics.", "Increase intensity gradually rather than sprinting immediately."]
        default:
            return ["Set up in a stable position.", "Use a controlled range of motion.", "Prioritize consistent technique over load."]
        }
    }

    var cues: [String] {
        ["Controlled tempo", "Stable setup", "Pain-free range", "Progress load gradually"]
    }
}

enum ExerciseCatalog {
    private static let builtIn: [ExerciseDefinition] = {
        let rows = """
Bench Press (Barbell)|Chest|Barbell|press
Bench Press (Dumbbell)|Chest|Dumbbell|press
Incline Bench Press (Barbell)|Chest|Barbell|press
Incline Bench Press (Dumbbell)|Chest|Dumbbell|press
Decline Bench Press|Chest|Barbell|press
Chest Press (Machine)|Chest|Machine|press
Chest Fly (Machine)|Chest|Machine|press
Cable Fly|Chest|Cable|press
Push Up|Chest|Bodyweight|press
Dip (Chest)|Chest|Bodyweight|press
Around the World|Chest|Dumbbell|raise
Pullover (Dumbbell)|Chest|Dumbbell|pull
Deadlift (Barbell)|Back|Barbell|hinge
Romanian Deadlift (Barbell)|Hamstrings|Barbell|hinge
Bent Over Row (Barbell)|Back|Barbell|pull
Bent Over Row (Dumbbell)|Back|Dumbbell|pull
One Arm Dumbbell Row|Back|Dumbbell|pull
Seated Cable Row|Back|Cable|pull
T-Bar Row|Back|Machine|pull
Chest Supported Row|Back|Machine|pull
Lat Pulldown|Back|Cable|pull
Lat Pulldown - Wide Grip|Back|Cable|pull
Pull Up|Back|Bodyweight|pull
Chin Up|Back|Bodyweight|pull
Straight Arm Pulldown|Back|Cable|pull
Back Extension|Back|Bodyweight|hinge
Back Extension (Machine)|Back|Machine|hinge
Good Morning|Back|Barbell|hinge
Overhead Press (Barbell)|Shoulders|Barbell|press
Shoulder Press (Dumbbell)|Shoulders|Dumbbell|press
Arnold Press (Dumbbell)|Shoulders|Dumbbell|press
Shoulder Press (Machine)|Shoulders|Machine|press
Lateral Raise (Dumbbell)|Shoulders|Dumbbell|raise
Lateral Raise (Cable)|Shoulders|Cable|raise
Front Raise|Shoulders|Dumbbell|raise
Rear Delt Fly|Shoulders|Dumbbell|raise
Reverse Pec Deck|Shoulders|Machine|raise
Face Pull|Shoulders|Cable|pull
Upright Row|Shoulders|Barbell|pull
Shrug (Barbell)|Shoulders|Barbell|pull
Shrug (Dumbbell)|Shoulders|Dumbbell|pull
Biceps Curl (Barbell)|Biceps|Barbell|curl
Biceps Curl (Dumbbell)|Biceps|Dumbbell|curl
Hammer Curl|Biceps|Dumbbell|curl
Incline Dumbbell Curl|Biceps|Dumbbell|curl
Preacher Curl|Biceps|Machine|curl
Cable Curl|Biceps|Cable|curl
Concentration Curl|Biceps|Dumbbell|curl
EZ-Bar Curl|Biceps|Barbell|curl
Triceps Pushdown|Triceps|Cable|extension
Overhead Triceps Extension|Triceps|Cable|extension
Skull Crusher|Triceps|Barbell|extension
Close Grip Bench Press|Triceps|Barbell|press
Triceps Dip|Triceps|Bodyweight|extension
Triceps Extension (Dumbbell)|Triceps|Dumbbell|extension
Squat (Barbell)|Quadriceps|Barbell|squat
Front Squat|Quadriceps|Barbell|squat
Goblet Squat|Quadriceps|Dumbbell|squat
Hack Squat|Quadriceps|Machine|squat
Leg Press|Quadriceps|Machine|squat
Leg Extension (Machine)|Quadriceps|Machine|extension
Bulgarian Split Squat|Quadriceps|Dumbbell|squat
Walking Lunge|Quadriceps|Dumbbell|squat
Reverse Lunge|Quadriceps|Dumbbell|squat
Step Up|Quadriceps|Dumbbell|squat
Leg Curl (Lying)|Hamstrings|Machine|curl
Leg Curl (Seated)|Hamstrings|Machine|curl
Nordic Hamstring Curl|Hamstrings|Bodyweight|curl
Stiff Leg Deadlift|Hamstrings|Barbell|hinge
Hip Thrust (Barbell)|Glutes|Barbell|hinge
Glute Bridge|Glutes|Bodyweight|hinge
Cable Kickback|Glutes|Cable|extension
Hip Abduction (Machine)|Glutes|Machine|raise
Hip Adduction (Machine)|Adductors|Machine|raise
Standing Calf Raise|Calves|Machine|raise
Seated Calf Raise|Calves|Machine|raise
Standing Calf Raise (Dumbbell)|Calves|Dumbbell|raise
Crunch|Core|Bodyweight|core
Cable Crunch|Core|Cable|core
Hanging Leg Raise|Core|Bodyweight|core
Flat Leg Raise|Core|Bodyweight|core
Plank|Core|Bodyweight|core
Side Plank|Core|Bodyweight|core
Ab Wheel|Core|Other|core
Russian Twist|Core|Bodyweight|core
Bicycle Crunch|Core|Bodyweight|core
Mountain Climber|Core|Bodyweight|core
Farmer Carry|Full Body|Dumbbell|carry
Kettlebell Swing|Full Body|Kettlebell|hinge
Clean and Press|Full Body|Barbell|press
Thruster|Full Body|Barbell|squat
Battle Ropes|Full Body|Other|cardio
Ball Slams|Full Body|Other|cardio
Burpee|Full Body|Bodyweight|cardio
Aerobics|Cardio|Cardio|cardio
Running|Cardio|Cardio|cardio
Cycling|Cardio|Cardio|cardio
Rowing|Cardio|Cardio|cardio
Stair Climber|Cardio|Cardio|cardio
Elliptical|Cardio|Cardio|cardio
Jump Rope|Cardio|Other|cardio
Barbell Flat Bench Press|Chest|Barbell|press
Chest Supported Machine Row|Back|Machine|pull
Lying Leg Curl|Hamstrings|Machine|curl
Cable Triceps Rope Pushdown|Triceps|Cable|extension
Dumbbell Shoulder Press (Seated)|Shoulders|Dumbbell|press
Dumbbell Romanian Deadlift|Hamstrings|Dumbbell|hinge
Wide Grip Lat Pulldown|Back|Cable|pull
Standing Dumbbell Biceps Curl|Biceps|Dumbbell|curl
Cable Face Pull|Shoulders|Cable|pull
Seated Cable Row (V-Bar)|Back|Cable|pull
Incline Dumbbell Bench Press|Chest|Dumbbell|press
Standing Dumbbell Lateral Raise|Shoulders|Dumbbell|raise
Cable Overhead Triceps Rope Extension|Triceps|Cable|extension
Reverse Pec Deck Machine|Shoulders|Machine|raise
Captain's Chair Leg Raise|Core|Bodyweight|core
Hack Squat Machine|Quadriceps|Machine|squat
Single-Arm Dumbbell Row|Back|Dumbbell|pull
Seated Leg Curl Machine|Hamstrings|Machine|curl
Cable Triceps Straight Bar Pushdown|Triceps|Cable|extension
Standing Barbell Overhead Press (Military Press)|Shoulders|Barbell|press
Trap Bar Deadlift|Full Body|Trap Bar|hinge
Neutral Grip Lat Pulldown|Back|Cable|pull
Dumbbell Walking Lunges|Quadriceps|Dumbbell|squat
Cable Biceps Curl|Biceps|Cable|curl
Chest Supported Dumbbell Row|Back|Dumbbell|pull
Assisted Dip Machine|Chest|Machine|press
Bench Dips|Triceps|Bodyweight|extension
Seated Calf Raise Machine|Calves|Machine|raise
Lean-Away Cable Lateral Raise|Shoulders|Cable|raise
EZ-Bar Biceps Curl|Biceps|EZ-Bar|curl
Kneeling Cable Crunch|Core|Cable|core
Abdominal Crunch Machine|Core|Machine|core
EZ-Bar Reverse Curl|Forearms|EZ-Bar|curl
Arnold Dumbbell Press|Shoulders|Dumbbell|press
Flat Dumbbell Bench Press|Chest|Dumbbell|press
Close-Grip Barbell Bench Press|Triceps|Barbell|press
Dumbbell Preacher Curl|Biceps|Dumbbell|curl
Incline Bench Spider Curl|Biceps|Dumbbell|curl
Lying Dumbbell Skull Crushers|Triceps|Dumbbell|extension
Lying Floor Leg Raises|Core|Bodyweight|core
Bench Press (Smith Machine)|Chest|Machine|press
"""
        return rows.split(separator: "\n").enumerated().compactMap { index, raw in
            let p = raw.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard p.count == 4 else { return nil }
            return ExerciseDefinition(
                id: "ex-\(index)",
                name: p[0],
                muscle: p[1],
                equipment: p[2],
                movement: p[3]
            )
        }
    }()

    static var all: [ExerciseDefinition] {
        builtIn + CustomExerciseStore.load().map { $0.definition }
    }

    static func find(_ id: String) -> ExerciseDefinition? {
        all.first { $0.id == id }
    }

    static func findByName(_ name: String) -> ExerciseDefinition? {
        all.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    static var muscles: [String] {
        Array(Set(all.map(\.muscle))).sorted()
    }
}

struct CustomExerciseRecord: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var muscle: String
    var equipment: String
    var movement: String

    var definition: ExerciseDefinition {
        ExerciseDefinition(
            id: id,
            name: name,
            muscle: muscle,
            equipment: equipment,
            movement: movement
        )
    }
}

enum CustomExerciseStore {
    private static let key = "repforge.customExercises.v1"

    static func load() -> [CustomExerciseRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([CustomExerciseRecord].self, from: data) else {
            return []
        }
        return records
    }

    static func save(_ records: [CustomExerciseRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func add(name: String, muscle: String, equipment: String, movement: String) {
        var records = load()
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty,
              !records.contains(where: { $0.name.caseInsensitiveCompare(cleanName) == .orderedSame }),
              ExerciseCatalog.findByName(cleanName) == nil else { return }

        records.append(
            CustomExerciseRecord(
                id: "custom-\(UUID().uuidString)",
                name: cleanName,
                muscle: muscle,
                equipment: equipment,
                movement: movement
            )
        )
        save(records)
    }

    static func delete(id: String) {
        var records = load()
        records.removeAll { $0.id == id }
        save(records)
    }

    static func isCustom(_ id: String) -> Bool {
        id.hasPrefix("custom-")
    }
}

// MARK: - Built-in 3-week program

struct ProgramExercise: Hashable, Codable {
    var name: String
    var sets: Int
    var reps: String
    var note: String?
    var superset: String?

    init(_ name: String, _ sets: Int, _ reps: String, note: String? = nil, superset: String? = nil) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.note = note
        self.superset = superset
    }
}

struct ProgramDay: Identifiable, Hashable, Codable {
    let id: String
    let week: Int
    var day: String
    var partner: String
    var focus: String
    var exercises: [ProgramExercise]

    var title: String { "Week \(week) • \(day)" }
}

enum BuiltInProgram {
    static let days: [ProgramDay] = [
        ProgramDay(id: "w1-mon", week: 1, day: "Monday", partner: "with friend", focus: "Chest Strength & Quads", exercises: [
            .init("Barbell Flat Bench Press", 3, "6–8"),
            .init("Leg Press", 3, "8–10", note: "Beginner-friendly quad focus"),
            .init("Chest Supported Machine Row", 3, "8–10"),
            .init("Lying Leg Curl", 3, "10–12"),
            .init("Cable Triceps Rope Pushdown", 3, "12–15", superset: "A"),
            .init("Lateral Raise (Cable)", 3, "12–15", superset: "A")
        ]),
        ProgramDay(id: "w1-wed", week: 1, day: "Wednesday", partner: "with brother", focus: "Shoulders & Hamstrings", exercises: [
            .init("Dumbbell Shoulder Press (Seated)", 3, "8–10"),
            .init("Dumbbell Romanian Deadlift", 3, "8–10"),
            .init("Wide Grip Lat Pulldown", 3, "8–10"),
            .init("Leg Extension (Machine)", 3, "10–12"),
            .init("Standing Dumbbell Biceps Curl", 3, "12–15", superset: "A"),
            .init("Cable Face Pull", 3, "12–15", superset: "A")
        ]),
        ProgramDay(id: "w1-fri", week: 1, day: "Friday", partner: "with friend", focus: "Chest Volume & Upper Back", exercises: [
            .init("Barbell Flat Bench Press", 3, "8–10", note: "Lighter load, controlled reps"),
            .init("Goblet Squat", 3, "10–12"),
            .init("Seated Cable Row (V-Bar)", 3, "8–10"),
            .init("Incline Dumbbell Bench Press", 3, "10–12"),
            .init("Standing Calf Raise", 4, "12–15")
        ]),
        ProgramDay(id: "w1-bonus", week: 1, day: "Bonus Day", partner: "with brother", focus: "Arms & Shoulders", exercises: [
            .init("Standing Dumbbell Lateral Raise", 4, "12–15"),
            .init("Incline Dumbbell Curl", 3, "10–12"),
            .init("Cable Overhead Triceps Rope Extension", 3, "10–12"),
            .init("Reverse Pec Deck Machine", 3, "15"),
            .init("Captain's Chair Leg Raise", 3, "12–15")
        ]),

        ProgramDay(id: "w2-mon", week: 2, day: "Monday", partner: "with friend", focus: "Chest & Hamstrings Focus", exercises: [
            .init("Barbell Flat Bench Press", 3, "6–8"),
            .init("Hack Squat Machine", 3, "8–10"),
            .init("Single-Arm Dumbbell Row", 3, "8–10", note: "Per side"),
            .init("Seated Leg Curl Machine", 3, "10–12"),
            .init("Hammer Curl", 3, "10–12", superset: "A"),
            .init("Cable Triceps Straight Bar Pushdown", 3, "10–12", superset: "A")
        ]),
        ProgramDay(id: "w2-wed", week: 2, day: "Wednesday", partner: "with brother", focus: "Upper Body & Quads", exercises: [
            .init("Standing Barbell Overhead Press (Military Press)", 3, "6–8"),
            .init("Trap Bar Deadlift", 3, "6–8"),
            .init("Neutral Grip Lat Pulldown", 3, "8–10"),
            .init("Dumbbell Walking Lunges", 3, "10/leg"),
            .init("Cable Biceps Curl", 3, "12–15", superset: "A"),
            .init("Lateral Raise (Cable)", 3, "12–15", superset: "A")
        ]),
        ProgramDay(id: "w2-fri", week: 2, day: "Friday", partner: "with friend", focus: "Chest Pump & Back Thickness", exercises: [
            .init("Incline Dumbbell Bench Press", 3, "8–10"),
            .init("Leg Press", 3, "10–12"),
            .init("Chest Supported Dumbbell Row", 3, "10–12"),
            .init("Assisted Dip Machine", 3, "8–10", note: "Bench Dips can be used as an alternative"),
            .init("Seated Calf Raise Machine", 4, "12–15")
        ]),
        ProgramDay(id: "w2-bonus", week: 2, day: "Bonus Day", partner: "with brother", focus: "Pump & Core", exercises: [
            .init("Lean-Away Cable Lateral Raise", 4, "12–15"),
            .init("EZ-Bar Biceps Curl", 3, "10–12"),
            .init("Cable Triceps Rope Pushdown", 3, "10–12"),
            .init("Cable Face Pull", 3, "15"),
            .init("Kneeling Cable Crunch", 3, "12–15")
        ]),

        ProgramDay(id: "w3-mon", week: 3, day: "Monday", partner: "with friend", focus: "Strength & Focus", exercises: [
            .init("Barbell Flat Bench Press", 3, "6"),
            .init("Goblet Squat", 3, "8–10", note: "Use a heavier dumbbell"),
            .init("Seated Cable Row", 3, "8–10", note: "Neutral grip"),
            .init("Dumbbell Romanian Deadlift", 3, "10–12"),
            .init("Triceps Pushdown", 3, "10–12", superset: "A"),
            .init("EZ-Bar Reverse Curl", 3, "10–12", superset: "A")
        ]),
        ProgramDay(id: "w3-wed", week: 3, day: "Wednesday", partner: "with brother", focus: "Shoulders & Back Width", exercises: [
            .init("Arnold Dumbbell Press", 3, "8–10"),
            .init("Romanian Deadlift (Barbell)", 3, "8–10"),
            .init("Wide Grip Lat Pulldown", 3, "8–10"),
            .init("Leg Extension (Machine)", 3, "12–15"),
            .init("Hammer Curl", 3, "12–15", superset: "A"),
            .init("Cable Face Pull", 3, "12–15", superset: "A")
        ]),
        ProgramDay(id: "w3-fri", week: 3, day: "Friday", partner: "with friend", focus: "Chest & Triceps Volume", exercises: [
            .init("Flat Dumbbell Bench Press", 3, "8–10"),
            .init("Close-Grip Barbell Bench Press", 3, "8–10"),
            .init("Chest Supported Machine Row", 3, "10–12"),
            .init("Leg Press", 3, "10–12"),
            .init("Standing Calf Raise", 4, "12–15")
        ]),
        ProgramDay(id: "w3-bonus", week: 3, day: "Bonus Day", partner: "with brother", focus: "Shoulder & Arm Burnout", exercises: [
            .init("Standing Dumbbell Lateral Raise", 4, "12–15"),
            .init("Dumbbell Preacher Curl", 3, "10–12", note: "Incline bench spider curl is an alternative"),
            .init("Lying Dumbbell Skull Crushers", 3, "10–12"),
            .init("Reverse Pec Deck Machine", 3, "15"),
            .init("Lying Floor Leg Raises", 3, "15")
        ])
    ]

    static func week(_ week: Int) -> [ProgramDay] {
        days.filter { $0.week == week }
    }
}

@MainActor
final class ProgramPlanStore: ObservableObject {
    @Published private(set) var customDays: [String: ProgramDay] = [:]

    private let defaultsKey = "repforge.program.customDays.v1"

    init() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: ProgramDay].self, from: data) else {
            return
        }
        customDays = decoded
    }

    func day(for base: ProgramDay) -> ProgramDay {
        customDays[base.id] ?? base
    }

    func days(for week: Int) -> [ProgramDay] {
        BuiltInProgram.week(week).map(day(for:))
    }

    func isCustomized(_ day: ProgramDay) -> Bool {
        customDays[day.id] != nil
    }

    func save(_ day: ProgramDay) {
        customDays[day.id] = day
        persist()
    }

    func reset(_ day: ProgramDay) {
        customDays.removeValue(forKey: day.id)
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(customDays) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}

// MARK: - Persistence

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var exerciseIDsCSV: String
    var planJSON: String?
    var createdAt: Date

    init(name: String, exerciseIDs: [String], plan: [ProgramExercise]? = nil) {
        self.id = UUID()
        self.name = name
        self.exerciseIDsCSV = exerciseIDs.joined(separator: ",")
        self.planJSON = Self.encodePlan(plan)
        self.createdAt = .now
    }

    var exerciseIDs: [String] {
        get { exerciseIDsCSV.split(separator: ",").map(String.init).filter { !$0.isEmpty } }
        set { exerciseIDsCSV = newValue.joined(separator: ",") }
    }

    var plannedExercises: [ProgramExercise]? {
        get {
            guard let planJSON,
                  let data = planJSON.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode([ProgramExercise].self, from: data)
        }
        set {
            planJSON = Self.encodePlan(newValue)
        }
    }

    private static func encodePlan(_ plan: [ProgramExercise]?) -> String? {
        guard let plan,
              let data = try? JSONEncoder().encode(plan) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

@Model
final class WorkoutSession {
    var id: UUID
    var title: String
    var startedAt: Date
    var endedAt: Date?
    var note: String?
    @Relationship(deleteRule: .cascade)
    var exercises: [ExerciseLog]

    init(title: String, startedAt: Date = .now, exercises: [ExerciseLog] = [], note: String? = nil) {
        self.id = UUID()
        self.title = title
        self.startedAt = startedAt
        self.exercises = exercises
        self.note = note
    }

    var duration: TimeInterval {
        (endedAt ?? .now).timeIntervalSince(startedAt)
    }

    var totalVolume: Double {
        exercises.flatMap(\.sets).filter(\.completed).reduce(0) { $0 + ($1.weightKg * Double($1.reps)) }
    }
}

@Model
final class ExerciseLog {
    var id: UUID
    var exerciseID: String
    var order: Int
    var targetReps: String?
    var coachingNote: String?
    var supersetGroup: String?
    var sessionNote: String?
    var restSeconds: Int?
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet]

    init(
        exerciseID: String,
        order: Int,
        targetReps: String? = nil,
        coachingNote: String? = nil,
        supersetGroup: String? = nil,
        sessionNote: String? = nil,
        restSeconds: Int? = nil,
        sets: [WorkoutSet] = []
    ) {
        self.id = UUID()
        self.exerciseID = exerciseID
        self.order = order
        self.targetReps = targetReps
        self.coachingNote = coachingNote
        self.supersetGroup = supersetGroup
        self.sessionNote = sessionNote
        self.restSeconds = restSeconds
        self.sets = sets
    }
}

@Model
final class WorkoutSet {
    var id: UUID
    var order: Int
    var weightKg: Double
    var reps: Int
    var completed: Bool
    var completedAt: Date?
    var setTypeRaw: String?
    var rpe: Double?
    var rir: Int?
    var note: String?

    init(
        order: Int,
        weightKg: Double = 0,
        reps: Int = 0,
        completed: Bool = false,
        setTypeRaw: String? = nil,
        rpe: Double? = nil,
        rir: Int? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.order = order
        self.weightKg = weightKg
        self.reps = reps
        self.completed = completed
        self.setTypeRaw = setTypeRaw
        self.rpe = rpe
        self.rir = rir
        self.note = note
    }

    var setType: String {
        get { setTypeRaw ?? "working" }
        set { setTypeRaw = newValue == "working" ? nil : newValue }
    }

    var countsForPR: Bool {
        completed && setType != "warmup"
    }
}

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var bio: String
    var bodyWeightKg: Double
    var heightCm: Double
    var createdAt: Date

    init(displayName: String = "Athlete") {
        self.id = UUID()
        self.displayName = displayName
        self.bio = "Consistency compounds."
        self.bodyWeightKg = 0
        self.heightCm = 0
        self.createdAt = .now
    }
}

// MARK: - Metrics

enum Metrics {
    static func completedSessions(_ sessions: [WorkoutSession]) -> [WorkoutSession] {
        sessions.filter { $0.endedAt != nil }
    }

    static func performances(exerciseID: String, sessions: [WorkoutSession]) -> [(date: Date, weight: Double, oneRM: Double, volume: Double)] {
        completedSessions(sessions).compactMap { session in
            let sets = session.exercises
                .filter { $0.exerciseID == exerciseID }
                .flatMap(\.sets)
                .filter(\.countsForPR)
            guard !sets.isEmpty else { return nil }
            let best = sets.map(\.weightKg).max() ?? 0
            let oneRM = sets.map { estimated1RM(weight: $0.weightKg, reps: $0.reps) }.max() ?? 0
            let volume = sets.reduce(0) { $0 + $1.weightKg * Double($1.reps) }
            return (session.endedAt ?? session.startedAt, best, oneRM, volume)
        }
        .sorted { $0.date < $1.date }
    }

    static func previousSets(exerciseID: String, sessions: [WorkoutSession]) -> [(Double, Int)] {
        guard let latest = completedSessions(sessions)
            .filter({ $0.exercises.contains(where: { $0.exerciseID == exerciseID }) })
            .max(by: { ($0.endedAt ?? $0.startedAt) < ($1.endedAt ?? $1.startedAt) }),
              let log = latest.exercises.first(where: { $0.exerciseID == exerciseID })
        else { return [] }
        return log.sets.filter(\.countsForPR).sorted { $0.order < $1.order }.map { ($0.weightKg, $0.reps) }
    }

    static func personalBest(exerciseID: String, sessions: [WorkoutSession]) -> Double {
        performances(exerciseID: exerciseID, sessions: sessions).map(\.weight).max() ?? 0
    }

    static func estimated1RM(weight: Double, reps: Int) -> Double {
        guard weight > 0, reps > 0 else { return 0 }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }
}

// MARK: - Exercise media

struct ExerciseDBGenderMedia: Decodable {
    let male: String?
    let female: String?
}

struct ExerciseDBItem: Decodable {
    let id: String
    let name: String
    let aliases: [String]?
    let bodyPart: String?
    let target: String?
    let equipment: String?
    let videos: ExerciseDBGenderMedia?
    let thumbnails: ExerciseDBGenderMedia?
}

struct ExerciseMedia {
    let matchedName: String
    let maleVideoURL: URL?
    let femaleVideoURL: URL?
    let maleThumbnailURL: URL?
    let femaleThumbnailURL: URL?
    let sourceName: String
    let sourceURL: URL?

    var hasBothGenders: Bool {
        maleVideoURL != nil && femaleVideoURL != nil
    }
}

actor ExerciseMediaCatalog {
    static let shared = ExerciseMediaCatalog()

    private var cached: [ExerciseDBItem]?

    func exercises() async throws -> [ExerciseDBItem] {
        if let cached { return cached }

        let url = URL(string: "https://raw.githubusercontent.com/luisaraujoc/free-exercise-db-api/main/data/exercises.json")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.cachePolicy = .returnCacheDataElseLoad
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode([ExerciseDBItem].self, from: data)
        cached = decoded
        return decoded
    }
}

enum ExerciseMediaService {
    static func media(for exercise: ExerciseDefinition) async throws -> ExerciseMedia? {
        let items = try await ExerciseMediaCatalog.shared.exercises()
        guard !items.isEmpty else { return nil }

        if noExactDemo.contains(exercise.name) {
            return nil
        }

        let selected: ExerciseDBItem?

        if let sourceID = exactSourceIDs[exercise.name] {
            selected = items.first(where: { $0.id == sourceID })
        } else {
            let query = preferredSearchTerm(for: exercise)
            let ranked = items
                .map { ($0, score(item: $0, query: query, exercise: exercise)) }
                .sorted { $0.1 > $1.1 }

            if let (best, bestScore) = ranked.first, bestScore >= 300 {
                selected = best
            } else {
                selected = nil
            }
        }

        guard let best = selected else { return nil }

        let maleVideo = best.videos?.male.flatMap(URL.init(string:))
        let femaleVideo = best.videos?.female.flatMap(URL.init(string:))
        let maleThumb = best.thumbnails?.male.flatMap(URL.init(string:))
        let femaleThumb = best.thumbnails?.female.flatMap(URL.init(string:))

        guard maleVideo != nil || femaleVideo != nil || maleThumb != nil || femaleThumb != nil else {
            return nil
        }

        return ExerciseMedia(
            matchedName: best.name,
            maleVideoURL: maleVideo,
            femaleVideoURL: femaleVideo,
            maleThumbnailURL: maleThumb,
            femaleThumbnailURL: femaleThumb,
            sourceName: "Free Exercise DB",
            sourceURL: URL(string: "https://github.com/luisaraujoc/free-exercise-db-api")
        )
    }

    // These mappings were manually audited against the source catalog so a
    // semantically different exercise can never win only because of aliases.
    private static let exactSourceIDs: [String: String] = [
        "Barbell Flat Bench Press": "0025",
        "Bench Press (Barbell)": "0025",
        "Chest Supported Machine Row": "1349",
        "Lying Leg Curl": "0586",
        "Leg Curl (Lying)": "0586",
        "Cable Triceps Rope Pushdown": "0200",
        "Lateral Raise (Cable)": "0178",
        "Dumbbell Shoulder Press (Seated)": "0289",
        "Shoulder Press (Dumbbell)": "0289",
        "Wide Grip Lat Pulldown": "drv-cable-bar-lateral-pulldown-wide-shoulder-grip",
        "Lat Pulldown - Wide Grip": "drv-cable-bar-lateral-pulldown-wide-shoulder-grip",
        "Leg Extension (Machine)": "0585",
        "Standing Dumbbell Biceps Curl": "0294",
        "Goblet Squat": "1760",
        "Seated Cable Row (V-Bar)": "0208",
        "Seated Cable Row": "0208",
        "Incline Dumbbell Bench Press": "0314",
        "Incline Bench Press (Dumbbell)": "0314",
        "Standing Calf Raise": "0605",
        "Standing Dumbbell Lateral Raise": "0334",
        "Incline Dumbbell Curl": "0318",
        "Cable Overhead Triceps Rope Extension": "0194",
        "Reverse Pec Deck Machine": "0602",
        "Captain's Chair Leg Raise": "0826",
        "Hack Squat Machine": "0743",
        "Seated Leg Curl Machine": "0599",
        "Leg Curl (Seated)": "0599",
        "Cable Triceps Straight Bar Pushdown": "1723",
        "Standing Barbell Overhead Press (Military Press)": "0553",
        "Neutral Grip Lat Pulldown": "0974",
        "Dumbbell Walking Lunges": "0336",
        "Walking Lunge": "0336",
        "Cable Biceps Curl": "0229",
        "Chest Supported Dumbbell Row": "0327",
        "Seated Calf Raise Machine": "0594",
        "EZ-Bar Biceps Curl": "2407",
        "EZ-Bar Curl": "2407",
        "Kneeling Cable Crunch": "0175",
        "Abdominal Crunch Machine": "1452",
        "Triceps Pushdown": "1723",
        "Arnold Dumbbell Press": "2137",
        "Close-Grip Barbell Bench Press": "0030",
        "Dumbbell Preacher Curl": "0402",
        "Lying Dumbbell Skull Crushers": "0351",
        "Lying Floor Leg Raises": "0865",
        "Flat Leg Raise": "0865"
    ]

    // The source database does not contain an exact enough demonstration for
    // these RepForge exercises. Showing no video is preferable to a wrong one.
    private static let noExactDemo: Set<String> = [
        "Cable Face Pull",
        "Face Pull",
        "Dumbbell Romanian Deadlift",
        "Romanian Deadlift (Barbell)",
        "Trap Bar Deadlift",
        "Single-Arm Dumbbell Row",
        "One Arm Dumbbell Row",
        "Hammer Curl",
        "Assisted Dip Machine",
        "Lean-Away Cable Lateral Raise",
        "EZ-Bar Reverse Curl",
        "Flat Dumbbell Bench Press",
        "Bench Press (Dumbbell)"
    ]

    private static func preferredSearchTerm(for exercise: ExerciseDefinition) -> String {
        let explicit: [String: String] = [
            "Bench Press (Smith Machine)": "smith machine bench press",
            "Decline Bench Press": "barbell decline bench press",
            "Chest Press (Machine)": "lever chest press",
            "Cable Fly": "cable fly",
            "Push Up": "push up",
            "Dip (Chest)": "chest dip",
            "Deadlift (Barbell)": "barbell deadlift",
            "Bent Over Row (Barbell)": "barbell bent over row",
            "Bent Over Row (Dumbbell)": "dumbbell bent over row",
            "Lat Pulldown": "cable pulldown",
            "Pull Up": "pull up",
            "Chin Up": "chin up",
            "Back Extension": "back extension",
            "Shoulder Press (Machine)": "lever shoulder press",
            "Front Raise": "dumbbell front raise",
            "Rear Delt Fly": "dumbbell rear delt fly",
            "Biceps Curl (Barbell)": "barbell curl",
            "Biceps Curl (Dumbbell)": "dumbbell biceps curl",
            "Preacher Curl": "lever preacher curl",
            "Squat (Barbell)": "barbell squat",
            "Front Squat": "barbell front squat",
            "Leg Press": "lever horizontal leg press",
            "Bulgarian Split Squat": "dumbbell bulgarian split squat",
            "Hip Thrust (Barbell)": "barbell hip thrust",
            "Standing Calf Raise (Dumbbell)": "dumbbell standing calf raise",
            "Crunch": "floor crunch",
            "Cable Crunch": "cable kneeling crunch",
            "Hanging Leg Raise": "hanging leg hip raise",
            "Plank": "plank",
            "Russian Twist": "russian twist",
            "Bicycle Crunch": "bicycle crunch"
        ]

        if let explicit = explicit[exercise.name] { return explicit }

        return exercise.name
            .replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalize(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "&", with: " and ")
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: " ", options: .regularExpression)
            .split(separator: " ")
            .map(String.init)
            .filter { !["the", "with", "machine", "exercise"].contains($0) }
            .joined(separator: " ")
    }

    private static func score(item: ExerciseDBItem, query: String, exercise: ExerciseDefinition) -> Int {
        let q = normalize(query)
        let qTokens = Set(q.split(separator: " ").map(String.init))
        let primary = normalize(item.name)

        var best = 0

        if primary == q {
            best = 700
        } else if primary.contains(q) || q.contains(primary) {
            best = 360
        } else {
            let nameTokens = Set(primary.split(separator: " ").map(String.init))
            let intersection = qTokens.intersection(nameTokens).count
            let union = qTokens.union(nameTokens).count
            best = union == 0 ? 0 : Int((Double(intersection) / Double(union)) * 180.0)
        }

        for alias in item.aliases ?? [] {
            let normalizedAlias = normalize(alias)
            if normalizedAlias == q {
                best = max(best, 500)
            } else if normalizedAlias.contains(q) || q.contains(normalizedAlias) {
                best = max(best, 260)
            }
        }

        if let equipment = item.equipment {
            let sourceEquipment = normalize(equipment)
            let appEquipment = normalize(exercise.equipment)
            let compatible =
                sourceEquipment.contains(appEquipment) ||
                appEquipment.contains(sourceEquipment) ||
                (appEquipment == "machine" && (
                    sourceEquipment.contains("leverage") ||
                    sourceEquipment.contains("sled") ||
                    sourceEquipment.contains("smith")
                )) ||
                (appEquipment == "bodyweight" && sourceEquipment.contains("body weight"))

            best += compatible ? 45 : -80
        }

        if item.videos?.male != nil || item.videos?.female != nil {
            best += 20
        }

        return best
    }
}

@MainActor
final class ExerciseMediaModel: ObservableObject {
    @Published var media: ExerciseMedia?
    @Published var isLoading = false
    @Published var loadFailed = false

    func load(exercise: ExerciseDefinition) async {
        isLoading = true
        loadFailed = false
        defer { isLoading = false }

        do {
            media = try await ExerciseMediaService.media(for: exercise)
            loadFailed = media == nil
        } catch {
            media = nil
            loadFailed = true
        }
    }
}

// MARK: - App

@main
struct RepForgeApp: App {
    private let container: ModelContainer = {
        let schema = Schema([
            WorkoutTemplate.self,
            WorkoutSession.self,
            ExerciseLog.self,
            WorkoutSet.self,
            UserProfile.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData initialization failed: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @State private var tab = 2

    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("appearance") private var appearance = "dark"
    @AppStorage("themePreset") private var themePreset = "forge"
    @AppStorage("textSize") private var textSize = "standard"
    @AppStorage("measurementSystem") private var measurementSystem = "metric"

    var body: some View {
        TabView(selection: $tab) {
            ProfileView()
                .tabItem { Label(L10n.profile, systemImage: "person.crop.circle.fill") }
                .tag(0)
            HistoryView()
                .tabItem { Label(L10n.history, systemImage: "clock.fill") }
                .tag(1)
            StartWorkoutView()
                .tabItem { Label(L10n.workout, systemImage: "plus.circle.fill") }
                .tag(2)
            ExerciseLibraryView()
                .tabItem { Label(L10n.exercises, systemImage: "dumbbell.fill") }
                .tag(3)
            SettingsView()
                .tabItem { Label(L10n.settings, systemImage: "gearshape.fill") }
                .tag(4)
        }
        .tint(RFTheme.accent)
        .preferredColorScheme(preferredColorScheme)
        .dynamicTypeSize(preferredTextSize)
        .id("\(appLanguage)-\(appearance)-\(themePreset)-\(textSize)-\(measurementSystem)")
        .task {
            if profiles.isEmpty {
                context.insert(UserProfile())
                try? context.save()
            }
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var preferredTextSize: DynamicTypeSize {
        switch textSize {
        case "compact": return .small
        case "large": return .xLarge
        case "xlarge": return .xxLarge
        default: return .medium
        }
    }
}

// MARK: - Workout home

struct StartWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) private var templates: [WorkoutTemplate]
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @StateObject private var programStore = ProgramPlanStore()
    @State private var showTemplateEditor = false
    @State private var templateSeed: ProgramDay?
    @State private var editingTemplate: WorkoutTemplate?
    @State private var editingProgramDay: ProgramDay?
    @State private var activeSession: WorkoutSession?
    @State private var selectedProgramWeek = 1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Quick Start")
                        .font(.title2.bold())

                    Button {
                        activeSession = createSession(title: "Workout", exerciseIDs: [])
                    } label: {
                        Label("Start an Empty Workout", systemImage: "bolt.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RFTheme.accent)

                    HStack {
                        Text("Templates").font(.largeTitle.bold())
                        Spacer()
                        Button {
                            templateSeed = nil
                            showTemplateEditor = true
                        } label: {
                            Label("Template", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }

                    if templates.isEmpty {
                        EmptyCard(
                            icon: "rectangle.stack.badge.plus",
                            title: "Build your first template",
                            text: "Save a repeatable workout, then launch it with one tap."
                        )
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 165), spacing: 14)], spacing: 14) {
                            ForEach(templates) { template in
                                TemplateCard(
                                    template: template,
                                    onStart: {
                                        activeSession = createSession(template: template)
                                    },
                                    onEdit: {
                                        editingTemplate = template
                                    },
                                    onDuplicate: {
                                        duplicateTemplate(template)
                                    },
                                    onDelete: {
                                        context.delete(template)
                                        try? context.save()
                                    }
                                )
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your 3-Week Program")
                                .font(.title2.bold())
                            Spacer()
                            Picker("Week", selection: $selectedProgramWeek) {
                                Text("W1").tag(1)
                                Text("W2").tag(2)
                                Text("W3").tag(3)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 150)
                        }

                        ForEach(programStore.days(for: selectedProgramWeek)) { day in
                            ProgramDayCard(
                                day: day,
                                isCustomized: programStore.isCustomized(day),
                                onStart: {
                                    activeSession = createSession(day: day)
                                },
                                onEdit: {
                                    editingProgramDay = day
                                },
                                onSaveAsTemplate: {
                                    templateSeed = day
                                },
                                onReset: {
                                    programStore.reset(day)
                                }
                            )
                        }
                    }

                    if let current = sessions.first(where: { $0.endedAt == nil }) {
                        Button {
                            activeSession = current
                        } label: {
                            Label("Resume \(current.title)", systemImage: "arrowtriangle.right.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .background(RFTheme.bg)
            .navigationTitle(L10n.startWorkout)
            .sheet(isPresented: $showTemplateEditor) {
                TemplateEditorView()
            }
            .sheet(item: $templateSeed, onDismiss: {
                templateSeed = nil
            }) { day in
                TemplateEditorView(prefill: day)
            }
            .sheet(item: $editingTemplate) { template in
                TemplateEditorView(template: template)
            }
            .sheet(item: $editingProgramDay) { day in
                ProgramDayEditorView(day: day) { updated in
                    programStore.save(updated)
                }
            }
            .fullScreenCover(item: $activeSession) { session in
                ActiveWorkoutView(session: session)
            }
        }
    }

    private func duplicateTemplate(_ template: WorkoutTemplate) {
        let copy = WorkoutTemplate(
            name: "\(template.name) \(L10n.text("Copy", "Kopie"))",
            exerciseIDs: template.exerciseIDs,
            plan: template.plannedExercises
        )
        context.insert(copy)
        try? context.save()
        Haptics.light()
    }

    private func createSession(title: String, exerciseIDs: [String]) -> WorkoutSession {
        let logs = exerciseIDs.enumerated().map { index, id in
            ExerciseLog(
                exerciseID: id,
                order: index,
                sets: (0..<AppPreferences.defaultSets).map { WorkoutSet(order: $0) }
            )
        }
        let session = WorkoutSession(title: title, exercises: logs)
        context.insert(session)
        try? context.save()
        return session
    }

    private func createSession(template: WorkoutTemplate) -> WorkoutSession {
        if let plan = template.plannedExercises, !plan.isEmpty {
            let logs = plan.enumerated().compactMap { index, item -> ExerciseLog? in
                guard let exercise = ExerciseCatalog.findByName(item.name) else { return nil }
                return ExerciseLog(
                    exerciseID: exercise.id,
                    order: index,
                    targetReps: item.reps,
                    coachingNote: item.note,
                    supersetGroup: item.superset,
                    sets: (0..<max(1, item.sets)).map { WorkoutSet(order: $0) }
                )
            }
            let session = WorkoutSession(title: template.name, exercises: logs)
            context.insert(session)
            try? context.save()
            return session
        }

        return createSession(title: template.name, exerciseIDs: template.exerciseIDs)
    }

    private func createSession(day: ProgramDay) -> WorkoutSession {
        let logs = day.exercises.enumerated().compactMap { index, item -> ExerciseLog? in
            guard let exercise = ExerciseCatalog.findByName(item.name) else { return nil }
            return ExerciseLog(
                exerciseID: exercise.id,
                order: index,
                targetReps: item.reps,
                coachingNote: item.note,
                supersetGroup: item.superset,
                sets: (0..<item.sets).map { WorkoutSet(order: $0) }
            )
        }
        let session = WorkoutSession(title: "\(day.title) — \(day.focus)", exercises: logs)
        context.insert(session)
        try? context.save()
        return session
    }
}

struct ProgramDayCard: View {
    let day: ProgramDay
    let isCustomized: Bool
    let onStart: () -> Void
    let onEdit: () -> Void
    let onSaveAsTemplate: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Text(day.day).font(.headline)
                        if isCustomized {
                            Text("Edited")
                                .font(.caption2.bold())
                                .foregroundStyle(RFTheme.accent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(RFTheme.accent.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    Text(day.focus).font(.subheadline).foregroundStyle(RFTheme.accent)
                    Text(day.partner.capitalized).font(.caption).foregroundStyle(RFTheme.muted)
                }

                Spacer()

                Menu {
                    Button(action: onEdit) {
                        Label("Edit Workout", systemImage: "pencil")
                    }
                    Button(action: onSaveAsTemplate) {
                        Label("Add to New Template", systemImage: "rectangle.stack.badge.plus")
                    }
                    if isCustomized {
                        Button(role: .destructive, action: onReset) {
                            Label("Reset to Original", systemImage: "arrow.counterclockwise")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .frame(width: 38, height: 38)
                        .background(RFTheme.raised)
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                }
            }

            ForEach(Array(day.exercises.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if let group = item.superset, !group.isEmpty {
                        Text("SS \(group)")
                            .font(.caption2.bold())
                            .foregroundStyle(RFTheme.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(RFTheme.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text(item.name)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Text("\(item.sets) × \(item.reps)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .tint(RFTheme.accent)

                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)

                Button(action: onSaveAsTemplate) {
                    Label("Template", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08)))
    }
}

struct ProgramDayEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ProgramDay
    @State private var showPicker = false
    @State private var pickerIDs: [String] = []
    let onSave: (ProgramDay) -> Void

    init(day: ProgramDay, onSave: @escaping (ProgramDay) -> Void) {
        _draft = State(initialValue: day)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Workout") {
                    TextField("Day", text: $draft.day)
                    TextField("Focus", text: $draft.focus)
                    TextField("Training partner / note", text: $draft.partner)
                }

                Section("Exercises") {
                    ForEach(draft.exercises.indices, id: \.self) { index in
                        ProgramExerciseEditorRow(item: $draft.exercises[index])
                    }
                    .onDelete { offsets in
                        draft.exercises.remove(atOffsets: offsets)
                    }
                    .onMove { source, destination in
                        draft.exercises.move(fromOffsets: source, toOffset: destination)
                    }

                    Button {
                        pickerIDs = []
                        showPicker = true
                    } label: {
                        Label("Add Exercises", systemImage: "plus")
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .navigationTitle("Edit \(draft.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .bold()
                    .disabled(draft.exercises.isEmpty)
                }
            }
            .sheet(isPresented: $showPicker, onDismiss: addPickedExercises) {
                ExercisePickerView(selectedIDs: $pickerIDs)
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func addPickedExercises() {
        let existing = Set(draft.exercises.map(\.name))
        for id in pickerIDs {
            guard let exercise = ExerciseCatalog.find(id),
                  !existing.contains(exercise.name) else { continue }
            draft.exercises.append(ProgramExercise(exercise.name, 3, "8–12"))
        }
        pickerIDs = []
    }
}

struct ProgramExerciseEditorRow: View {
    @Binding var item: ProgramExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(item.name)
                .font(.headline)

            HStack(spacing: 14) {
                Stepper("Sets \(item.sets)", value: $item.sets, in: 1...10)

                TextField("Reps", text: $item.reps)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 86)
                    .multilineTextAlignment(.center)
            }

            HStack {
                TextField("Note (optional)", text: Binding(
                    get: { item.note ?? "" },
                    set: { item.note = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)

                TextField("SS", text: Binding(
                    get: { item.superset ?? "" },
                    set: { item.superset = $0.isEmpty ? nil : $0.uppercased() }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 62)
                .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 5)
    }
}

struct TemplateCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundStyle(RFTheme.accent)
                Spacer()
                Menu {
                    Button(action: onEdit) {
                        Label(L10n.text("Edit Template", "Template bewerken"), systemImage: "pencil")
                    }
                    Button(action: onDuplicate) {
                        Label(L10n.text("Duplicate", "Dupliceren"), systemImage: "plus.square.on.square")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .background(RFTheme.raised)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Text(template.name)
                .font(.headline)
                .lineLimit(2)

            Text((template.plannedExercises?.map(\.name) ?? template.exerciseIDs.compactMap(ExerciseCatalog.find).map(\.name)).joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(RFTheme.muted)
                .lineLimit(4)

            HStack(spacing: 8) {
                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .tint(RFTheme.accent)

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Edit template")
            }
        }
        .padding()
        .frame(minHeight: 180, alignment: .topLeading)
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12)))
    }
}

struct TemplateEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    private let template: WorkoutTemplate?

    @State private var name: String
    @State private var items: [ProgramExercise]
    @State private var showPicker = false
    @State private var pickerIDs: [String] = []

    init(prefill: ProgramDay? = nil, template: WorkoutTemplate? = nil) {
        self.template = template

        if let template {
            _name = State(initialValue: template.name)
            let existing = template.plannedExercises ??
                template.exerciseIDs.compactMap { id in
                    guard let exercise = ExerciseCatalog.find(id) else { return nil }
                    return ProgramExercise(exercise.name, 3, "8–12")
                }
            _items = State(initialValue: existing)
        } else if let prefill {
            _name = State(initialValue: "\(prefill.day) — \(prefill.focus)")
            _items = State(initialValue: prefill.exercises)
        } else {
            _name = State(initialValue: "New Template")
            _items = State(initialValue: [])
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Template") {
                    TextField("Name", text: $name)
                }

                Section("Exercises") {
                    ForEach(items.indices, id: \.self) { index in
                        ProgramExerciseEditorRow(item: $items[index])
                    }
                    .onDelete { offsets in
                        items.remove(atOffsets: offsets)
                    }
                    .onMove { source, destination in
                        items.move(fromOffsets: source, toOffset: destination)
                    }

                    Button {
                        pickerIDs = []
                        showPicker = true
                    } label: {
                        Label("Add Exercises", systemImage: "plus")
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .navigationTitle(template == nil ? "New Template" : "Edit Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .bold()
                    .disabled(items.isEmpty)
                }
            }
            .sheet(isPresented: $showPicker, onDismiss: addPickedExercises) {
                ExercisePickerView(selectedIDs: $pickerIDs)
            }
        }
    }

    private func saveTemplate() {
        let ids = items.compactMap { ExerciseCatalog.findByName($0.name)?.id }
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = cleanName.isEmpty ? "Workout" : cleanName

        if let template {
            template.name = finalName
            template.exerciseIDs = ids
            template.plannedExercises = items
        } else {
            context.insert(
                WorkoutTemplate(
                    name: finalName,
                    exerciseIDs: ids,
                    plan: items
                )
            )
        }

        try? context.save()
        dismiss()
    }

    private func addPickedExercises() {
        let existing = Set(items.map(\.name))
        for id in pickerIDs {
            guard let exercise = ExerciseCatalog.find(id),
                  !existing.contains(exercise.name) else { continue }
            items.append(ProgramExercise(exercise.name, 3, "8–12"))
        }
        pickerIDs = []
    }
}

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIDs: [String]
    @State private var search = ""
    @State private var muscle = "All"

    private var filtered: [ExerciseDefinition] {
        ExerciseCatalog.all.filter { ex in
            (search.isEmpty || ex.name.localizedCaseInsensitiveContains(search)) &&
            (muscle == "All" || ex.muscle == muscle)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { ex in
                Button {
                    if selectedIDs.contains(ex.id) {
                        selectedIDs.removeAll { $0 == ex.id }
                    } else {
                        selectedIDs.append(ex.id)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(ex.name).foregroundStyle(.primary).font(.headline)
                            Text("\(ex.muscle) • \(ex.equipment)").foregroundStyle(.secondary).font(.caption)
                        }
                        Spacer()
                        Image(systemName: selectedIDs.contains(ex.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedIDs.contains(ex.id) ? RFTheme.accent : RFTheme.muted)
                    }
                }
            }
            .searchable(text: $search, prompt: "Search exercises")
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .navigationTitle(L10n.exercises)
            .safeAreaInset(edge: .top) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["All"] + ExerciseCatalog.muscles, id: \.self) { item in
                            Button(item) { muscle = item }
                                .buttonStyle(.bordered)
                                .tint(muscle == item ? RFTheme.accent : .gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.ultraThinMaterial)
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedIDs.isEmpty ? "No exercises selected" : "\(selectedIDs.count) selected")
                            .font(.caption.bold())
                        Text("Tap exercises to add or remove them")
                            .font(.caption2)
                            .foregroundStyle(RFTheme.muted)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Text(selectedIDs.isEmpty ? "Done" : "Add \(selectedIDs.count)")
                            .font(.headline)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RFTheme.accent)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.bold()
                }
            }
        }
    }
}

// MARK: - Active workout

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var session: WorkoutSession
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var allSessions: [WorkoutSession]

    @State private var showExercisePicker = false
    @State private var pickerIDs: [String] = []
    @State private var showFinishConfirm = false
    @State private var showSummary = false
    @State private var restRemaining = 0
    @State private var restOriginal = 0
    @State private var showWorkoutNote = false

    @AppStorage("keepScreenAwake") private var keepScreenAwake = true
    @AppStorage("autoRestTimer") private var autoRestTimer = true
    @AppStorage("defaultRestSeconds") private var defaultRestSeconds = 90

    private let restTicker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.title).font(.largeTitle.bold())
                            TimelineView(.periodic(from: .now, by: 1)) { _ in
                                Label(durationString(session.duration), systemImage: "clock")
                                    .foregroundStyle(RFTheme.muted)
                            }
                        }
                        Spacer()
                        Button(L10n.finish) { showFinishConfirm = true }
                            .buttonStyle(.borderedProminent)
                            .tint(RFTheme.success)
                            .font(.headline)
                    }

                    Button {
                        showWorkoutNote.toggle()
                    } label: {
                        HStack {
                            Label(
                                (session.note ?? "").isEmpty
                                    ? L10n.text("Add workout note", "Trainingsnotitie toevoegen")
                                    : L10n.text("Workout note", "Trainingsnotitie"),
                                systemImage: "note.text"
                            )
                            Spacer()
                            Image(systemName: showWorkoutNote ? "chevron.up" : "chevron.down")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(RFTheme.accent)

                    if showWorkoutNote {
                        TextField(
                            L10n.text("How did the workout feel?", "Hoe voelde de training?"),
                            text: Binding(
                                get: { session.note ?? "" },
                                set: { session.note = $0; try? context.save() }
                            ),
                            axis: .vertical
                        )
                        .lineLimit(2...5)
                        .padding(12)
                        .background(RFTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if session.exercises.isEmpty {
                        EmptyCard(
                            icon: "dumbbell",
                            title: L10n.text("No exercises yet", "Nog geen oefeningen"),
                            text: L10n.text("Add an exercise to begin logging sets.", "Voeg een oefening toe om sets te registreren.")
                        )
                    }

                    ForEach(session.exercises.sorted(by: { $0.order < $1.order })) { log in
                        WorkoutExerciseBlock(
                            log: log,
                            sessions: allSessions,
                            onSetCompleted: {
                                startRestTimer(for: log)
                            },
                            onMoveUp: { moveExercise(log, delta: -1) },
                            onMoveDown: { moveExercise(log, delta: 1) },
                            onDuplicate: { duplicateExercise(log) },
                            onRemoveExercise: { removeExercise(log) }
                        )
                    }

                    Button {
                        pickerIDs = []
                        showExercisePicker = true
                    } label: {
                        Label(L10n.addExercise, systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                    }
                    .buttonStyle(.bordered)
                    .tint(RFTheme.accent)
                }
                .padding()
                .padding(.bottom, restRemaining > 0 ? 88 : 0)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(RFTheme.bg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if restRemaining > 0 {
                    RestTimerBanner(
                        remaining: restRemaining,
                        original: max(restOriginal, 1),
                        onAdd30: {
                            restRemaining += 30
                            restOriginal = max(restOriginal, restRemaining)
                            Haptics.light()
                        },
                        onSkip: {
                            restRemaining = 0
                            Haptics.light()
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
            }
            .onReceive(restTicker) { _ in
                guard restRemaining > 0 else { return }
                restRemaining -= 1
                if restRemaining == 0 {
                    Haptics.success()
                }
            }
            .confirmationDialog(
                L10n.text("Finish this workout?", "Deze training afronden?"),
                isPresented: $showFinishConfirm
            ) {
                Button(L10n.text("Finish Workout", "Training afronden")) {
                    finishWorkout()
                }
                Button(L10n.text("Cancel", "Annuleren"), role: .cancel) {}
            } message: {
                Text(L10n.text(
                    "Completed sets, weights and reps will be added to your history.",
                    "Voltooide sets, gewichten en herhalingen worden aan je geschiedenis toegevoegd."
                ))
            }
            .sheet(isPresented: $showExercisePicker, onDismiss: addPickedExercises) {
                ExercisePickerView(selectedIDs: $pickerIDs)
            }
            .sheet(isPresented: $showSummary) {
                WorkoutSummaryView(
                    session: session,
                    sessions: allSessions,
                    onDone: {
                        showSummary = false
                        dismiss()
                    }
                )
                .interactiveDismissDisabled()
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
            }
            .onChange(of: keepScreenAwake) { _, enabled in
                UIApplication.shared.isIdleTimerDisabled = enabled
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    private func finishWorkout() {
        session.endedAt = .now
        restRemaining = 0
        try? context.save()
        Haptics.success()
        showSummary = true
    }

    private func startRestTimer(for log: ExerciseLog) {
        guard autoRestTimer else { return }
        let seconds = log.restSeconds ?? defaultRestSeconds
        guard seconds > 0 else { return }
        restRemaining = seconds
        restOriginal = seconds
    }

    private func addPickedExercises() {
        guard !pickerIDs.isEmpty else { return }
        let existing = Set(session.exercises.map(\.exerciseID))
        var nextOrder = (session.exercises.map(\.order).max() ?? -1) + 1
        for id in pickerIDs where !existing.contains(id) {
            session.exercises.append(ExerciseLog(
                exerciseID: id,
                order: nextOrder,
                restSeconds: defaultRestSeconds,
                sets: (0..<AppPreferences.defaultSets).map { WorkoutSet(order: $0) }
            ))
            nextOrder += 1
        }
        pickerIDs = []
        try? context.save()
    }

    private func moveExercise(_ log: ExerciseLog, delta: Int) {
        var ordered = session.exercises.sorted(by: { $0.order < $1.order })
        guard let current = ordered.firstIndex(where: { $0.id == log.id }) else { return }
        let destination = current + delta
        guard ordered.indices.contains(destination) else { return }
        ordered.swapAt(current, destination)
        for (index, item) in ordered.enumerated() {
            item.order = index
        }
        Haptics.light()
        try? context.save()
    }

    private func duplicateExercise(_ log: ExerciseLog) {
        let copySets = log.sets.sorted(by: { $0.order < $1.order }).map {
            WorkoutSet(
                order: $0.order,
                weightKg: $0.weightKg,
                reps: $0.reps,
                setTypeRaw: $0.setTypeRaw,
                rpe: $0.rpe,
                rir: $0.rir
            )
        }
        let next = (session.exercises.map(\.order).max() ?? -1) + 1
        session.exercises.append(
            ExerciseLog(
                exerciseID: log.exerciseID,
                order: next,
                targetReps: log.targetReps,
                coachingNote: log.coachingNote,
                supersetGroup: log.supersetGroup,
                sessionNote: log.sessionNote,
                restSeconds: log.restSeconds,
                sets: copySets
            )
        )
        Haptics.light()
        try? context.save()
    }

    private func removeExercise(_ log: ExerciseLog) {
        session.exercises.removeAll { $0.id == log.id }
        context.delete(log)

        for (index, exercise) in session.exercises
            .sorted(by: { $0.order < $1.order })
            .enumerated() {
            exercise.order = index
        }

        try? context.save()
    }
}

struct RestTimerBanner: View {
    let remaining: Int
    let original: Int
    let onAdd30: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(RFTheme.raised, lineWidth: 5)
                Circle()
                    .trim(from: 0, to: min(1, Double(remaining) / Double(max(original, 1))))
                    .stroke(RFTheme.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(durationString(TimeInterval(remaining)))
                    .font(.caption.bold())
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.text("Rest timer", "Rusttimer"))
                    .font(.headline)
                Text(L10n.text("Recover, then hit the next set.", "Herstel en begin daarna aan je volgende set."))
                    .font(.caption)
                    .foregroundStyle(RFTheme.muted)
                    .lineLimit(1)
            }

            Spacer()

            Button("+30", action: onAdd30)
                .buttonStyle(.bordered)

            Button(L10n.text("Skip", "Stop"), action: onSkip)
                .buttonStyle(.borderedProminent)
                .tint(RFTheme.accent)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 8)
    }
}


struct WorkoutExerciseBlock: View {
    @Environment(\.modelContext) private var context
    @Bindable var log: ExerciseLog
    let sessions: [WorkoutSession]
    let onSetCompleted: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDuplicate: () -> Void
    let onRemoveExercise: () -> Void

    @State private var showRemoveExerciseConfirm = false
    @State private var showOptions = false

    private var exercise: ExerciseDefinition? { ExerciseCatalog.find(log.exerciseID) }
    private var previous: [(Double, Int)] { Metrics.previousSets(exerciseID: log.exerciseID, sessions: sessions) }
    private var best: Double { Metrics.personalBest(exerciseID: log.exerciseID, sessions: sessions) }
    private var orderedSets: [WorkoutSet] { log.sets.sorted(by: { $0.order < $1.order }) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let ex = exercise {
                HStack(alignment: .top) {
                    NavigationLink {
                        ExerciseDetailView(exercise: ex)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ex.name)
                                .font(.title3.bold())
                                .foregroundStyle(RFTheme.accent)

                            HStack(spacing: 8) {
                                Text(best > 0
                                     ? "Best: \(AppPreferences.displayWeight(best).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)"
                                     : L10n.text("No previous best", "Nog geen persoonlijk record"))

                                if let target = log.targetReps {
                                    Text("\(L10n.text("Target", "Doel")) \(target)")
                                        .foregroundStyle(RFTheme.accent)
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(RFTheme.muted)

                            if let note = log.coachingNote {
                                Text(note)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            if let sessionNote = log.sessionNote, !sessionNote.isEmpty {
                                Label(sessionNote, systemImage: "note.text")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            if let group = log.supersetGroup {
                                Label("Superset \(group)", systemImage: "link")
                                    .font(.caption.bold())
                                    .foregroundStyle(RFTheme.accent)
                            }
                        }
                    }

                    Spacer()

                    Menu {
                        NavigationLink {
                            ExerciseDetailView(exercise: ex)
                        } label: {
                            Label(L10n.text("Exercise Guide", "Oefening uitleg"), systemImage: "info.circle")
                        }

                        Button {
                            copyPreviousSets()
                        } label: {
                            Label(L10n.text("Copy Previous Sets", "Vorige sets kopiëren"), systemImage: "doc.on.doc")
                        }
                        .disabled(previous.isEmpty)

                        Button(action: onMoveUp) {
                            Label(L10n.text("Move Up", "Omhoog"), systemImage: "arrow.up")
                        }

                        Button(action: onMoveDown) {
                            Label(L10n.text("Move Down", "Omlaag"), systemImage: "arrow.down")
                        }

                        Button(action: onDuplicate) {
                            Label(L10n.text("Duplicate Exercise", "Oefening dupliceren"), systemImage: "plus.square.on.square")
                        }

                        Button {
                            showOptions = true
                        } label: {
                            Label(L10n.text("Exercise Options", "Oefening opties"), systemImage: "slider.horizontal.3")
                        }

                        Divider()

                        Button(role: .destructive) {
                            showRemoveExerciseConfirm = true
                        } label: {
                            Label(L10n.text("Remove Exercise", "Oefening verwijderen"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .foregroundStyle(RFTheme.accent)
                            .frame(width: 40, height: 40)
                            .background(RFTheme.raised)
                            .clipShape(RoundedRectangle(cornerRadius: 11))
                    }
                }
            }

            HStack {
                Text(L10n.text("Set", "Set")).frame(width: 42, alignment: .leading)
                if AppPreferences.showPreviousSets {
                    Text(L10n.text("Previous", "Vorige")).frame(maxWidth: .infinity)
                }
                Text(AppPreferences.weightLabel).frame(width: 76)
                Text(L10n.text("Reps", "Reps")).frame(width: 64)
                Image(systemName: "checkmark").frame(width: 34)
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)

            ForEach(orderedSets) { set in
                WorkoutSetRow(
                    set: set,
                    previous: previous.indices.contains(set.order) ? previous[set.order] : nil,
                    canDelete: log.sets.count > 1,
                    onCompleted: { completed in
                        if completed { onSetCompleted() }
                    },
                    onDelete: {
                        removeSet(set)
                    }
                )
            }

            Button {
                addSet()
            } label: {
                Label(L10n.text("Add Set", "Set toevoegen"), systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(RFTheme.accent)
        }
        .padding()
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .sheet(isPresented: $showOptions) {
            ExerciseLogOptionsView(log: log)
        }
        .confirmationDialog(
            L10n.text("Remove \(exercise?.name ?? "exercise")?", "\(exercise?.name ?? "oefening") verwijderen?"),
            isPresented: $showRemoveExerciseConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.text("Remove Exercise", "Oefening verwijderen"), role: .destructive) {
                onRemoveExercise()
            }
            Button(L10n.text("Cancel", "Annuleren"), role: .cancel) {}
        } message: {
            Text(L10n.text(
                "This removes the exercise and its sets from the current workout only.",
                "Dit verwijdert de oefening en de sets alleen uit deze training."
            ))
        }
    }

    private func copyPreviousSets() {
        guard !previous.isEmpty else { return }

        while log.sets.count < previous.count {
            log.sets.append(WorkoutSet(order: log.sets.count))
        }

        for (index, values) in previous.enumerated() {
            guard log.sets.indices.contains(index) else { continue }
            log.sets[index].weightKg = values.0
            log.sets[index].reps = values.1
            log.sets[index].completed = false
            log.sets[index].completedAt = nil
        }

        Haptics.light()
        try? context.save()
    }

    private func addSet() {
        Haptics.light()
        let next = (log.sets.map(\.order).max() ?? -1) + 1
        log.sets.append(WorkoutSet(order: next))
        try? context.save()
    }

    private func removeSet(_ set: WorkoutSet) {
        guard log.sets.count > 1 else { return }
        log.sets.removeAll { $0.id == set.id }
        context.delete(set)
        renumberSets()
        try? context.save()
    }

    private func renumberSets() {
        for (index, set) in log.sets.sorted(by: { $0.order < $1.order }).enumerated() {
            set.order = index
        }
    }
}

struct ExerciseLogOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var log: ExerciseLog

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.text("Rest timer", "Rusttimer")) {
                    Stepper(
                        "\(L10n.text("Rest", "Rust")): \(log.restSeconds ?? AppPreferences.defaultRestSeconds)s",
                        value: Binding(
                            get: { log.restSeconds ?? AppPreferences.defaultRestSeconds },
                            set: { log.restSeconds = $0 }
                        ),
                        in: 15...600,
                        step: 15
                    )

                    Button(L10n.text("Use app default", "Gebruik app-standaard")) {
                        log.restSeconds = nil
                    }
                }

                Section(L10n.text("Workout note", "Trainingsnotitie")) {
                    TextField(
                        L10n.text("Note for this exercise", "Notitie voor deze oefening"),
                        text: Binding(
                            get: { log.sessionNote ?? "" },
                            set: { log.sessionNote = $0 }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(2...5)
                }
            }
            .navigationTitle(L10n.text("Exercise Options", "Oefening opties"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.done) {
                        try? context.save()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}


struct WorkoutSetRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var set: WorkoutSet
    let previous: (Double, Int)?
    let canDelete: Bool
    let onCompleted: (Bool) -> Void
    let onDelete: () -> Void

    @State private var showSetOptions = false
    @State private var dragOffset: CGFloat = 0
    @State private var restingOffset: CGFloat = 0
    @State private var dragAxis: SwipeAxis?

    private enum SwipeAxis {
        case horizontal
        case vertical
    }

    private let deleteWidth: CGFloat = 78

    var body: some View {
        ZStack(alignment: .trailing) {
            if canDelete {
                Button(role: .destructive) {
                    withAnimation(.snappy) {
                        dragOffset = 0
                        restingOffset = 0
                    }
                    Haptics.light()
                    onDelete()
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "trash.fill")
                        Text(L10n.text("Delete", "Verwijder"))
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(.white)
                    .frame(width: deleteWidth, height: 44)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel(L10n.text("Delete set \(set.order + 1)", "Set \(set.order + 1) verwijderen"))
            }

            rowContent
                .background(RFTheme.surface)
                .offset(x: dragOffset)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 14)
                        .onChanged { value in
                            guard canDelete else { return }

                            let horizontal = value.translation.width
                            let vertical = value.translation.height

                            if dragAxis == nil,
                               max(abs(horizontal), abs(vertical)) > 10 {
                                dragAxis = abs(horizontal) > abs(vertical) * 1.20
                                    ? .horizontal
                                    : .vertical
                            }

                            guard dragAxis == .horizontal else { return }

                            let proposed = restingOffset + horizontal
                            dragOffset = min(0, max(-deleteWidth * 1.45, proposed))
                        }
                        .onEnded { _ in
                            defer { dragAxis = nil }
                            guard canDelete, dragAxis == .horizontal else { return }

                            if dragOffset < -(deleteWidth * 1.15) {
                                withAnimation(.easeOut(duration: 0.16)) {
                                    dragOffset = -360
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                                    Haptics.light()
                                    onDelete()
                                    dragOffset = 0
                                    restingOffset = 0
                                }
                            } else if dragOffset < -(deleteWidth * 0.38) {
                                withAnimation(.snappy) {
                                    dragOffset = -deleteWidth
                                    restingOffset = -deleteWidth
                                }
                            } else {
                                withAnimation(.snappy) {
                                    dragOffset = 0
                                    restingOffset = 0
                                }
                            }
                        }
                )
                .onTapGesture {
                    if restingOffset != 0 {
                        withAnimation(.snappy) {
                            dragOffset = 0
                            restingOffset = 0
                        }
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showSetOptions) {
            SetOptionsView(set: set)
        }
    }

    private func setTypeShort(_ type: String) -> String {
        switch type {
        case "warmup": return "WU"
        case "drop": return "DROP"
        case "failure": return "FAIL"
        default: return ""
        }
    }

    private var rowContent: some View {
        HStack(spacing: 8) {
            Button {
                showSetOptions = true
            } label: {
                VStack(spacing: 1) {
                    Text("\(set.order + 1)")
                        .font(.headline)
                    if set.setType != "working" {
                        Text(setTypeShort(set.setType))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(RFTheme.accent)
                    }
                }
                .frame(width: 42, height: 42)
                .background(RFTheme.field)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            if AppPreferences.showPreviousSets {
                Text(previous.map {
                    "\(AppPreferences.displayWeight($0.0).formatted(.number.precision(.fractionLength(0...2)))) × \($0.1)"
                } ?? "—")
                    .font(.caption)
                    .foregroundStyle(RFTheme.muted)
                    .frame(maxWidth: .infinity)
            }

            DoneNumberField(
                value: Binding(
                    get: { AppPreferences.displayWeight(set.weightKg) },
                    set: { set.weightKg = AppPreferences.storedWeightKg($0) }
                ),
                integerOnly: false,
                placeholder: "0"
            )
            .frame(width: 76, height: 42)
            .background(RFTheme.field)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            DoneNumberField(
                value: Binding(
                    get: { Double(set.reps) },
                    set: { set.reps = max(0, Int($0.rounded())) }
                ),
                integerOnly: true,
                placeholder: "0"
            )
            .frame(width: 64, height: 42)
            .background(RFTheme.field)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                set.completed.toggle()
                set.completedAt = set.completed ? .now : nil
                if set.completed { Haptics.success() } else { Haptics.light() }
                try? context.save()
                onCompleted(set.completed)
            } label: {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(set.completed ? RFTheme.success : RFTheme.muted)
            }
            .frame(width: 34)
        }
        .frame(height: 44)
    }
}

struct SetOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var set: WorkoutSet

    @State private var useRPE: Bool
    @State private var useRIR: Bool

    init(set: WorkoutSet) {
        self.set = set
        _useRPE = State(initialValue: set.rpe != nil)
        _useRIR = State(initialValue: set.rir != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.text("Set type", "Settype")) {
                    Picker(
                        L10n.text("Type", "Type"),
                        selection: Binding(
                            get: { set.setType },
                            set: { set.setType = $0 }
                        )
                    ) {
                        Text(L10n.text("Working", "Werkset")).tag("working")
                        Text(L10n.text("Warm-up", "Warming-up")).tag("warmup")
                        Text(L10n.text("Drop set", "Dropset")).tag("drop")
                        Text(L10n.text("To failure", "Tot falen")).tag("failure")
                    }
                    .pickerStyle(.segmented)

                    if set.setType == "warmup" {
                        Text(L10n.text(
                            "Warm-up sets are excluded from personal-record calculations.",
                            "Warming-upsets tellen niet mee voor persoonlijke records."
                        ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Section("RPE / RIR") {
                    Toggle("RPE", isOn: $useRPE)
                        .onChange(of: useRPE) { _, enabled in
                            set.rpe = enabled ? (set.rpe ?? 8) : nil
                        }

                    if useRPE {
                        Stepper(
                            "RPE \(set.rpe?.formatted(.number.precision(.fractionLength(0...1))) ?? "8")",
                            value: Binding(
                                get: { set.rpe ?? 8 },
                                set: { set.rpe = $0 }
                            ),
                            in: 5...10,
                            step: 0.5
                        )
                    }

                    Toggle("RIR", isOn: $useRIR)
                        .onChange(of: useRIR) { _, enabled in
                            set.rir = enabled ? (set.rir ?? 2) : nil
                        }

                    if useRIR {
                        Stepper(
                            "RIR \(set.rir ?? 2)",
                            value: Binding(
                                get: { set.rir ?? 2 },
                                set: { set.rir = $0 }
                            ),
                            in: 0...6
                        )
                    }
                }

                Section(L10n.text("Set note", "Setnotitie")) {
                    TextField(
                        L10n.text("Optional note", "Optionele notitie"),
                        text: Binding(
                            get: { set.note ?? "" },
                            set: { set.note = $0 }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(2...5)
                }
            }
            .navigationTitle(L10n.text("Set \(set.order + 1)", "Set \(set.order + 1)"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.done) {
                        try? context.save()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

struct DoneNumberField: UIViewRepresentable {
    @Binding var value: Double
    let integerOnly: Bool
    let placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.keyboardType = integerOnly ? .numberPad : .decimalPad
        field.textAlignment = .center
        field.textColor = .label
        field.tintColor = UIColor(RFTheme.accent)
        field.placeholder = placeholder
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 12
        field.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .editingChanged)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(
                title: L10n.done,
                style: .done,
                target: context.coordinator,
                action: #selector(Coordinator.doneTapped)
            )
        ]
        field.inputAccessoryView = toolbar
        context.coordinator.field = field
        field.text = formatted(value)
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        guard !uiView.isFirstResponder else { return }
        let expected = formatted(value)
        if uiView.text != expected {
            uiView.text = expected
        }

        if let toolbar = uiView.inputAccessoryView as? UIToolbar,
           let done = toolbar.items?.last {
            done.title = L10n.done
        }
    }

    private func formatted(_ value: Double) -> String {
        guard value != 0 else { return "" }
        if integerOnly { return String(Int(value.rounded())) }
        return value.formatted(.number.precision(.fractionLength(0...2)))
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DoneNumberField
        weak var field: UITextField?

        init(parent: DoneNumberField) {
            self.parent = parent
        }

        @objc func changed(_ sender: UITextField) {
            let raw = sender.text ?? ""
            let normalized = raw.replacingOccurrences(of: ",", with: ".")
            guard !normalized.isEmpty else {
                parent.value = 0
                return
            }

            if parent.integerOnly {
                parent.value = Double(Int(normalized) ?? 0)
            } else if let parsed = Double(normalized) {
                parent.value = max(0, parsed)
            }
        }

        @objc func doneTapped() {
            field?.resignFirstResponder()
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}


struct WorkoutSummaryView: View {
    let session: WorkoutSession
    let sessions: [WorkoutSession]
    let onDone: () -> Void

    private var completedSets: [WorkoutSet] {
        session.exercises.flatMap(\.sets).filter(\.completed)
    }

    private var prs: [(String, Double, Double)] {
        let previousSessions = sessions.filter { $0.id != session.id && $0.endedAt != nil }

        return session.exercises.compactMap { log in
            let current = log.sets.filter(\.countsForPR).map(\.weightKg).max() ?? 0
            guard current > 0 else { return nil }
            let previous = Metrics.personalBest(exerciseID: log.exerciseID, sessions: previousSessions)
            guard current > previous else { return nil }
            let name = ExerciseCatalog.find(log.exerciseID)?.name ?? "Exercise"
            return (name, current, previous)
        }
    }

    private var progressionSuggestions: [(String, Double)] {
        session.exercises.compactMap { log in
            guard let target = log.targetReps,
                  let upper = highestRepTarget(target) else { return nil }

            let workingSets = log.sets.filter { $0.countsForPR && $0.setType == "working" }
            guard !workingSets.isEmpty,
                  workingSets.allSatisfy({ $0.reps >= upper }),
                  let current = workingSets.map(\.weightKg).max(),
                  current > 0 else { return nil }

            let name = ExerciseCatalog.find(log.exerciseID)?.name ?? "Exercise"
            return (name, current + AppPreferences.progressionStepKg)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(spacing: 8) {
                        Image(systemName: prs.isEmpty ? "checkmark.circle.fill" : "trophy.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(prs.isEmpty ? RFTheme.success : RFTheme.accent)
                        Text(L10n.text("Workout Complete", "Training voltooid"))
                            .font(.largeTitle.bold())
                        Text(session.title)
                            .foregroundStyle(RFTheme.muted)
                    }
                    .frame(maxWidth: .infinity)

                    HStack {
                        StatCard(title: L10n.text("Duration", "Duur"), value: durationString(session.duration), icon: "clock.fill")
                        StatCard(title: L10n.text("Volume", "Volume"), value: "\(Int(AppPreferences.displayVolume(session.totalVolume))) \(AppPreferences.weightLabel)", icon: "chart.bar.fill")
                    }

                    HStack {
                        StatCard(title: L10n.text("Completed sets", "Voltooide sets"), value: "\(completedSets.count)", icon: "checkmark.circle.fill")
                        StatCard(title: L10n.text("PRs", "PR's"), value: "\(prs.count)", icon: "trophy.fill")
                    }

                    if !prs.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.text("New personal records", "Nieuwe persoonlijke records"))
                                .font(.title3.bold())

                            ForEach(Array(prs.enumerated()), id: \.offset) { _, pr in
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .foregroundStyle(RFTheme.accent)
                                    VStack(alignment: .leading) {
                                        Text(pr.0).bold()
                                        Text(
                                            pr.2 > 0
                                            ? "\(AppPreferences.displayWeight(pr.2).formatted(.number.precision(.fractionLength(0...2)))) → \(AppPreferences.displayWeight(pr.1).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)"
                                            : "\(AppPreferences.displayWeight(pr.1).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(RFTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }

                    if !progressionSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.text("Next workout suggestions", "Suggesties voor volgende training"))
                                .font(.title3.bold())

                            ForEach(Array(progressionSuggestions.enumerated()), id: \.offset) { _, suggestion in
                                HStack {
                                    Image(systemName: "arrow.up.right.circle.fill")
                                        .foregroundStyle(RFTheme.success)
                                    VStack(alignment: .leading) {
                                        Text(suggestion.0).bold()
                                        Text(
                                            "\(L10n.text("Consider", "Overweeg")) \(AppPreferences.displayWeight(suggestion.1).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(RFTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Text(L10n.text(
                                "Suggestions are based on hitting the top of the programmed rep range for all working sets.",
                                "Suggesties zijn gebaseerd op het behalen van de bovenkant van de herhalingsrange voor alle werksets."
                            ))
                            .font(.caption)
                            .foregroundStyle(RFTheme.muted)
                        }
                    }

                    if let note = session.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Label(L10n.text("Workout note", "Trainingsnotitie"), systemImage: "note.text")
                                .font(.headline)
                            Text(note)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(RFTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button(L10n.done, action: onDone)
                        .buttonStyle(.borderedProminent)
                        .tint(RFTheme.accent)
                        .frame(maxWidth: .infinity)
                        .controlSize(.large)
                }
                .padding()
            }
            .background(RFTheme.bg)
            .navigationTitle(L10n.text("Summary", "Samenvatting"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func highestRepTarget(_ text: String) -> Int? {
        let numbers = text
            .split(whereSeparator: { !$0.isNumber })
            .compactMap { Int($0) }
        return numbers.max()
    }
}

// MARK: - History

struct HistoryView: View {
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]

    private var completed: [WorkoutSession] {
        sessions.filter { $0.endedAt != nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if completed.isEmpty {
                    EmptyCard(icon: "clock.arrow.circlepath", title: "No workout history", text: "Finished workouts will appear here with sets, volume and duration.")
                        .padding()
                } else {
                    List(completed) { session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(session.title).font(.headline)
                                    Spacer()
                                    Text(session.startedAt, format: .dateTime.day().month(.abbreviated))
                                        .foregroundStyle(.secondary)
                                }
                                Text("\(session.exercises.count) \(L10n.text("exercises", "oefeningen")) • \(Int(AppPreferences.displayVolume(session.totalVolume))) \(AppPreferences.weightLabel) \(L10n.text("volume", "volume")) • \(durationString(session.duration))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(RFTheme.bg)
            .navigationTitle(L10n.history)
        }
    }
}

struct SessionDetailView: View {
    let session: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let note = session.note, !note.isEmpty {
                    Label(note, systemImage: "note.text")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RFTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                HStack {
                    StatCard(title: L10n.text("Duration", "Duur"), value: durationString(session.duration), icon: "clock.fill")
                    StatCard(title: L10n.text("Volume", "Volume"), value: "\(Int(AppPreferences.displayVolume(session.totalVolume))) \(AppPreferences.weightLabel)", icon: "chart.bar.fill")
                }

                ForEach(session.exercises.sorted(by: { $0.order < $1.order })) { log in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(ExerciseCatalog.find(log.exerciseID)?.name ?? "Exercise")
                            .font(.headline)
                            .foregroundStyle(RFTheme.accent)
                        ForEach(log.sets.filter(\.completed).sorted(by: { $0.order < $1.order })) { set in
                            HStack {
                                Text("Set \(set.order + 1)")
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(AppPreferences.displayWeight(set.weightKg).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel) × \(set.reps)")
                                        .bold()
                                    HStack(spacing: 6) {
                                        if set.setType != "working" {
                                            Text(set.setType.capitalized)
                                        }
                                        if let rpe = set.rpe {
                                            Text("RPE \(rpe.formatted(.number.precision(.fractionLength(0...1))))")
                                        }
                                        if let rir = set.rir {
                                            Text("RIR \(rir)")
                                        }
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(RFTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
        .background(RFTheme.bg)
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Exercise library & detail

struct ExerciseLibraryView: View {
    @State private var search = ""
    @State private var muscle = "All"
    @State private var showCustomEditor = false
    @State private var refreshToken = UUID()
    @State private var deleteCandidate: ExerciseDefinition?

    private var filtered: [ExerciseDefinition] {
        _ = refreshToken
        return ExerciseCatalog.all.filter {
            (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)) &&
            (muscle == "All" || $0.muscle == muscle)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { ex in
                NavigationLink {
                    ExerciseDetailView(exercise: ex)
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12).fill(RFTheme.raised)
                            Image(systemName: icon(for: ex.movement))
                                .foregroundStyle(RFTheme.accent)
                                .font(.title2)
                        }
                        .frame(width: 52, height: 52)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(ex.name).font(.headline)
                                if CustomExerciseStore.isCustom(ex.id) {
                                    Text(L10n.text("CUSTOM", "EIGEN"))
                                        .font(.system(size: 8, weight: .bold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(RFTheme.accent.opacity(0.18))
                                        .foregroundStyle(RFTheme.accent)
                                        .clipShape(Capsule())
                                }
                            }

                            Text("\(ex.muscle) • \(ex.equipment)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if CustomExerciseStore.isCustom(ex.id) {
                        Button(role: .destructive) {
                            deleteCandidate = ex
                        } label: {
                            Label(L10n.text("Delete", "Verwijder"), systemImage: "trash")
                        }
                    }
                }
            }
            .id(refreshToken)
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .searchable(text: $search, prompt: L10n.text("Search exercises", "Zoek oefeningen"))
            .navigationTitle(L10n.exercises)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCustomEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(L10n.text("Create custom exercise", "Eigen oefening maken"))
                }
            }
            .safeAreaInset(edge: .top) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["All"] + ExerciseCatalog.muscles, id: \.self) { item in
                            Button(item == "All" ? L10n.text("All", "Alles") : item) {
                                muscle = item
                            }
                            .buttonStyle(.bordered)
                            .tint(muscle == item ? RFTheme.accent : .gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $showCustomEditor, onDismiss: {
                refreshToken = UUID()
            }) {
                CustomExerciseEditorView()
            }
            .confirmationDialog(
                L10n.text("Delete custom exercise?", "Eigen oefening verwijderen?"),
                isPresented: Binding(
                    get: { deleteCandidate != nil },
                    set: { if !$0 { deleteCandidate = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(L10n.text("Delete", "Verwijder"), role: .destructive) {
                    if let candidate = deleteCandidate {
                        CustomExerciseStore.delete(id: candidate.id)
                        deleteCandidate = nil
                        refreshToken = UUID()
                    }
                }
                Button(L10n.text("Cancel", "Annuleren"), role: .cancel) {
                    deleteCandidate = nil
                }
            } message: {
                Text(L10n.text(
                    "Existing workout history will keep its saved exercise ID, but the exercise will no longer appear in the library.",
                    "Bestaande trainingsgeschiedenis behoudt de opgeslagen oefening-ID, maar de oefening verschijnt niet meer in de bibliotheek."
                ))
            }
        }
    }

    private func icon(for movement: String) -> String {
        switch movement {
        case "press": return "arrow.up.circle.fill"
        case "pull": return "arrow.down.circle.fill"
        case "squat": return "figure.strengthtraining.traditional"
        case "hinge": return "figure.flexibility"
        case "cardio": return "figure.run"
        case "core": return "figure.core.training"
        default: return "dumbbell.fill"
        }
    }
}

struct CustomExerciseEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var muscle = "Chest"
    @State private var equipment = "Dumbbell"
    @State private var movement = "press"

    private let muscles = [
        "Chest", "Back", "Shoulders", "Biceps", "Triceps", "Forearms",
        "Quadriceps", "Hamstrings", "Glutes", "Calves", "Core", "Full Body", "Cardio", "Other"
    ]

    private let equipmentOptions = [
        "Barbell", "Dumbbell", "Cable", "Machine", "Bodyweight",
        "Kettlebell", "EZ-Bar", "Trap Bar", "Cardio", "Other"
    ]

    private let movementOptions: [(String, String)] = [
        ("press", "Press"),
        ("pull", "Pull"),
        ("squat", "Squat"),
        ("hinge", "Hinge"),
        ("curl", "Curl"),
        ("extension", "Extension"),
        ("raise", "Raise"),
        ("core", "Core"),
        ("carry", "Carry"),
        ("cardio", "Cardio"),
        ("other", "Other")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.text("Exercise", "Oefening")) {
                    TextField(L10n.text("Exercise name", "Naam oefening"), text: $name)

                    Picker(L10n.text("Muscle", "Spiergroep"), selection: $muscle) {
                        ForEach(muscles, id: \.self) { Text($0).tag($0) }
                    }

                    Picker(L10n.text("Equipment", "Apparatuur"), selection: $equipment) {
                        ForEach(equipmentOptions, id: \.self) { Text($0).tag($0) }
                    }

                    Picker(L10n.text("Movement", "Beweging"), selection: $movement) {
                        ForEach(movementOptions, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }
                }

                Section {
                    Text(L10n.text(
                        "Custom exercises are stored locally and automatically appear in workout and template exercise pickers.",
                        "Eigen oefeningen worden lokaal opgeslagen en verschijnen automatisch in de oefeningkiezers voor trainingen en templates."
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(L10n.text("New Exercise", "Nieuwe oefening"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text("Cancel", "Annuleren")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Save", "Opslaan")) {
                        CustomExerciseStore.add(
                            name: name,
                            muscle: muscle,
                            equipment: equipment,
                            movement: movement
                        )
                        Haptics.success()
                        dismiss()
                    }
                    .bold()
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}


struct ExerciseDetailView: View {
    let exercise: ExerciseDefinition
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var tab = 0

    private var performances: [(date: Date, weight: Double, oneRM: Double, volume: Double)] {
        Metrics.performances(exerciseID: exercise.id, sessions: sessions)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Picker("Section", selection: $tab) {
                    Text("Guide").tag(0)
                    Text("History").tag(1)
                    Text("Charts").tag(2)
                    Text("Records").tag(3)
                }
                .pickerStyle(.segmented)

                if tab == 0 { guide }
                if tab == 1 { history }
                if tab == 2 { charts }
                if tab == 3 { records }
            }
            .padding()
        }
        .background(RFTheme.bg)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var guide: some View {
        ExerciseDemoView(exercise: exercise)

        HStack {
            Label(exercise.muscle, systemImage: "figure.strengthtraining.traditional")
            Spacer()
            Text(exercise.equipment).foregroundStyle(RFTheme.muted)
        }

        Text("How to perform").font(.title3.bold())
        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, step in
            HStack(alignment: .top, spacing: 12) {
                Text("\(index + 1)")
                    .font(.caption.bold())
                    .frame(width: 28, height: 28)
                    .background(RFTheme.accent)
                    .clipShape(Circle())
                Text(step)
            }
        }

        Text("Technique cues").font(.title3.bold()).padding(.top, 4)
        ForEach(exercise.cues, id: \.self) {
            Label($0, systemImage: "checkmark.circle.fill")
                .foregroundStyle(.secondary)
        }

        Text("Training guidance is general information, not medical advice. Stop an exercise if it causes pain and seek qualified help when appropriate.")
            .font(.caption)
            .foregroundStyle(RFTheme.muted)
            .padding(.top, 4)
    }

    @ViewBuilder
    private var history: some View {
        if performances.isEmpty {
            EmptyCard(icon: "clock", title: "No history yet", text: "Complete this exercise in a workout to populate its history.")
        } else {
            ForEach(Array(performances.reversed().enumerated()), id: \.offset) { _, p in
                HStack {
                    VStack(alignment: .leading) {
                        Text(p.date.formatted(date: .abbreviated, time: .omitted)).bold()
                        Text("\(L10n.text("Volume", "Volume")) \(Int(AppPreferences.displayVolume(p.volume))) \(AppPreferences.weightLabel)").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(AppPreferences.displayWeight(p.weight).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)")
                        .font(.headline)
                        .foregroundStyle(RFTheme.accent)
                }
                .padding()
                .background(RFTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    @ViewBuilder
    private var charts: some View {
        if performances.isEmpty {
            EmptyCard(icon: "chart.xyaxis.line", title: "No chart data", text: "Your weight progression will appear after completed sessions.")
        } else {
            Text("Best weight").font(.title3.bold())
            Chart {
                ForEach(Array(performances.enumerated()), id: \.offset) { _, p in
                    LineMark(x: .value("Date", p.date), y: .value("Weight", AppPreferences.displayWeight(p.weight)))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Date", p.date), y: .value("Weight", AppPreferences.displayWeight(p.weight)))
                }
            }
            .frame(height: 220)

            Text("Estimated 1RM").font(.title3.bold()).padding(.top, 8)
            Chart {
                ForEach(Array(performances.enumerated()), id: \.offset) { _, p in
                    AreaMark(x: .value("Date", p.date), y: .value("1RM", AppPreferences.displayWeight(p.oneRM)))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(RFTheme.accent.opacity(0.22))
                    LineMark(x: .value("Date", p.date), y: .value("1RM", AppPreferences.displayWeight(p.oneRM)))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(RFTheme.accent)
                }
            }
            .frame(height: 220)
        }
    }

    @ViewBuilder
    private var records: some View {
        let bestWeight = performances.map(\.weight).max() ?? 0
        let bestRM = performances.map(\.oneRM).max() ?? 0
        let maxVolume = performances.map(\.volume).max() ?? 0

        VStack(spacing: 12) {
            RecordRow(name: L10n.text("Best weight", "Beste gewicht"), value: bestWeight > 0 ? "\(AppPreferences.displayWeight(bestWeight).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)" : "—")
            RecordRow(name: "Estimated 1RM", value: bestRM > 0 ? "\(AppPreferences.displayWeight(bestRM).formatted(.number.precision(.fractionLength(0...1)))) \(AppPreferences.weightLabel)" : "—")
            RecordRow(name: L10n.text("Max session volume", "Max sessievolume"), value: maxVolume > 0 ? "\(Int(AppPreferences.displayVolume(maxVolume))) \(AppPreferences.weightLabel)" : "—")
        }
    }
}

struct ExerciseDemoView: View {
    let exercise: ExerciseDefinition
    @StateObject private var model = ExerciseMediaModel()
    @State private var gender = "Male"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if model.isLoading {
                    ZStack {
                        Color.black
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(RFTheme.accent)
                            Text("Loading HD exercise demo…")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.65))
                        }
                    }
                } else if let media = model.media,
                          let videoURL = selectedVideoURL(media) {
                    LoopingExerciseVideo(url: videoURL)
                } else if let media = model.media,
                          let imageURL = selectedThumbnailURL(media) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            ZStack {
                                Color.black
                                image
                                    .resizable()
                                    .scaledToFit()
                            }
                        case .failure:
                            mediaFallback
                        default:
                            ZStack {
                                Color.black
                                ProgressView().tint(RFTheme.accent)
                            }
                        }
                    }
                } else {
                    mediaFallback
                }
            }
            .frame(height: 255)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.10)))

            if let media = model.media {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(media.matchedName)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                        if let sourceURL = media.sourceURL {
                            Link("Demo source: \(media.sourceName)", destination: sourceURL)
                                .font(.caption2)
                                .foregroundStyle(RFTheme.muted)
                        } else {
                            Text("Demo source: \(media.sourceName)")
                                .font(.caption2)
                                .foregroundStyle(RFTheme.muted)
                        }
                    }

                    Spacer()

                    if media.hasBothGenders {
                        Picker("Model", selection: $gender) {
                            Text("M").tag("Male")
                            Text("F").tag("Female")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 88)
                    }
                }
            }
        }
        .task(id: exercise.id) {
            await model.load(exercise: exercise)
        }
    }

    private func selectedVideoURL(_ media: ExerciseMedia) -> URL? {
        if gender == "Female" {
            return media.femaleVideoURL ?? media.maleVideoURL
        }
        return media.maleVideoURL ?? media.femaleVideoURL
    }

    private func selectedThumbnailURL(_ media: ExerciseMedia) -> URL? {
        if gender == "Female" {
            return media.femaleThumbnailURL ?? media.maleThumbnailURL
        }
        return media.maleThumbnailURL ?? media.femaleThumbnailURL
    }

    private var mediaFallback: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, RFTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 10) {
                Image(systemName: "play.slash.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(RFTheme.muted)
                Text("No HD demo found for this exercise")
                    .font(.headline)
                Text("Form instructions are available below.")
                    .font(.caption)
                    .foregroundStyle(RFTheme.muted)
            }
        }
    }
}

final class PlayerLayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

struct AVPlayerLayerContainer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.backgroundColor = .black
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        return view
    }

    func updateUIView(_ uiView: PlayerLayerView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = .resizeAspect
    }
}

struct LoopingExerciseVideo: View {
    let url: URL
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var isPlaying = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black

            if let player {
                AVPlayerLayerContainer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(RFTheme.accent)
            }

            Button {
                guard let player else { return }
                isPlaying.toggle()
                if isPlaying {
                    player.play()
                } else {
                    player.pause()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(12)
        }
        .task(id: url) {
            player?.pause()

            let item = AVPlayerItem(url: url)
            let queue = AVQueuePlayer()
            queue.isMuted = true
            queue.actionAtItemEnd = .none

            let loop = AVPlayerLooper(player: queue, templateItem: item)
            player = queue
            looper = loop
            isPlaying = true
            queue.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}

// MARK: - Profile

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var editing = false

    private var profile: UserProfile? { profiles.first }
    private var completed: [WorkoutSession] { sessions.filter { $0.endedAt != nil } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if let profile {
                        ZStack {
                            Circle().fill(RFTheme.accent.opacity(0.22)).frame(width: 96, height: 96)
                            Text(String(profile.displayName.prefix(1)).uppercased())
                                .font(.largeTitle.bold())
                                .foregroundStyle(RFTheme.accent)
                        }

                        Text(profile.displayName).font(.title.bold())
                        Text(profile.bio).foregroundStyle(RFTheme.muted)

                        HStack {
                            StatCard(title: L10n.text("Workouts", "Trainingen"), value: "\(completed.count)", icon: "dumbbell.fill")
                            StatCard(title: L10n.text("Total Volume", "Totaal volume"), value: "\(Int(AppPreferences.displayVolume(completed.reduce(0) { $0 + $1.totalVolume }))) \(AppPreferences.weightLabel)", icon: "chart.bar.fill")
                        }

                        HStack {
                            StatCard(title: L10n.text("This week", "Deze week"), value: "\(workoutsThisWeek)", icon: "calendar")
                            StatCard(title: L10n.text("Current streak", "Huidige reeks"), value: "\(currentStreak) \(L10n.text("wk", "wk"))", icon: "flame.fill")
                        }

                        HStack {
                            StatCard(title: L10n.text("Completed sets", "Voltooide sets"), value: "\(totalCompletedSets)", icon: "checkmark.circle.fill")
                            StatCard(title: L10n.text("Avg duration", "Gem. duur"), value: averageDuration, icon: "timer")
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training activity").font(.title3.bold())
                            Chart(activityData, id: \.date) { item in
                                BarMark(
                                    x: .value("Day", item.date, unit: .day),
                                    y: .value("Workouts", item.count)
                                )
                                .foregroundStyle(RFTheme.accent)
                            }
                            .frame(height: 190)
                            .chartYAxis(.hidden)
                        }
                        .padding()
                        .background(RFTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        Button {
                            editing = true
                        } label: {
                            Label("Edit Local Profile", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .background(RFTheme.bg)
            .navigationTitle(L10n.profile)
            .sheet(isPresented: $editing) {
                if let profile {
                    EditProfileView(profile: profile)
                }
            }
        }
    }

    private var workoutsThisWeek: Int {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else { return 0 }
        return completed.filter { $0.startedAt >= start }.count
    }

    private var totalCompletedSets: Int {
        completed.reduce(0) { partial, session in
            partial + session.exercises.flatMap(\.sets).filter(\.completed).count
        }
    }

    private var averageDuration: String {
        guard !completed.isEmpty else { return "00:00" }
        let average = completed.reduce(0.0) { $0 + $1.duration } / Double(completed.count)
        return durationString(average)
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let weeks = Set(completed.compactMap {
            calendar.dateInterval(of: .weekOfYear, for: $0.startedAt)?.start
        })

        guard let currentWeek = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else { return 0 }

        var count = 0
        var cursor = currentWeek
        while weeks.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    private var activityData: [(date: Date, count: Int)] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -27, to: .now)!)
        return (0..<28).map { i in
            let date = cal.date(byAdding: .day, value: i, to: start)!
            let count = completed.filter { cal.isDate($0.startedAt, inSameDayAs: date) }.count
            return (date, count)
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var profile: UserProfile

    var body: some View {
        NavigationStack {
            Form {
                TextField(L10n.text("Display name", "Weergavenaam"), text: $profile.displayName)
                TextField(L10n.text("Bio", "Bio"), text: $profile.bio, axis: .vertical)

                DoneNumberField(
                    value: Binding(
                        get: { AppPreferences.displayWeight(profile.bodyWeightKg) },
                        set: { profile.bodyWeightKg = AppPreferences.storedWeightKg($0) }
                    ),
                    integerOnly: false,
                    placeholder: L10n.text("Body weight", "Lichaamsgewicht")
                )
                .frame(height: 44)
                .overlay(alignment: .trailing) {
                    Text(AppPreferences.weightLabel)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 10)
                }

                DoneNumberField(
                    value: Binding(
                        get: { AppPreferences.displayHeight(profile.heightCm) },
                        set: { profile.heightCm = AppPreferences.storedHeightCm($0) }
                    ),
                    integerOnly: false,
                    placeholder: L10n.text("Height", "Lengte")
                )
                .frame(height: 44)
                .overlay(alignment: .trailing) {
                    Text(AppPreferences.heightLabel)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 10)
                }
            }
            .navigationTitle(L10n.profile)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Save", "Opslaan")) {
                        try? context.save()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - Settings

struct ThemeSelector: View {
    @Binding var selection: String

    private let themes: [(id: String, name: String, bg: Color, card: Color, accent: Color)] = [
        ("forge", "Forge Blue", Color(red: 0.055, green: 0.070, blue: 0.078), Color(red: 0.105, green: 0.135, blue: 0.150), Color(red: 0.18, green: 0.63, blue: 1.0)),
        ("oled", "OLED", .black, Color(red: 0.055, green: 0.055, blue: 0.060), Color(red: 0.18, green: 0.63, blue: 1.0)),
        ("graphite", "Graphite", Color(red: 0.075, green: 0.075, blue: 0.082), Color(red: 0.125, green: 0.125, blue: 0.135), Color(red: 0.18, green: 0.63, blue: 1.0)),
        ("navy", "Navy", Color(red: 0.025, green: 0.055, blue: 0.095), Color(red: 0.070, green: 0.105, blue: 0.155), Color(red: 0.18, green: 0.63, blue: 1.0)),
        ("emerald", "Emerald", Color(red: 0.025, green: 0.080, blue: 0.065), Color(red: 0.055, green: 0.145, blue: 0.110), Color(red: 0.10, green: 0.78, blue: 0.48)),
        ("orange", "Orange", Color(red: 0.105, green: 0.055, blue: 0.025), Color(red: 0.175, green: 0.095, blue: 0.045), Color(red: 1.0, green: 0.48, blue: 0.12)),
        ("purple", "Purple", Color(red: 0.070, green: 0.040, blue: 0.105), Color(red: 0.125, green: 0.075, blue: 0.180), Color(red: 0.63, green: 0.43, blue: 1.0))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.text("Theme", "Thema"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(themes, id: \.id) { theme in
                        Button {
                            selection = theme.id
                            Haptics.light()
                        } label: {
                            VStack(spacing: 7) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(theme.bg)
                                        .frame(width: 72, height: 48)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(theme.card)
                                        .frame(width: 48, height: 28)

                                    Circle()
                                        .fill(theme.accent)
                                        .frame(width: 13, height: 13)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selection == theme.id ? theme.accent : Color.secondary.opacity(0.25), lineWidth: selection == theme.id ? 2.5 : 1)
                                )

                                Text(theme.name)
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PlateCalculatorView: View {
    @State private var targetWeight: Double = AppPreferences.isImperial ? 225 : 100
    @State private var barWeight: Double = AppPreferences.isImperial ? 45 : 20

    private var plates: [Double] {
        AppPreferences.isImperial
            ? [45, 35, 25, 10, 5, 2.5]
            : [25, 20, 15, 10, 5, 2.5, 1.25]
    }

    private var calculation: [(Double, Int)] {
        var remaining = max(0, (targetWeight - barWeight) / 2)
        var result: [(Double, Int)] = []

        for plate in plates {
            let count = Int((remaining + 0.0001) / plate)
            if count > 0 {
                result.append((plate, count))
                remaining -= Double(count) * plate
            }
        }
        return result
    }

    private var actualWeight: Double {
        barWeight + calculation.reduce(0) { $0 + ($1.0 * Double($1.1) * 2) }
    }

    var body: some View {
        Form {
            Section(L10n.text("Target", "Doel")) {
                HStack {
                    Text(L10n.text("Target weight", "Doelgewicht"))
                    Spacer()
                    DoneNumberField(value: $targetWeight, integerOnly: false, placeholder: "0")
                        .frame(width: 100, height: 40)
                    Text(AppPreferences.weightLabel)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text(L10n.text("Bar weight", "Stanggewicht"))
                    Spacer()
                    DoneNumberField(value: $barWeight, integerOnly: false, placeholder: "0")
                        .frame(width: 100, height: 40)
                    Text(AppPreferences.weightLabel)
                        .foregroundStyle(.secondary)
                }
            }

            Section(L10n.text("Load each side", "Belading per kant")) {
                if targetWeight <= barWeight {
                    Text(L10n.text("No plates required.", "Geen schijven nodig."))
                        .foregroundStyle(.secondary)
                } else if calculation.isEmpty {
                    Text(L10n.text("Target cannot be matched with the standard plate set.", "Doel kan niet met de standaard schijven worden gemaakt."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(calculation.enumerated()), id: \.offset) { _, item in
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(RFTheme.accent)
                            Text("\(item.0.formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)")
                            Spacer()
                            Text("× \(item.1)")
                                .bold()
                        }
                    }

                    LabeledContent(
                        L10n.text("Actual loaded weight", "Werkelijk geladen gewicht"),
                        value: "\(actualWeight.formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)"
                    )
                }
            }

            Section {
                Text(L10n.text(
                    "The calculator assumes the same plates are loaded on both sides of the bar.",
                    "De calculator gaat uit van dezelfde schijven aan beide kanten van de stang."
                ))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L10n.text("Plate Calculator", "Schijvencalculator"))
    }
}

struct SettingsView: View {
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var exportSessions: [WorkoutSession]
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) private var exportTemplates: [WorkoutTemplate]

    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("measurementSystem") private var measurementSystem = "metric"
    @AppStorage("appearance") private var appearance = "dark"
    @AppStorage("themePreset") private var themePreset = "forge"
    @AppStorage("textSize") private var textSize = "standard"
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("showPreviousSets") private var showPreviousSets = true
    @AppStorage("keepScreenAwake") private var keepScreenAwake = true
    @AppStorage("defaultSets") private var defaultSets = 3
    @AppStorage("defaultRestSeconds") private var defaultRestSeconds = 90
    @AppStorage("autoRestTimer") private var autoRestTimer = true
    @AppStorage("progressionStepKg") private var progressionStepKg = 2.5

    private var workoutCSV: String {
        var rows = ["date,workout,exercise,set,type,weight_kg,reps,rpe,rir,note"]
        for session in exportSessions where session.endedAt != nil {
            for log in session.exercises.sorted(by: { $0.order < $1.order }) {
                let exerciseName = ExerciseCatalog.find(log.exerciseID)?.name ?? log.exerciseID
                for set in log.sets.sorted(by: { $0.order < $1.order }) where set.completed {
                    let fields = [
                        csv(session.startedAt.ISO8601Format()),
                        csv(session.title),
                        csv(exerciseName),
                        "\(set.order + 1)",
                        csv(set.setType),
                        set.weightKg.formatted(.number.locale(Locale(identifier: "en_US_POSIX")).precision(.fractionLength(0...3))),
                        "\(set.reps)",
                        set.rpe.map { String($0) } ?? "",
                        set.rir.map { String($0) } ?? "",
                        csv(set.note ?? "")
                    ]
                    rows.append(fields.joined(separator: ","))
                }
            }
        }
        return rows.joined(separator: "\n")
    }

    private var templateBackupText: String {
        exportTemplates.map { template in
            let exercises = template.plannedExercises?.map {
                "\($0.name) | \($0.sets) × \($0.reps)\($0.note.map { " | \($0)" } ?? "")"
            } ?? template.exerciseIDs.compactMap { ExerciseCatalog.find($0)?.name }
            return "# \(template.name)\n" + exercises.joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }

    private func csv(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.text("Units & region", "Eenheden & regio")) {
                    Picker(L10n.text("Language", "Taal"), selection: $appLanguage) {
                        Text("English").tag("en")
                        Text("Nederlands").tag("nl")
                    }

                    Picker(L10n.text("Measurement system", "Meetsysteem"), selection: $measurementSystem) {
                        Text(L10n.text("Metric (kg, cm, km)", "Metrisch (kg, cm, km)")).tag("metric")
                        Text(L10n.text("Imperial (lb, in, mi)", "Imperiaal (lb, in, mi)")).tag("imperial")
                    }

                    LabeledContent(L10n.text("Weight", "Gewicht"), value: AppPreferences.weightLabel)
                    LabeledContent(L10n.text("Height", "Lengte"), value: AppPreferences.heightLabel)
                    LabeledContent(L10n.text("Distance", "Afstand"), value: AppPreferences.distanceLabel)
                }

                Section(L10n.text("Appearance", "Weergave")) {
                    Picker(L10n.text("Mode", "Modus"), selection: $appearance) {
                        Text(L10n.text("System", "Systeem")).tag("system")
                        Text(L10n.text("Dark", "Donker")).tag("dark")
                        Text(L10n.text("Light", "Licht")).tag("light")
                    }

                    ThemeSelector(selection: $themePreset)

                    Picker(L10n.text("Text size", "Tekstgrootte"), selection: $textSize) {
                        Text(L10n.text("Compact", "Compact")).tag("compact")
                        Text(L10n.text("Standard", "Standaard")).tag("standard")
                        Text(L10n.text("Large", "Groot")).tag("large")
                        Text(L10n.text("Extra large", "Extra groot")).tag("xlarge")
                    }
                }

                Section(L10n.text("Workout", "Training")) {
                    Stepper(
                        "\(L10n.text("Default sets for new exercises", "Standaard sets voor nieuwe oefeningen")): \(defaultSets)",
                        value: $defaultSets,
                        in: 1...6
                    )

                    Toggle(L10n.text("Show previous sets", "Vorige sets tonen"), isOn: $showPreviousSets)
                    Toggle(L10n.text("Automatic rest timer", "Automatische rusttimer"), isOn: $autoRestTimer)

                    if autoRestTimer {
                        Stepper(
                            "\(L10n.text("Default rest", "Standaard rust")): \(defaultRestSeconds)s",
                            value: $defaultRestSeconds,
                            in: 15...600,
                            step: 15
                        )
                    }

                    Stepper(
                        "\(L10n.text("Progression step", "Progressiestap")): \(AppPreferences.displayWeight(progressionStepKg).formatted(.number.precision(.fractionLength(0...2)))) \(AppPreferences.weightLabel)",
                        value: $progressionStepKg,
                        in: 0.25...20,
                        step: 0.25
                    )

                    Toggle(L10n.text("Keep screen awake during workout", "Scherm aanhouden tijdens training"), isOn: $keepScreenAwake)
                    Toggle(L10n.text("Haptic feedback", "Haptische feedback"), isOn: $hapticsEnabled)
                }

                Section(L10n.text("Tools", "Hulpmiddelen")) {
                    NavigationLink {
                        PlateCalculatorView()
                    } label: {
                        Label(L10n.text("Plate Calculator", "Schijvencalculator"), systemImage: "circle.grid.2x2.fill")
                    }
                }

                Section(L10n.text("Storage & export", "Opslag & export")) {
                    LabeledContent(L10n.text("Workout data", "Trainingsdata"), value: L10n.text("Stored locally", "Lokaal opgeslagen"))

                    ShareLink(item: workoutCSV) {
                        Label(L10n.text("Export workout history", "Trainingsgeschiedenis exporteren"), systemImage: "square.and.arrow.up")
                    }

                    ShareLink(item: templateBackupText) {
                        Label(L10n.text("Export templates", "Templates exporteren"), systemImage: "doc.on.doc")
                    }

                    Text(L10n.text(
                        "Exports are plain text/CSV so you can keep an external copy before reinstalling or changing builds.",
                        "Exports zijn platte tekst/CSV zodat je een externe kopie kunt bewaren vóór herinstalleren of wisselen van build."
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Section(L10n.text("About", "Over")) {
                    LabeledContent("RepForge", value: "0.1.0")
                    LabeledContent(L10n.text("Exercise media", "Oefenmedia"), value: "Free Exercise DB")
                }
            }
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .navigationTitle(L10n.settings)
        }
    }
}

// MARK: - Shared UI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(RFTheme.accent)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(RFTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EmptyCard: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(RFTheme.accent)
            Text(title).font(.headline)
            Text(text).multilineTextAlignment(.center).foregroundStyle(RFTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct RecordRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack {
            Text(name).font(.headline)
            Spacer()
            Text(value).font(.headline).foregroundStyle(RFTheme.accent)
        }
        .padding()
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

func durationString(_ interval: TimeInterval) -> String {
    let total = max(0, Int(interval))
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
}
