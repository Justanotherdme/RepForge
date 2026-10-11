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

    @State private var showTemplateEditor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    EFPageHeading(
                        title: L10n.text("Start a workout", "Start een training"),
                        subtitle: L10n.text("Choose how you want to train today.",
                                            "Kies hoe je vandaag wilt trainen.")
                    )
                    if let running = sessions.first(where: { $0.endedAt == nil }) {
                        Button {
                            launch(running)
                            dismiss()
                        } label: {
                            EFLinkTile(symbol: "play.circle.fill",
                                       title: L10n.text("Resume active workout", "Hervat actieve training"),
                                       subtitle: running.title)
                        }
                        .buttonStyle(.plain)
                    }
                    EFEyebrow(value: "START SOMETHING NEW").padding(.top, 9)
                    Button { source = 0 } label: {
                        EFLinkTile(symbol: "rectangle.stack",
                                   title: L10n.text("Choose a template", "Kies een template"),
                                   subtitle: "Start from one of your saved routines")
                    }
                    .buttonStyle(.plain)
                    Button { showTemplateEditor = true } label: {
                        EFLinkTile(symbol: "square.and.pencil",
                                   title: L10n.text("Create new template", "Nieuw template maken"),
                                   subtitle: "Build, customize and save a workout")
                    }
                    .buttonStyle(.plain)
                    Button { startEmpty() } label: {
                        EFLinkTile(symbol: "bolt.fill",
                                   title: L10n.text("Quick workout", "Snelle training"),
                                   subtitle: "Start empty and add exercises as you go")
                    }
                    .buttonStyle(.plain)
                    HStack {
                        EFSection(title: "TEMPLATES")
                        Spacer(minLength: 0)
                        Button { showTemplateEditor = true } label: {
                            Label("Create", systemImage: "plus")
                                .font(.caption.bold()).foregroundStyle(EF.cobalt)
                        }
                    }
                    .padding(.top, 12)
                    Picker("Workout source", selection: $source) {
                        Text(L10n.text("My templates", "Mijn templates")).tag(0)
                        Text(L10n.text("Workout library", "Workouts")).tag(1)
                    }
                    .pickerStyle(.segmented)
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(EF.faint)
                        TextField(L10n.text("Search templates", "Zoek templates"), text: $query)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(14)
                    .background(EF.field, in: RoundedRectangle(cornerRadius: 13))
                    if source == 0 {
                        let displayed = templates.filter {
                            query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
                        }
                        if displayed.isEmpty {
                            Text(L10n.text("No saved templates yet. Create one to reuse your workout.",
                                           "Nog geen templates. Maak er een om trainingen te herhalen."))
                                .font(.subheadline).foregroundStyle(EF.faint)
                                .padding(.vertical, 14)
                        }
                        ForEach(displayed) { template in
                            Button { startTemplate(template) } label: {
                                EFLinkTile(symbol: "list.bullet.rectangle",
                                           title: template.name,
                                           subtitle: "\(template.exerciseIDs.count) exercises • Tap to start")
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ForEach(CoachWorkoutLibrary.all.filter {
                            query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
                        }) { item in
                            Button {
                                if let session = CoachWorkoutActions.start(
                                    name: item.name, plan: item.exercises,
                                    gymID: gymID, in: context
                                ) {
                                    launch(session)
                                    dismiss()
                                }
                            } label: {
                                EFLinkTile(symbol: "dumbbell.fill",
                                           title: item.name,
                                           subtitle: "~\(item.estimatedMinutes) min • \(item.category)")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 70)
            }
            .background(EF.paper)
            .navigationTitle(L10n.text("Start training", "Start training"))
            .navigationBarTitleDisplayMode(.inline)
            .tint(EF.cobalt)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Close", "Sluiten")) { dismiss() }
                }
            }
            .sheet(isPresented: $showTemplateEditor) { TemplateEditorView() }
        }
    }

    private func startEmpty() {
        let session = WorkoutSession(
            title: L10n.text("New workout", "Nieuwe training"),
            gymID: gymID
        )
        context.insert(session)
        try? context.save()
        launch(session)
        dismiss()
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
                EFNavigation(selected: $selectedTab, start: startOrResume, dark: false)
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
        // Starting is always an explicit choice. Never auto-resume Monday or
        // any other unfinished session when tapping the global + action.
        showStart = true
    }
    private func startPlan(_ item: CoachWorkout) {
        if let session = CoachWorkoutActions.start(
            name: item.name, plan: item.exercises, gymID: gymID, in: context
        ) {
            presentedSession = session
        }
    }
}
