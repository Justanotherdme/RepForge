import SwiftUI
import SwiftData

struct EFSessionLauncher: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) private var templates: [WorkoutTemplate]
    @State private var source = 0
    @State private var query = ""
    let launch: (WorkoutSession) -> Void
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    EFEyebrow(value: "READY WHEN YOU ARE")
                    EFTitle(lines: ["LET'S", "TRAIN."])
                    Text(L10n.text("Your next session is one tap away.",
                                    "Je volgende training begint met één tik."))
                        .font(.subheadline).foregroundStyle(EF.faint)
                    if let running = sessions.first(where: { $0.endedAt == nil }) {
                        EFAction(title: L10n.text("RESUME ACTIVE WORKOUT", "HERVAT TRAINING"),
                                 symbol: "play.fill") {
                            launch(running)
                            dismiss()
                        }
                    }
                    EFAction(title: L10n.text("START EMPTY WORKOUT", "START LEGE TRAINING"),
                             symbol: "plus", orange: true) {
                        let session = WorkoutSession(
                            title: L10n.text("New workout", "Nieuwe training"),
                            gymID: gymID
                        )
                        context.insert(session)
                        try? context.save()
                        launch(session)
                        dismiss()
                    }
                    Picker("Source", selection: $source) {
                        Text(L10n.text("My routines", "Mijn schema's")).tag(0)
                        Text(L10n.text("Workout library", "Workouts")).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 14)
                    TextField(L10n.text("Search", "Zoek"), text: $query)
                        .padding(.vertical, 14)
                        .overlay(alignment: .bottom) { EFRule() }

                    if source == 0 {
                        ForEach(templates.filter {
                            query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
                        }) { template in
                            Button { startTemplate(template) } label: {
                                EFNumberRow(order: 1, title: template.name,
                                            detail: "\(template.exerciseIDs.count) MOVEMENTS")
                            }
                            .buttonStyle(.plain)
                            EFRule()
                        }
                    } else {
                        ForEach(Array(CoachWorkoutLibrary.all.filter {
                            query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
                        }.enumerated()), id: \.element.id) { i, item in
                            Button {
                                if let session = CoachWorkoutActions.start(
                                    name: item.name, plan: item.exercises,
                                    gymID: gymID, in: context
                                ) {
                                    launch(session)
                                    dismiss()
                                }
                            } label: {
                                EFNumberRow(order: i + 1, title: item.name,
                                            detail: "~\(item.estimatedMinutes) MIN • \(item.category)")
                            }
                            .buttonStyle(.plain)
                            EFRule()
                        }
                    }
                }
                .padding(24)
            }
            .background(EF.paper)
            .navigationTitle(L10n.text("Start training", "Start training"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Close", "Sluiten")) { dismiss() }
                        .foregroundStyle(EF.cobalt)
                }
            }
        }
        .environment(\.colorScheme, .light)
    }

    private func startTemplate(_ template: WorkoutTemplate) {
        let plan: [ExerciseLog]
        if let saved = template.plannedExercises, !saved.isEmpty {
            plan = saved.enumerated().compactMap { index, item in
                guard let def = ExerciseCatalog.findByName(item.name) else { return nil }
                return ExerciseLog(
                    exerciseID: def.id, order: index,
                    targetReps: item.reps, coachingNote: item.note,
                    supersetGroup: item.superset,
                    sets: (0..<max(1, item.sets)).map { WorkoutSet(order: $0) }
                )
            }
        } else {
            plan = template.exerciseIDs.enumerated().map { index, id in
                ExerciseLog(exerciseID: id, order: index,
                            sets: (0..<AppPreferences.defaultSets).map { WorkoutSet(order: $0) })
            }
        }
        let session = WorkoutSession(title: template.name, exercises: plan, gymID: gymID)
        context.insert(session)
        try? context.save()
        launch(session)
        dismiss()
    }
}

struct EFAppShell: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var presentedSession: WorkoutSession?
    @State private var pendingSession: WorkoutSession?
    @State private var showStart = false
    @State private var showProfile = false
    @State private var keyboardVisible = false
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID

    var body: some View {
        ZStack {
            switch selectedTab {
            case 1:
                EFPlans(launch: startPlan)
            case 2:
                EFIndex()
            case 3:
                EFAtlas()
            default:
                EFHome(
                    start: startOrResume,
                    profile: { showProfile = true },
                    openPlans: { selectedTab = 1 },
                    selectPlan: startPlan
                )
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !keyboardVisible {
                EFNavigation(selected: $selectedTab, start: startOrResume, dark: selectedTab == 3)
            }
        }
        .sheet(isPresented: $showStart, onDismiss: {
            if let pendingSession {
                presentedSession = pendingSession
                self.pendingSession = nil
            }
        }) {
            EFSessionLauncher { session in
                pendingSession = session
            }
        }
        .sheet(isPresented: $showProfile) { EFProfile() }
        .fullScreenCover(item: $presentedSession) { session in
            EFWorkout(session: session)
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillShowNotification
        )) { _ in keyboardVisible = true }
        .onReceive(NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillHideNotification
        )) { _ in keyboardVisible = false }
    }

    private func startOrResume() {
        if let running = sessions.first(where: { $0.endedAt == nil }) {
            presentedSession = running
        } else {
            showStart = true
        }
    }
    private func startPlan(_ item: CoachWorkout) {
        if let session = CoachWorkoutActions.start(
            name: item.name, plan: item.exercises, gymID: gymID, in: context
        ) {
            presentedSession = session
        }
    }
}
