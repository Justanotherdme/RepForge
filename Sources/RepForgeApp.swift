import SwiftUI
import SwiftData
import Charts
import AVKit

// MARK: - Theme

enum RFTheme {
    static let bg = Color(red: 0.055, green: 0.070, blue: 0.078)
    static let surface = Color(red: 0.105, green: 0.135, blue: 0.150)
    static let raised = Color(red: 0.140, green: 0.175, blue: 0.190)
    static let field = Color(red: 0.075, green: 0.095, blue: 0.105)
    static let accent = Color(red: 0.18, green: 0.63, blue: 1.0)
    static let success = Color(red: 0.16, green: 0.78, blue: 0.43)
    static let muted = Color.white.opacity(0.52)
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
    static let all: [ExerciseDefinition] = {
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

// MARK: - Built-in 3-week program

struct ProgramExercise: Hashable {
    let name: String
    let sets: Int
    let reps: String
    let note: String?
    let superset: String?

    init(_ name: String, _ sets: Int, _ reps: String, note: String? = nil, superset: String? = nil) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.note = note
        self.superset = superset
    }
}

struct ProgramDay: Identifiable, Hashable {
    let id: String
    let week: Int
    let day: String
    let partner: String
    let focus: String
    let exercises: [ProgramExercise]

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

// MARK: - Persistence

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var exerciseIDsCSV: String
    var createdAt: Date

    init(name: String, exerciseIDs: [String]) {
        self.id = UUID()
        self.name = name
        self.exerciseIDsCSV = exerciseIDs.joined(separator: ",")
        self.createdAt = .now
    }

    var exerciseIDs: [String] {
        get { exerciseIDsCSV.split(separator: ",").map(String.init).filter { !$0.isEmpty } }
        set { exerciseIDsCSV = newValue.joined(separator: ",") }
    }
}

@Model
final class WorkoutSession {
    var id: UUID
    var title: String
    var startedAt: Date
    var endedAt: Date?
    @Relationship(deleteRule: .cascade)
    var exercises: [ExerciseLog]

    init(title: String, startedAt: Date = .now, exercises: [ExerciseLog] = []) {
        self.id = UUID()
        self.title = title
        self.startedAt = startedAt
        self.exercises = exercises
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
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet]

    init(
        exerciseID: String,
        order: Int,
        targetReps: String? = nil,
        coachingNote: String? = nil,
        supersetGroup: String? = nil,
        sets: [WorkoutSet] = []
    ) {
        self.id = UUID()
        self.exerciseID = exerciseID
        self.order = order
        self.targetReps = targetReps
        self.coachingNote = coachingNote
        self.supersetGroup = supersetGroup
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

    init(order: Int, weightKg: Double = 0, reps: Int = 0, completed: Bool = false) {
        self.id = UUID()
        self.order = order
        self.weightKg = weightKg
        self.reps = reps
        self.completed = completed
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
                .filter(\.completed)
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
        return log.sets.filter(\.completed).sorted { $0.order < $1.order }.map { ($0.weightKg, $0.reps) }
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

// MARK: - Licensed exercise media (wger)

struct WgerExerciseResponse: Decodable {
    let results: [WgerExercise]
}

struct WgerExercise: Decodable {
    let translations: [WgerTranslation]
    let videos: [WgerVideo]
    let images: [WgerImage]
}

struct WgerTranslation: Decodable {
    let name: String
}

struct WgerVideo: Decodable, Identifiable {
    let id: Int
    let video: String
    let isMain: Bool?
    let licenseTitle: String?
    let licenseObjectURL: String?
    let licenseAuthor: String?
    let licenseAuthorURL: String?

    enum CodingKeys: String, CodingKey {
        case id, video
        case isMain = "is_main"
        case licenseTitle = "license_title"
        case licenseObjectURL = "license_object_url"
        case licenseAuthor = "license_author"
        case licenseAuthorURL = "license_author_url"
    }
}

struct WgerImage: Decodable, Identifiable {
    let id: Int
    let image: String
    let isMain: Bool?
    let licenseTitle: String?
    let licenseObjectURL: String?
    let licenseAuthor: String?
    let licenseAuthorURL: String?

    enum CodingKeys: String, CodingKey {
        case id, image
        case isMain = "is_main"
        case licenseTitle = "license_title"
        case licenseObjectURL = "license_object_url"
        case licenseAuthor = "license_author"
        case licenseAuthorURL = "license_author_url"
    }
}

struct LicensedExerciseMedia {
    let videoURL: URL?
    let imageURL: URL?
    let licenseTitle: String?
    let licenseURL: URL?
    let author: String?
    let authorURL: URL?
    let matchedName: String?
}

enum WgerMediaService {
    static func media(for exercise: ExerciseDefinition) async throws -> LicensedExerciseMedia? {
        var components = URLComponents(string: "https://wger.de/api/v2/exerciseinfo/")!
        components.queryItems = [
            URLQueryItem(name: "name__search", value: searchTerm(for: exercise)),
            URLQueryItem(name: "language__code", value: "en"),
            URLQueryItem(name: "limit", value: "8")
        ]

        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            return nil
        }

        let decoded = try JSONDecoder().decode(WgerExerciseResponse.self, from: data)

        let candidates = decoded.results.sorted { lhs, rhs in
            score(lhs, exercise: exercise) > score(rhs, exercise: exercise)
        }

        guard let result = candidates.first(where: { !$0.videos.isEmpty || !$0.images.isEmpty }) else {
            return nil
        }

        let video = result.videos.first(where: { $0.isMain == true }) ?? result.videos.first
        let image = result.images.first(where: { $0.isMain == true }) ?? result.images.first
        let mediaLicenseTitle = video?.licenseTitle ?? image?.licenseTitle
        let mediaLicenseURL = URL(string: video?.licenseObjectURL ?? image?.licenseObjectURL ?? "")
        let mediaAuthor = video?.licenseAuthor ?? image?.licenseAuthor
        let mediaAuthorURL = URL(string: video?.licenseAuthorURL ?? image?.licenseAuthorURL ?? "")
        let matchedName = result.translations.first?.name

        return LicensedExerciseMedia(
            videoURL: URL(string: video?.video ?? ""),
            imageURL: URL(string: image?.image ?? ""),
            licenseTitle: mediaLicenseTitle,
            licenseURL: mediaLicenseURL,
            author: mediaAuthor,
            authorURL: mediaAuthorURL,
            matchedName: matchedName
        )
    }

    private static func searchTerm(for exercise: ExerciseDefinition) -> String {
        let explicit: [String: String] = [
            "Barbell Flat Bench Press": "bench press",
            "Bench Press (Barbell)": "bench press",
            "Bench Press (Dumbbell)": "dumbbell bench press",
            "Bench Press (Smith Machine)": "smith machine bench press",
            "Chest Supported Machine Row": "chest supported row",
            "Chest Supported Dumbbell Row": "chest supported dumbbell row",
            "Dumbbell Shoulder Press (Seated)": "dumbbell shoulder press",
            "Wide Grip Lat Pulldown": "lat pulldown",
            "Lat Pulldown - Wide Grip": "lat pulldown",
            "Neutral Grip Lat Pulldown": "lat pulldown",
            "Seated Cable Row (V-Bar)": "seated cable row",
            "Cable Face Pull": "face pull",
            "Captain's Chair Leg Raise": "leg raise",
            "Lying Floor Leg Raises": "leg raise",
            "Dumbbell Romanian Deadlift": "romanian deadlift",
            "Romanian Deadlift (Barbell)": "romanian deadlift",
            "Trap Bar Deadlift": "deadlift",
            "Standing Barbell Overhead Press (Military Press)": "overhead press",
            "Arnold Dumbbell Press": "arnold press",
            "Cable Triceps Rope Pushdown": "triceps pushdown",
            "Cable Triceps Straight Bar Pushdown": "triceps pushdown",
            "Cable Overhead Triceps Rope Extension": "triceps extension",
            "Lying Dumbbell Skull Crushers": "skull crusher",
            "Lean-Away Cable Lateral Raise": "lateral raise",
            "Reverse Pec Deck Machine": "reverse fly",
            "Hack Squat Machine": "hack squat"
        ]
        if let term = explicit[exercise.name] { return term }

        return exercise.name
            .replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func score(_ result: WgerExercise, exercise: ExerciseDefinition) -> Int {
        let wanted = searchTerm(for: exercise).lowercased()
        let names = result.translations.map { $0.name.lowercased() }
        var value = result.videos.isEmpty ? 0 : 100
        if names.contains(wanted) { value += 60 }
        if names.contains(where: { $0.contains(wanted) || wanted.contains($0) }) { value += 30 }
        if result.videos.contains(where: { $0.isMain == true }) { value += 10 }
        return value
    }
}

@MainActor
final class ExerciseMediaModel: ObservableObject {
    @Published var media: LicensedExerciseMedia?
    @Published var isLoading = false
    @Published var loadFailed = false

    func load(exercise: ExerciseDefinition) async {
        isLoading = true
        loadFailed = false
        defer { isLoading = false }

        do {
            media = try await WgerMediaService.media(for: exercise)
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
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @State private var tab = 2

    var body: some View {
        TabView(selection: $tab) {
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(0)
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
                .tag(1)
            StartWorkoutView()
                .tabItem { Label("Workout", systemImage: "plus.circle.fill") }
                .tag(2)
            ExerciseLibraryView()
                .tabItem { Label("Exercises", systemImage: "dumbbell.fill") }
                .tag(3)
        }
        .tint(RFTheme.accent)
        .task {
            if profiles.isEmpty {
                context.insert(UserProfile())
                try? context.save()
            }
        }
    }
}

// MARK: - Workout home

struct StartWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) private var templates: [WorkoutTemplate]
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var showTemplateEditor = false
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
                                TemplateCard(template: template) {
                                    activeSession = createSession(title: template.name, exerciseIDs: template.exerciseIDs)
                                } onDelete: {
                                    context.delete(template)
                                    try? context.save()
                                }
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

                        ForEach(BuiltInProgram.week(selectedProgramWeek)) { day in
                            ProgramDayCard(day: day) {
                                activeSession = createSession(day: day)
                            }
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
            .navigationTitle("Start Workout")
            .sheet(isPresented: $showTemplateEditor) {
                TemplateEditorView()
            }
            .fullScreenCover(item: $activeSession) { session in
                ActiveWorkoutView(session: session)
            }
        }
    }

    private func createSession(title: String, exerciseIDs: [String]) -> WorkoutSession {
        let logs = exerciseIDs.enumerated().map { index, id in
            ExerciseLog(
                exerciseID: id,
                order: index,
                sets: (0..<3).map { WorkoutSet(order: $0) }
            )
        }
        let session = WorkoutSession(title: title, exercises: logs)
        context.insert(session)
        try? context.save()
        return session
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
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(day.day).font(.headline)
                    Text(day.focus).font(.subheadline).foregroundStyle(RFTheme.accent)
                    Text(day.partner.capitalized).font(.caption).foregroundStyle(RFTheme.muted)
                }
                Spacer()
                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .tint(RFTheme.accent)
            }

            ForEach(Array(day.exercises.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if let group = item.superset {
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
        }
        .padding()
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08)))
    }
}

struct TemplateCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundStyle(RFTheme.accent)
                Spacer()
                Menu {
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

            Text(template.exerciseIDs.compactMap(ExerciseCatalog.find).map(\.name).joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(RFTheme.muted)
                .lineLimit(4)

            Button("Start", action: onStart)
                .buttonStyle(.borderedProminent)
                .tint(RFTheme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
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
    @State private var name = "New Template"
    @State private var selectedIDs: [String] = []
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            List {
                Section("Template") {
                    TextField("Name", text: $name)
                }

                Section("Exercises") {
                    ForEach(Array(selectedIDs.enumerated()), id: \.element) { index, id in
                        if let ex = ExerciseCatalog.find(id) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ex.name).font(.headline)
                                    Text(ex.muscle).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(index + 1)").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { selectedIDs.remove(atOffsets: $0) }

                    Button {
                        showPicker = true
                    } label: {
                        Label("Add Exercises", systemImage: "plus")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .navigationTitle("New Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        context.insert(WorkoutTemplate(name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Workout" : name, exerciseIDs: selectedIDs))
                        try? context.save()
                        dismiss()
                    }
                    .bold()
                    .disabled(selectedIDs.isEmpty)
                }
            }
            .sheet(isPresented: $showPicker) {
                ExercisePickerView(selectedIDs: $selectedIDs)
            }
        }
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
            .searchable(text: $search)
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .navigationTitle("Exercises")
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
            .toolbar {
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.title).font(.largeTitle.bold())
                            TimelineView(.periodic(from: .now, by: 1)) { _ in
                                Label(durationString(session.duration), systemImage: "clock")
                                    .foregroundStyle(RFTheme.muted)
                            }
                        }
                        Spacer()
                        Button("Finish") { showFinishConfirm = true }
                            .buttonStyle(.borderedProminent)
                            .tint(RFTheme.success)
                            .font(.headline)
                    }

                    if session.exercises.isEmpty {
                        EmptyCard(icon: "dumbbell", title: "No exercises yet", text: "Add an exercise to begin logging sets.")
                    }

                    ForEach(session.exercises.sorted(by: { $0.order < $1.order })) { log in
                        WorkoutExerciseBlock(log: log, sessions: allSessions)
                    }

                    Button {
                        pickerIDs = []
                        showExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                    }
                    .buttonStyle(.bordered)
                    .tint(RFTheme.accent)
                }
                .padding()
            }
            .background(RFTheme.bg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .confirmationDialog("Finish this workout?", isPresented: $showFinishConfirm) {
                Button("Finish Workout") {
                    session.endedAt = .now
                    try? context.save()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Completed sets, weights and reps will be added to your history.")
            }
            .sheet(isPresented: $showExercisePicker, onDismiss: addPickedExercises) {
                ExercisePickerView(selectedIDs: $pickerIDs)
            }
        }
    }

    private func addPickedExercises() {
        guard !pickerIDs.isEmpty else { return }
        let existing = Set(session.exercises.map(\.exerciseID))
        var nextOrder = (session.exercises.map(\.order).max() ?? -1) + 1
        for id in pickerIDs where !existing.contains(id) {
            session.exercises.append(ExerciseLog(
                exerciseID: id,
                order: nextOrder,
                sets: (0..<3).map { WorkoutSet(order: $0) }
            ))
            nextOrder += 1
        }
        pickerIDs = []
        try? context.save()
    }
}

struct WorkoutExerciseBlock: View {
    @Environment(\.modelContext) private var context
    @Bindable var log: ExerciseLog
    let sessions: [WorkoutSession]

    private var exercise: ExerciseDefinition? { ExerciseCatalog.find(log.exerciseID) }
    private var previous: [(Double, Int)] { Metrics.previousSets(exerciseID: log.exerciseID, sessions: sessions) }
    private var best: Double { Metrics.personalBest(exerciseID: log.exerciseID, sessions: sessions) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let ex = exercise {
                NavigationLink {
                    ExerciseDetailView(exercise: ex)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ex.name)
                                .font(.title3.bold())
                                .foregroundStyle(RFTheme.accent)
                            HStack(spacing: 8) {
                                Text(best > 0 ? "Best: \(best.formatted(.number.precision(.fractionLength(0...2)))) kg" : "No previous best")
                                if let target = log.targetReps {
                                    Text("Target \(target) reps")
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
                            if let group = log.supersetGroup {
                                Label("Superset \(group)", systemImage: "link")
                                    .font(.caption.bold())
                                    .foregroundStyle(RFTheme.accent)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(RFTheme.muted)
                    }
                }
            }

            HStack {
                Text("Set").frame(width: 42, alignment: .leading)
                Text("Previous").frame(maxWidth: .infinity)
                Text("kg").frame(width: 82)
                Text("Reps").frame(width: 66)
                Image(systemName: "checkmark").frame(width: 34)
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)

            ForEach(log.sets.sorted(by: { $0.order < $1.order })) { set in
                WorkoutSetRow(
                    set: set,
                    previous: previous.indices.contains(set.order) ? previous[set.order] : nil
                )
            }

            Button {
                let next = (log.sets.map(\.order).max() ?? -1) + 1
                log.sets.append(WorkoutSet(order: next))
                try? context.save()
            } label: {
                Label("Add Set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(RFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct WorkoutSetRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var set: WorkoutSet
    let previous: (Double, Int)?

    var body: some View {
        HStack(spacing: 8) {
            Text("\(set.order + 1)")
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(RFTheme.field)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(previous.map { "\($0.0.formatted(.number.precision(.fractionLength(0...2)))) × \($0.1)" } ?? "—")
                .font(.caption)
                .foregroundStyle(RFTheme.muted)
                .frame(maxWidth: .infinity)

            TextField("0", value: $set.weightKg, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: 82, height: 42)
                .background(RFTheme.field)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 66, height: 42)
                .background(RFTheme.field)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                set.completed.toggle()
                set.completedAt = set.completed ? .now : nil
                try? context.save()
            } label: {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.completed ? RFTheme.success : RFTheme.muted)
            }
            .frame(width: 34)
        }
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
                                Text("\(session.exercises.count) exercises • \(Int(session.totalVolume)) kg volume • \(durationString(session.duration))")
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
            .navigationTitle("History")
        }
    }
}

struct SessionDetailView: View {
    let session: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    StatCard(title: "Duration", value: durationString(session.duration), icon: "clock.fill")
                    StatCard(title: "Volume", value: "\(Int(session.totalVolume)) kg", icon: "chart.bar.fill")
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
                                Text("\(set.weightKg.formatted(.number.precision(.fractionLength(0...2)))) kg × \(set.reps)")
                                    .bold()
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

    private var filtered: [ExerciseDefinition] {
        ExerciseCatalog.all.filter {
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
                            Text(ex.name).font(.headline)
                            Text("\(ex.muscle) • \(ex.equipment)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(RFTheme.bg)
            .searchable(text: $search)
            .navigationTitle("Exercises")
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
                    .padding(.vertical, 6)
                }
                .background(.ultraThinMaterial)
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
        default: return "dumbbell.fill"
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
                        Text("Volume \(Int(p.volume)) kg").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(p.weight.formatted(.number.precision(.fractionLength(0...2)))) kg")
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
                    LineMark(x: .value("Date", p.date), y: .value("Weight", p.weight))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Date", p.date), y: .value("Weight", p.weight))
                }
            }
            .frame(height: 220)

            Text("Estimated 1RM").font(.title3.bold()).padding(.top, 8)
            Chart {
                ForEach(Array(performances.enumerated()), id: \.offset) { _, p in
                    AreaMark(x: .value("Date", p.date), y: .value("1RM", p.oneRM))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(RFTheme.accent.opacity(0.22))
                    LineMark(x: .value("Date", p.date), y: .value("1RM", p.oneRM))
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
            RecordRow(name: "Best weight", value: bestWeight > 0 ? "\(bestWeight.formatted(.number.precision(.fractionLength(0...2)))) kg" : "—")
            RecordRow(name: "Estimated 1RM", value: bestRM > 0 ? "\(bestRM.formatted(.number.precision(.fractionLength(0...1)))) kg" : "—")
            RecordRow(name: "Max session volume", value: maxVolume > 0 ? "\(Int(maxVolume)) kg" : "—")
        }
    }
}

struct ExerciseDemoView: View {
    let exercise: ExerciseDefinition
    @StateObject private var model = ExerciseMediaModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if model.isLoading {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.95))
                        ProgressView("Finding exercise demo…")
                            .tint(RFTheme.accent)
                            .foregroundStyle(Color.black.opacity(0.7))
                    }
                } else if let media = model.media, let videoURL = media.videoURL {
                    LoopingExerciseVideo(url: videoURL)
                } else if let media = model.media, let imageURL = media.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                                .background(Color.white)
                        case .failure:
                            mediaFallback
                        default:
                            ZStack {
                                Color.white
                                ProgressView().tint(RFTheme.accent)
                            }
                        }
                    }
                } else {
                    mediaFallback
                }
            }
            .frame(height: 270)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.12)))

            if let media = model.media {
                HStack(spacing: 6) {
                    Image(systemName: "play.rectangle.fill")
                    Text(media.matchedName.map { "Demo: \($0)" } ?? "Exercise demonstration")
                    Spacer()
                    Text("wger")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .foregroundStyle(RFTheme.muted)

                if media.licenseTitle != nil || media.author != nil {
                    HStack(spacing: 4) {
                        Text("Media")
                        if let author = media.author {
                            if let url = media.authorURL {
                                Link(author, destination: url)
                            } else {
                                Text("© \(author)")
                            }
                        }
                        if let license = media.licenseTitle {
                            Text("•")
                            if let url = media.licenseURL {
                                Link(license, destination: url)
                            } else {
                                Text(license)
                            }
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(RFTheme.muted)
                }
            }
        }
        .task(id: exercise.id) {
            await model.load(exercise: exercise)
        }
    }

    private var mediaFallback: some View {
        ZStack {
            LinearGradient(
                colors: [RFTheme.surface, RFTheme.raised],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 54, weight: .medium))
                    .foregroundStyle(RFTheme.accent)
                Text("No licensed demo found")
                    .font(.headline)
                Text("Instructions and form cues are available below.")
                    .font(.caption)
                    .foregroundStyle(RFTheme.muted)
            }
        }
    }
}

struct LoopingExerciseVideo: View {
    let url: URL
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var isPlaying = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.white

            if let player {
                VideoPlayer(player: player)
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
            } else {
                ProgressView()
                    .tint(RFTheme.accent)
            }

            Button {
                guard let player else { return }
                isPlaying.toggle()
                isPlaying ? player.play() : player.pause()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.headline)
                    .foregroundStyle(RFTheme.accent)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(12)
        }
        .task(id: url) {
            let item = AVPlayerItem(url: url)
            let queue = AVQueuePlayer()
            queue.isMuted = true
            let loop = AVPlayerLooper(player: queue, templateItem: item)
            player = queue
            looper = loop
            queue.play()
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
                            StatCard(title: "Workouts", value: "\(completed.count)", icon: "dumbbell.fill")
                            StatCard(title: "Total Volume", value: "\(Int(completed.reduce(0) { $0 + $1.totalVolume })) kg", icon: "chart.bar.fill")
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
            .navigationTitle("Profile")
            .sheet(isPresented: $editing) {
                if let profile {
                    EditProfileView(profile: profile)
                }
            }
        }
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
                TextField("Display name", text: $profile.displayName)
                TextField("Bio", text: $profile.bio, axis: .vertical)
                TextField("Body weight (kg)", value: $profile.bodyWeightKg, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Height (cm)", value: $profile.heightCm, format: .number)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? context.save()
                        dismiss()
                    }
                    .bold()
                }
            }
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
