import SwiftUI
import SwiftData

struct EFPlans: View {
    let launch: (CoachWorkout) -> Void
    @Environment(\.modelContext) private var context
    @State private var category = "All"
    @State private var query = ""
    @State private var showThreeWeeks = false
    @State private var showRoutines = false
    @State private var savedName: String?
    @State private var scheduled: ScheduledWorkoutRecord?
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID
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
                LazyVStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 0) {
                                Text("THE ").foregroundStyle(EF.ink)
                                Text("PLAYBOOK.").foregroundStyle(EF.cobalt)
                            }
                            EFEyebrow(value: "BUILT FOR CONSISTENCY.")
                        }
                        .font(.system(size: 16, weight: .black))
                        Spacer()
                        Text("02 / 06")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundStyle(EF.cobalt)
                    }
                    .padding(.bottom, 34)
                    EFTitle(lines: L10n.text("TRAIN WITH|INTENT.", "TRAIN MET|EEN DOEL.").components(separatedBy: "|"), highlight: 1)
                    Text(L10n.text("Real plans. Clear progression. Time you can actually commit.",
                                    "Duidelijke schema's, zichtbare vooruitgang, haalbare trainingstijden."))
                        .font(.subheadline).foregroundStyle(EF.faint)
                        .padding(.top, 12).padding(.bottom, 23)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(["All", "Strength", "Muscle growth", "Express", "Full body", "Targeted", "Conditioning"], id: \.self) { option in
                                Button {
                                    category = option
                                } label: {
                                    Text(option == "All" ? "ALL" : option.uppercased())
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundStyle(category == option ? .white : EF.ink)
                                        .padding(.horizontal, 12).frame(minHeight: 44)
                                        .background(category == option ? EF.ink : .clear)
                                        .overlay(Rectangle().stroke(EF.rule))
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(category == option ? .isSelected : [])
                            }
                        }
                    }
                    .padding(.bottom, 27)

                    EFSection(title: "EDITOR'S PICK.", detail: "01 / FEATURED")
                    if let featured = CoachWorkoutLibrary.all.first(where: { $0.id == "upper-a" }) ??
                        CoachWorkoutLibrary.all.first {
                        NavigationLink {
                            detail(featured)
                        } label: {
                            VStack(alignment: .leading, spacing: 14) {
                                EFEyebrow(value: "THE STRENGTH BLUEPRINT", light: true)
                                Text(featured.name.uppercased())
                                    .font(.system(size: 33, weight: .black, design: .rounded))
                                    .tracking(-1.5)
                                    .foregroundStyle(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                HStack {
                                    Text(featured.level.uppercased())
                                    Text("•")
                                    Text("\(featured.exercises.count) MOVES")
                                    Spacer()
                                    Text("~ \(featured.estimatedMinutes) MIN")
                                        .padding(9)
                                        .background(EF.orange)
                                        .foregroundStyle(EF.ink)
                                }
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundStyle(EF.ice)
                            }
                            .padding(21)
                            .frame(maxWidth: .infinity, minHeight: 205, alignment: .leading)
                            .background {
                                ZStack(alignment: .bottomTrailing) {
                                    EF.ink
                                    Circle().stroke(EF.cobalt, lineWidth: 27)
                                        .frame(width: 190, height: 190)
                                        .offset(x: 61, y: 74)
                                        .clipped()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 12)
                    }
                    EFSection(title: "PROGRAM LIBRARY", detail: "\(filtered.count) WORKOUTS")
                        .padding(.top, 30)
                    TextField(L10n.text("Search programs", "Zoek trainingsschema's"), text: $query)
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 12)
                        .overlay(alignment: .bottom) { EFRule() }
                        .padding(.top, 10)
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, workout in
                        NavigationLink {
                            detail(workout)
                        } label: {
                            EFNumberRow(order: index + 1, title: workout.name,
                                        detail: "\(workout.level) • \(workout.equipment) • ~\(workout.estimatedMinutes) MIN")
                        }
                        .buttonStyle(.plain)
                        EFRule()
                    }
                    Button { showThreeWeeks = true } label: {
                        HStack {
                            Text("03").font(.system(size: 33, weight: .black))
                                .foregroundStyle(EF.cobalt)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(L10n.text("YOUR 3-WEEK PROGRAM", "JOUW 3-WEKENPLAN"))
                                    .font(.headline.weight(.heavy))
                                Text(L10n.text("Separate, fully editable plan",
                                                "Apart, volledig bewerkbaar schema"))
                                    .font(.caption).foregroundStyle(EF.faint)
                            }
                            Spacer()
                            Text("OPEN ↗").font(.caption.weight(.heavy))
                                .foregroundStyle(EF.cobalt)
                        }
                        .padding(16)
                        .overlay(Rectangle().stroke(EF.cobalt, lineWidth: 1.2))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 22)
                    Button { showRoutines = true } label: {
                        EFNumberRow(order: 4, title: L10n.text("MY ROUTINES AND SCHEDULE",
                                                            "MIJN SCHEMA'S EN AGENDA"),
                                    detail: L10n.text("Create, edit, schedule and share",
                                                      "Maken, bewerken, plannen en delen"))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .background(EF.paper)
            .toolbar(.hidden, for: .navigationBar)
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
