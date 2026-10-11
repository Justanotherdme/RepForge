import SwiftUI
import SwiftData

struct EFPlans: View {
    let launch: (CoachWorkout) -> Void
    @Environment(\.modelContext) private var context
    @State private var category = "All"
    @State private var query = ""
    @State private var section = 0
    @State private var showThreeWeeks = false
    @State private var showRoutines = false
    @State private var savedName: String?
    @State private var scheduled: ScheduledWorkoutRecord?
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID
    private let categories = ["All", "Strength", "Muscle growth", "Express", "Full body", "Targeted", "Conditioning"]
    private var filtered: [CoachWorkout] {
        CoachWorkoutLibrary.all.filter {
            (category == "All" || $0.category == category) &&
            (query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) ||
             $0.focus.localizedCaseInsensitiveContains(query))
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    EFPageHeading(title: L10n.text("Training Plans", "Trainingsschema's"),
                                  subtitle: "Structured training, ready to log.")
                    searchField
                    sectionPicker
                    if section == 2 {
                        threeWeekPanel
                    } else {
                        if section == 0 { featuredCard }
                        if section == 1 { routinesPanel }
                        workoutLibrary
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 26)
                .padding(.bottom, 115)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(EF.paper)
            .toolbar(.hidden, for: .navigationBar)
            .tint(EF.cobalt)
            .sheet(isPresented: $showThreeWeeks) { TrainingHubView() }
            .sheet(isPresented: $showRoutines) { StartWorkoutView() }
            .sheet(item: $scheduled) { record in
                ScheduleWorkoutSheet(seed: record) { updated in
                    WorkoutScheduleStore.update(updated)
                }
            }
            .alert(L10n.text("Saved as routine", "Opgeslagen als schema"),
                   isPresented: Binding(get: { savedName != nil },
                                        set: { if !$0 { savedName = nil } })) {
                Button(L10n.done) { savedName = nil }
            } message: { Text(savedName ?? "") }
        }
    }

    private var searchField: some View {
        HStack(spacing: 11) {
            Image(systemName: "magnifyingglass").foregroundStyle(EF.faint)
            TextField(L10n.text("Find a workout or plan...", "Zoek een training..."), text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(EF.ink)
        }
        .padding(15)
        .background(EF.cobalt.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
    }

    private var sectionPicker: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Button {
                    section = index
                } label: {
                    Text(["Workouts", "Splits", "My 3 Weeks"][index])
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(section == index ? .white : EF.ink)
                        .frame(maxWidth: .infinity, minHeight: 47)
                        .background(section == index ? EF.cobalt : .clear,
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(section == index ? .isSelected : [])
            }
        }
        .padding(4)
        .background(EF.cobalt.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
    }

    @ViewBuilder private var featuredCard: some View {
        if let featured = CoachWorkoutLibrary.all.first {
            NavigationLink {
                detail(featured)
            } label: {
                VStack(alignment: .leading, spacing: 13) {
                    EFEyebrow(value: "TRAIN SMARTER", light: true)
                    Text("FIND YOUR\nNEXT SESSION")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .tracking(-0.8)
                        .foregroundStyle(EF.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(featured.name.uppercased() + "  •  ~\(featured.estimatedMinutes) MIN")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(EF.ice)
                    HStack {
                        Text("VIEW FEATURED")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(EF.ink)
                    .padding(.horizontal, 13)
                    .frame(height: 39)
                    .background(EF.orange, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 19)
                        .fill(EF.night)
                        .overlay(alignment: .trailing) {
                            Circle().stroke(EF.cobalt, lineWidth: 26)
                                .frame(width: 180, height: 180)
                                .offset(x: 80, y: 60)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 19))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var routinesPanel: some View {
        Button { showRoutines = true } label: {
            EFLinkTile(symbol: "calendar", title: "My routines and schedule",
                       subtitle: "Create, edit, schedule and share your splits")
        }
        .buttonStyle(.plain)
    }

    private var threeWeekPanel: some View {
        VStack(alignment: .leading, spacing: 17) {
            EFEyebrow(value: "03 / YOUR PROGRAM")
            Text("YOUR 3-WEEK\nBLUEPRINT")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(EF.ink)
            Text(L10n.text("Your fully editable plan and weekly schedule.",
                           "Jouw bewerkbare trainingsschema en weekplanning."))
                .font(.subheadline).foregroundStyle(EF.faint)
            Button { showThreeWeeks = true } label: {
                Label("OPEN MY PROGRAM", systemImage: "arrow.up.right")
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .font(.subheadline.weight(.bold))
            }
            .buttonStyle(.borderedProminent).tint(EF.cobalt)
            Button { showRoutines = true } label: {
                EFLinkTile(symbol: "list.bullet.rectangle", title: "My routines",
                           subtitle: "Manage custom schedules and training days")
            }
        }
        .padding(19)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 19))
    }

    private var workoutLibrary: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text(section == 1 ? "SPLITS & ROUTINES" : "\(filtered.count) READY-TO-USE WORKOUTS")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(EF.ink)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { option in
                        Button { category = option } label: {
                            Text(option == "All" ? "All goals" : option)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(category == option ? .white : EF.ink)
                                .padding(.horizontal, 16)
                                .frame(minHeight: 43)
                                .background(category == option ? EF.cobalt : EF.cobalt.opacity(0.07),
                                            in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            ForEach(filtered) { workout in
                NavigationLink {
                    detail(workout)
                } label: {
                    workoutRow(workout)
                }
                .buttonStyle(.plain)
            }
            if section == 0 {
                Button { section = 2 } label: {
                    EFLinkTile(symbol: "calendar.badge.clock", title: "Your 3-week program",
                               subtitle: "Separate, fully editable workout plan")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 7)
    }

    private func workoutRow(_ workout: CoachWorkout) -> some View {
        HStack(spacing: 13) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(EF.cobalt)
                .frame(width: 58, height: 65)
                .background(EF.cobalt.opacity(0.10), in: RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .leading, spacing: 5) {
                Text(workout.category.uppercased())
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundStyle(EF.cobalt)
                Text(workout.name)
                    .font(.subheadline.weight(.bold)).foregroundStyle(EF.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(workout.focus)
                    .font(.caption).foregroundStyle(EF.faint)
                    .lineLimit(2)
                Text("~\(workout.estimatedMinutes) MIN  ·  \(workout.exercises.count) MOVES  ·  \(workout.level.uppercased())")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(EF.faint)
                    .lineLimit(2)
            }
            Spacer(minLength: 2)
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(EF.ink)
        }
        .padding(14)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(EF.rule.opacity(0.65)))
    }

    private func detail(_ workout: CoachWorkout) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 17) {
                EFEyebrow(value: workout.category.uppercased())
                Text(workout.name.uppercased())
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(EF.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(workout.focus).font(.subheadline).foregroundStyle(EF.faint)
                HStack {
                    Text("~\(workout.estimatedMinutes) MIN")
                    Spacer()
                    Text("\(workout.totalSets) SETS")
                    Spacer()
                    Text(workout.level.uppercased())
                }
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(EF.cobalt)
                EFRule()
                EFSection(title: L10n.text("SESSION OUTLINE", "TRAININGSOPBOUW"))
                ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(String(format: "%02d", index + 1))
                            .font(.title2.bold()).foregroundStyle(EF.cobalt)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name.uppercased())
                                .font(.subheadline.weight(.heavy)).foregroundStyle(EF.ink)
                            Text("\(item.sets) × \(item.reps)")
                                .font(.caption.weight(.semibold)).foregroundStyle(EF.faint)
                        }
                        Spacer()
                        if let exercise = ExerciseCatalog.findByName(item.name) {
                            NavigationLink {
                                ExerciseDetailView(exercise: exercise)
                            } label: {
                                Image(systemName: "play.rectangle")
                                    .foregroundStyle(EF.cobalt)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                    EFRule()
                }
                EFAction(title: L10n.text("START WORKOUT", "START TRAINING")) {
                    launch(workout)
                }
                HStack(spacing: 14) {
                    Button {
                        CoachWorkoutActions.saveTemplate(workout, in: context)
                        savedName = workout.name
                    } label: { Label(L10n.text("SAVE", "BEWAREN"), systemImage: "bookmark") }
                    Spacer()
                    Button {
                        scheduled = ScheduledWorkoutRecord(
                            date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
                            title: workout.name,
                            exerciseIDs: workout.exercises.compactMap {
                                ExerciseCatalog.findByName($0.name)?.id
                            },
                            plan: workout.exercises, gymID: gymID, sourceLabel: "Playbook")
                    } label: {
                        Label(L10n.text("SCHEDULE", "PLANNEN"), systemImage: "calendar")
                    }
                }
                .font(.caption.weight(.heavy)).foregroundStyle(EF.cobalt)
                .frame(minHeight: 52)
                Text(L10n.text("Estimated duration includes warm-up, working sets, rest and station changes.",
                                "Tijdsindicatie inclusief warming-up, sets, rust en wisselen van toestel."))
                    .font(.caption).foregroundStyle(EF.faint)
            }
            .padding(24)
        }
        .background(EF.paper)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .tint(EF.cobalt)
    }
}
