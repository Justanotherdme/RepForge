import SwiftUI
import SwiftData

/// Personal program uses the original BuiltInProgram days and their persisted
/// ProgramPlanStore overrides. It never substitutes the public workout library.
struct EFPersonalThreeWeekProgram: View {
    @Environment(\.modelContext) private var context
    @ObservedObject var plan: ProgramPlanStore
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID
    @State private var week = 1
    @State private var editing: ProgramDay?
    @State private var templateDraft: ProgramDay?
    @State private var scheduling: ScheduledWorkoutRecord?
    @State private var activeSession: WorkoutSession?
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            heading
            weekSelector
            HStack {
                EFSection(title: L10n.text("Your training days", "Jouw trainingsdagen"),
                          detail: "\(plan.days(for: week).count) " + L10n.text("SESSIONS", "TRAININGEN"))
                Spacer(minLength: 0)
            }
            ForEach(plan.days(for: week)) { day in
                EFPersonalDayCard(
                    day: day,
                    customized: plan.isCustomized(day),
                    onEdit: { editing = day },
                    onStart: { start(day) },
                    onSaveTemplate: { templateDraft = day },
                    onSchedule: { schedule(day) },
                    onReset: { plan.reset(day) }
                )
            }
            NavigationLink {
                EFSavedRoutinesView()
            } label: {
                EFLinkTile(
                    symbol: "rectangle.stack",
                    title: L10n.text("My saved routines", "Mijn opgeslagen schema's"),
                    subtitle: L10n.text("Create, edit, duplicate and schedule your templates",
                                        "Maak, bewerk, kopieer en plan je templates")
                )
            }
            .buttonStyle(.plain)
        }
        .sheet(item: $editing) { day in
            ProgramDayEditorView(day: day) { updated in
                plan.save(updated)
            }
            .tint(EF.cobalt)
        }
        .sheet(item: $templateDraft) { day in
            TemplateEditorView(prefill: day)
        }
        .sheet(item: $scheduling) { item in
            ScheduleWorkoutSheet(seed: item) { updated in
                WorkoutScheduleStore.update(updated)
            }
        }
        .fullScreenCover(item: $activeSession) { session in
            EFWorkout(session: session)
        }
        .alert(L10n.text("Workout", "Training"), isPresented: Binding(
            get: { message != nil },
            set: { if !$0 { message = nil } }
        )) {
            Button(L10n.done) { message = nil }
        } message: {
            Text(message ?? "")
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 12) {
            EFEyebrow(value: "PERSONAL TRAINING / 03 WEEKS")
            Text(L10n.text("Your original\n3-week program", "Je originele\n3-wekenplan"))
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(EF.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.text("Your Monday, Wednesday, Friday and bonus sessions. Each day is editable; your changes are saved independently.",
                           "Je maandag-, woensdag-, vrijdag- en bonustrainingen. Elke dag is te bewerken; wijzigingen worden apart opgeslagen."))
                .font(.subheadline).foregroundStyle(EF.faint)
            HStack(spacing: 12) {
                Label("12 " + L10n.text("SESSIONS", "TRAININGEN"), systemImage: "calendar")
                Label("3 " + L10n.text("WEEKS", "WEKEN"), systemImage: "checkmark.square")
            }
            .font(.system(size: 10, weight: .heavy, design: .monospaced))
            .foregroundStyle(EF.cobalt)
            ShareLink(item: RepForgeShareCodec.programURL(
                name: "RepForge 3-Week Program",
                days: BuiltInProgram.days.map { plan.day(for: $0) }
            )) {
                Label(L10n.text("Share my 3-week plan", "Deel mijn 3-wekenplan"),
                      systemImage: "square.and.arrow.up")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(EF.cobalt)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(EF.rule))
    }

    private var weekSelector: some View {
        HStack(spacing: 7) {
            ForEach(1...3, id: \.self) { number in
                Button { week = number } label: {
                    VStack(spacing: 4) {
                        Text(L10n.text("WEEK", "WEEK"))
                            .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        Text("\(number)").font(.title3.bold())
                    }
                    .foregroundStyle(week == number ? EF.onAccent : EF.ink)
                    .frame(maxWidth: .infinity, minHeight: 59)
                    .background(week == number ? EF.cobalt : EF.surface,
                                in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(week == number ? .isSelected : [])
            }
        }
    }

    private func start(_ day: ProgramDay) {
        guard let result = CoachWorkoutActions.start(
            name: "\(day.title) — \(day.focus)",
            plan: day.exercises,
            gymID: gymID,
            in: context
        ) else {
            message = L10n.text(
                "This session has no exercises matched in your exercise library. Edit the day to choose available movements.",
                "Deze training heeft geen herkende oefeningen. Bewerk de dag en kies beschikbare oefeningen."
            )
            return
        }
        activeSession = result
    }

    private func schedule(_ day: ProgramDay) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        scheduling = ScheduledWorkoutRecord(
            date: tomorrow,
            title: "\(day.title) — \(day.focus)",
            exerciseIDs: day.exercises.compactMap { ExerciseCatalog.findByName($0.name)?.id },
            plan: day.exercises,
            gymID: gymID,
            sourceLabel: "My 3 Weeks"
        )
    }
}

private struct EFPersonalDayCard: View {
    let day: ProgramDay
    let customized: Bool
    let onEdit: () -> Void
    let onStart: () -> Void
    let onSaveTemplate: () -> Void
    let onSchedule: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Text(day.day.prefix(3).uppercased())
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    Text("\(day.exercises.count)")
                        .font(.title2.bold())
                }
                .foregroundStyle(EF.cobalt)
                .frame(width: 56, height: 62)
                .background(EF.cobalt.opacity(0.11), in: RoundedRectangle(cornerRadius: 13))

                VStack(alignment: .leading, spacing: 5) {
                    Text(day.day.uppercased())
                        .font(.caption.weight(.heavy)).foregroundStyle(EF.cobalt)
                    Text(day.focus)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(EF.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(day.partner.capitalized)
                        .font(.caption).foregroundStyle(EF.faint)
                }
                Spacer(minLength: 0)
                if customized {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(EF.cobalt)
                        .accessibilityLabel(L10n.text("Customized", "Aangepast"))
                }
            }
            HStack(spacing: 10) {
                Label("~\(TrainingTimeEstimator.minutes(for: day.exercises)) min", systemImage: "clock")
                Label("\(day.exercises.reduce(0) { $0 + $1.sets }) sets", systemImage: "list.number")
            }
            .font(.caption.weight(.medium)).foregroundStyle(EF.faint)

            ForEach(Array(day.exercises.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 11) {
                    Text(String(format: "%02d", index + 1))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(EF.cobalt)
                        .frame(width: 24, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(EF.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        if let note = item.note, !note.isEmpty {
                            Text(note).font(.caption).foregroundStyle(EF.faint)
                        }
                    }
                    Spacer(minLength: 6)
                    Text("\(item.sets) × \(item.reps)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(EF.faint)
                        .fixedSize(horizontal: true, vertical: false)
                }
                if index != day.exercises.count - 1 { EFRule() }
            }

            HStack(spacing: 9) {
                Button(action: onStart) {
                    Label(L10n.text("Start", "Start"), systemImage: "play.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity, minHeight: 47)
                }
                .buttonStyle(.borderedProminent).tint(EF.cobalt)
                Button(action: onEdit) {
                    Label(L10n.text("Edit", "Bewerk"), systemImage: "pencil")
                        .font(.subheadline.bold())
                        .foregroundStyle(EF.cobalt)
                        .frame(maxWidth: .infinity, minHeight: 47)
                        .background(EF.cobalt.opacity(0.10),
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                Menu {
                    Button(action: onSchedule) {
                        Label(L10n.text("Schedule", "Inplannen"), systemImage: "calendar")
                    }
                    Button(action: onSaveTemplate) {
                        Label(L10n.text("Save as template", "Bewaar als template"),
                              systemImage: "square.stack.3d.up")
                    }
                    ShareLink(item: RepForgeShareCodec.templateURL(
                        name: "\(day.title) — \(day.focus)",
                        exercises: day.exercises
                    )) {
                        Label(L10n.text("Share", "Delen"), systemImage: "square.and.arrow.up")
                    }
                    if customized {
                        Button(role: .destructive, action: onReset) {
                            Label(L10n.text("Restore original", "Herstel origineel"),
                                  systemImage: "arrow.counterclockwise")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(EF.ink)
                        .frame(width: 44, height: 47)
                        .background(EF.field, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(17)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 19))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(EF.rule))
    }
}

/// Distinct saved-template management destination, not the legacy StartWorkoutView.
struct EFSavedRoutinesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) private var templates: [WorkoutTemplate]
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID
    @State private var creating = false
    @State private var editing: WorkoutTemplate?
    @State private var deleteCandidate: WorkoutTemplate?
    @State private var scheduling: ScheduledWorkoutRecord?
    @State private var activeSession: WorkoutSession?
    @State private var message: String?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                EFPageHeading(
                    title: L10n.text("My Routines", "Mijn schema's"),
                    subtitle: L10n.text("Your saved templates, separate from your 3-week program.",
                                        "Je opgeslagen templates, los van je 3-wekenplan.")
                )
                Button { creating = true } label: {
                    Label(L10n.text("Create routine", "Maak schema"), systemImage: "plus")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent).tint(EF.cobalt)

                if templates.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.largeTitle).foregroundStyle(EF.cobalt)
                        Text(L10n.text("No saved routines yet", "Nog geen opgeslagen schema's"))
                            .font(.headline).foregroundStyle(EF.ink)
                        Text(L10n.text("Save any workout as a template, or create a routine here.",
                                       "Bewaar een training als template of maak hier een schema."))
                            .font(.subheadline).foregroundStyle(EF.faint)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(EF.surface, in: RoundedRectangle(cornerRadius: 18))
                }

                ForEach(templates) { template in
                    routineCard(template)
                }
            }
            .padding(20)
            .padding(.bottom, 80)
        }
        .background(EF.paper)
        .navigationTitle(L10n.text("My routines", "Mijn schema's"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .tint(EF.cobalt)
        .sheet(isPresented: $creating) { TemplateEditorView() }
        .sheet(item: $editing) { template in TemplateEditorView(template: template) }
        .sheet(item: $scheduling) { seed in
            ScheduleWorkoutSheet(seed: seed) { updated in
                WorkoutScheduleStore.update(updated)
            }
        }
        .fullScreenCover(item: $activeSession) { session in EFWorkout(session: session) }
        .confirmationDialog(L10n.text("Delete saved routine?", "Schema verwijderen?"),
                            isPresented: Binding(
                                get: { deleteCandidate != nil },
                                set: { if !$0 { deleteCandidate = nil } }
                            )) {
            Button(L10n.text("Delete routine", "Schema verwijderen"), role: .destructive) {
                if let template = deleteCandidate {
                    context.delete(template)
                    try? context.save()
                    deleteCandidate = nil
                }
            }
            Button(L10n.text("Cancel", "Annuleren"), role: .cancel) { deleteCandidate = nil }
        }
        .alert(L10n.text("Routine", "Schema"), isPresented: Binding(
            get: { message != nil },
            set: { if !$0 { message = nil } }
        )) {
            Button(L10n.done) { message = nil }
        } message: { Text(message ?? "") }
    }

    private func routineCard(_ template: WorkoutTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "rectangle.stack.fill")
                    .font(.title3)
                    .foregroundStyle(EF.cobalt)
                    .frame(width: 42, height: 42)
                    .background(EF.cobalt.opacity(0.09), in: RoundedRectangle(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline.bold()).foregroundStyle(EF.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(template.plannedExercises?.count ?? template.exerciseIDs.count) " +
                         L10n.text("exercises", "oefeningen"))
                        .font(.caption).foregroundStyle(EF.faint)
                }
                Spacer(minLength: 0)
                Menu {
                    Button { editing = template } label: {
                        Label(L10n.text("Edit", "Bewerk"), systemImage: "pencil")
                    }
                    Button {
                        let copy = WorkoutTemplate(
                            name: template.name + " " + L10n.text("Copy", "Kopie"),
                            exerciseIDs: template.exerciseIDs,
                            plan: template.plannedExercises
                        )
                        context.insert(copy)
                        try? context.save()
                    } label: {
                        Label(L10n.text("Duplicate", "Kopieer"),
                              systemImage: "plus.square.on.square")
                    }
                    Button { schedule(template) } label: {
                        Label(L10n.text("Schedule", "Inplannen"), systemImage: "calendar")
                    }
                    ShareLink(item: RepForgeShareCodec.templateURL(
                        name: template.name,
                        exercises: template.plannedExercises ??
                            template.exerciseIDs.compactMap { id in
                                guard let def = ExerciseCatalog.find(id) else { return nil }
                                return ProgramExercise(def.name, AppPreferences.defaultSets, "8–12")
                            }
                    )) {
                        Label(L10n.text("Share", "Delen"), systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) { deleteCandidate = template } label: {
                        Label(L10n.text("Delete", "Verwijderen"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(EF.ink)
                        .frame(width: 44, height: 44)
                        .background(EF.field, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            HStack(spacing: 10) {
                Button { start(template) } label: {
                    Label(L10n.text("Start workout", "Start training"), systemImage: "play.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(.borderedProminent).tint(EF.cobalt)
                Button { editing = template } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(EF.cobalt)
                        .frame(width: 48, height: 46)
                        .background(EF.field, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(17)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(EF.rule))
    }

    private func start(_ template: WorkoutTemplate) {
        let plan = template.plannedExercises ??
            template.exerciseIDs.compactMap { id -> ProgramExercise? in
                guard let def = ExerciseCatalog.find(id) else { return nil }
                return ProgramExercise(def.name, AppPreferences.defaultSets, "8–12")
            }
        guard let session = CoachWorkoutActions.start(
            name: template.name, plan: plan, gymID: gymID, in: context
        ) else {
            message = L10n.text("This routine has no available exercises.",
                                "Dit schema bevat geen beschikbare oefeningen.")
            return
        }
        activeSession = session
    }

    private func schedule(_ template: WorkoutTemplate) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        scheduling = ScheduledWorkoutRecord(
            date: tomorrow,
            title: template.name,
            exerciseIDs: template.exerciseIDs,
            plan: template.plannedExercises,
            gymID: gymID,
            sourceLabel: "My Routines"
        )
    }
}
