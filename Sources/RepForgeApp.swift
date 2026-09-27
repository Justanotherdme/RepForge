import SwiftUI
import SwiftData
import Charts

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

    static var muscles: [String] {
        Array(Set(all.map(\.muscle))).sorted()
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
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet]

    init(exerciseID: String, order: Int, sets: [WorkoutSet] = []) {
        self.id = UUID()
        self.exerciseID = exerciseID
        self.order = order
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
                            Text(best > 0 ? "Best: \(best.formatted(.number.precision(.fractionLength(0...2)))) kg" : "No previous best")
                                .font(.caption)
                                .foregroundStyle(RFTheme.muted)
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
        MovementAnimationView(movement: exercise.movement)

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

struct MovementAnimationView: View {
    let movement: String
    @State private var phase = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(RFTheme.surface)
                Canvas { context, size in
                    let cx = size.width / 2
                    let cy = size.height / 2
                    let delta: CGFloat = phase ? 22 : -6
                    let head = CGPoint(x: cx, y: cy - 65 + (movement == "squat" ? delta * 0.3 : 0))
                    context.fill(Path(ellipseIn: CGRect(x: head.x - 12, y: head.y - 12, width: 24, height: 24)), with: .color(RFTheme.accent))

                    var bodyPath = Path()
                    let shoulder = CGPoint(x: cx, y: head.y + 22)
                    let hip = CGPoint(x: cx + (movement == "hinge" ? delta : 0), y: cy + 20 + (movement == "squat" ? delta : 0))
                    bodyPath.move(to: shoulder)
                    bodyPath.addLine(to: hip)

                    let handY = movement == "press" ? cy - 45 - delta : cy - 5 + (movement == "curl" ? delta : 0)
                    bodyPath.move(to: shoulder)
                    bodyPath.addLine(to: CGPoint(x: cx - 48, y: handY))
                    bodyPath.move(to: shoulder)
                    bodyPath.addLine(to: CGPoint(x: cx + 48, y: handY))

                    let footY = cy + 82
                    bodyPath.move(to: hip)
                    bodyPath.addLine(to: CGPoint(x: cx - 34, y: footY))
                    bodyPath.move(to: hip)
                    bodyPath.addLine(to: CGPoint(x: cx + 34, y: footY))

                    context.stroke(bodyPath, with: .color(.white.opacity(0.92)), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))

                    var bar = Path()
                    bar.move(to: CGPoint(x: cx - 65, y: handY))
                    bar.addLine(to: CGPoint(x: cx + 65, y: handY))
                    context.stroke(bar, with: .color(RFTheme.accent), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                }
                .padding(18)
            }
        }
        .frame(height: 225)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                phase = true
            }
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
