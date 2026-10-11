import SwiftUI
import SwiftData
import UIKit
import Combine

struct EFWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var session: WorkoutSession
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var history: [WorkoutSession]

    @State private var selection = 0
    @State private var chooseExercises = false
    @State private var pickerIDs: [String] = []
    @State private var showFinish = false
    @State private var showSummary = false
    @State private var showAdvanced = false
    @State private var editNote = false
    @State private var noteDraft = ""
    @State private var restEnd: Date?
    @State private var restDuration = 90
    @State private var restExercise = ""
    @AppStorage("defaultRestSeconds") private var defaultRestSeconds = 90
    @AppStorage("autoRestTimer") private var autoRestTimer = true
    @AppStorage("keepScreenAwake") private var keepScreenAwake = true

    private var exercises: [ExerciseLog] { session.exercises.sorted { $0.order < $1.order } }
    private var selected: ExerciseLog? { exercises.indices.contains(selection) ? exercises[selection] : nil }
    private var complete: Int { session.exercises.reduce(0) { $0 + $1.sets.filter(\.completed).count } }
    private var total: Int { session.exercises.reduce(0) { $0 + $1.sets.count } }
    private var percent: Double { total == 0 ? 0 : Double(complete) / Double(total) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 17) {
                    toolbar
                    sessionOverview
                    exerciseQueue
                    if let log = selected {
                        EFWorkoutExercise(
                            log: log,
                            history: history,
                            gymID: GymProfileStore.sessionGymID(session),
                            setCompleted: { startRest(for: log) },
                            removeExercise: { remove(log) }
                        )
                        .id(log.id)
                    } else {
                        emptyState
                    }
                    addExerciseButton
                    Button {
                        noteDraft = session.note ?? ""
                        editNote = true
                    } label: {
                        Label(L10n.text("Workout notes", "Trainingsnotities"),
                              systemImage: "square.and.pencil")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(EF.cobalt)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(EF.paper)
            .scrollDismissesKeyboard(.interactively)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let restEnd {
                    EFRestStrip(
                        end: restEnd, duration: restDuration,
                        adjust: { amount in
                            self.restEnd = restEnd.addingTimeInterval(TimeInterval(amount))
                            restDuration = max(1, restDuration + amount)
                            updateLiveActivity()
                        },
                        skip: { stopRest() }
                    )
                }
            }
            .sheet(isPresented: $chooseExercises, onDismiss: appendSelected) {
                EFExerciseSelector(selectedIDs: $pickerIDs)
            }
            .sheet(isPresented: $showAdvanced) {
                ActiveWorkoutView(session: session)
            }
            .sheet(isPresented: $editNote) {
                NavigationStack {
                    Form {
                        TextField(L10n.text("Workout note", "Trainingsnotitie"),
                                  text: $noteDraft, axis: .vertical)
                            .lineLimit(3...8)
                    }
                    .navigationTitle(L10n.text("Notes", "Notities"))
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(L10n.done) {
                                session.note = noteDraft
                                try? context.save()
                                editNote = false
                            }
                        }
                    }
                }
            }
            .confirmationDialog(
                L10n.text("Finish and save this workout?", "Training afronden en bewaren?"),
                isPresented: $showFinish
            ) {
                Button(L10n.text("Finish workout", "Training afronden")) { finish() }
                Button(L10n.text("Cancel", "Annuleren"), role: .cancel) {}
            }
            .sheet(isPresented: $showSummary, onDismiss: {
                dismiss()
            }) {
                WorkoutSummaryView(session: session, sessions: history) {
                    showSummary = false
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                if let restEnd, restEnd <= Date() {
                    stopRest()
                    Haptics.success()
                }
            }
            .onAppear { UIApplication.shared.isIdleTimerDisabled = keepScreenAwake }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        }
        .tint(EF.cobalt)
    }

    private var toolbar: some View {
        HStack {
            Button { dismiss() } label: {
                Label(L10n.text("Back", "Terug"), systemImage: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EF.cobalt)
                    .frame(minHeight: 44)
            }
            .accessibilityLabel(L10n.text("Close, keep workout open", "Sluit, behoud training"))
            Spacer()
            Text("LIVE WORKOUT")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(EF.faint)
            Spacer()
            Button { showFinish = true } label: {
                Text(L10n.text("Finish", "Afronden"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 15)
                    .frame(minHeight: 40)
                    .background(EF.cobalt, in: Capsule())
            }
        }
    }

    private var sessionOverview: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    EFEyebrow(value: "SESSION IN PROGRESS")
                    Text(session.title)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(-1)
                        .foregroundStyle(EF.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                }
                Spacer(minLength: 0)
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(durationString(session.duration))
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(EF.cobalt)
                        Text("DURATION")
                            .font(.system(size: 9, weight: .heavy, design: .monospaced))
                            .foregroundStyle(EF.faint)
                    }
                }
            }
            HStack(spacing: 8) {
                statChip("\(exercises.count) EXERCISES", "dumbbell")
                statChip("\(complete) / \(total) SETS", "checkmark.circle")
                Spacer(minLength: 0)
                Text("\(Int(percent * 100))%")
                    .font(.subheadline.weight(.bold)).foregroundStyle(EF.cobalt)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(EF.field)
                    Capsule().fill(EF.cobalt)
                        .frame(width: proxy.size.width * percent)
                }
            }
            .frame(height: 7)
            .accessibilityLabel("\(Int(percent * 100)) percent complete")
        }
        .padding(19)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 21))
        .overlay(RoundedRectangle(cornerRadius: 21).stroke(EF.rule))
    }
    private func statChip(_ value: String, _ symbol: String) -> some View {
        Label(value, systemImage: symbol)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(EF.faint)
    }

    private var exerciseQueue: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                EFSection(title: L10n.text("Exercise queue", "Oefeningen"),
                          detail: "\(exercises.isEmpty ? 0 : selection + 1) / \(exercises.count)")
                Spacer(minLength: 0)
                Button { showAdvanced = true } label: {
                    Label(L10n.text("All", "Alles"), systemImage: "list.bullet")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(EF.cobalt)
                        .frame(minHeight: 44)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, log in
                        Button {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                            selection = index
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("EXERCISE \(index + 1)")
                                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                    .foregroundStyle(selection == index ? .white.opacity(0.77) : EF.faint)
                                Text(ExerciseCatalog.find(log.exerciseID)?.name ?? "Exercise")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(selection == index ? .white : EF.ink)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .frame(width: 190, height: 68, alignment: .leading)
                            .background(selection == index ? EF.cobalt : EF.surface,
                                        in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(EF.rule.opacity(0.65)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selection == index ? .isSelected : [])
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 11) {
            EFSection(title: L10n.text("No exercises yet", "Nog geen oefeningen"))
            Text(L10n.text("Add an exercise to build your workout.",
                           "Voeg een oefening toe aan je training."))
                .foregroundStyle(EF.faint)
            Button {
                pickerIDs = []
                chooseExercises = true
            } label: {
                Label(L10n.addExercise, systemImage: "plus")
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent).tint(EF.cobalt)
        }
        .padding(20)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private var addExerciseButton: some View {
        Button {
            pickerIDs = []
            chooseExercises = true
        } label: {
            Label(L10n.addExercise, systemImage: "plus")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(EF.cobalt)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(EF.cobalt.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(EF.cobalt.opacity(0.27)))
        }
        .buttonStyle(.plain)
    }

    private func appendSelected() {
        let existing = Set(session.exercises.map(\.exerciseID))
        var index = (exercises.map(\.order).max() ?? -1) + 1
        let first = index
        for id in pickerIDs where !existing.contains(id) {
            let count = ExerciseCatalog.find(id)?.movement == "cardio" ? 1 : AppPreferences.defaultSets
            session.exercises.append(
                ExerciseLog(exerciseID: id, order: index,
                            sets: (0..<max(1, count)).map { WorkoutSet(order: $0) })
            )
            index += 1
        }
        if index > first { selection = first }
        try? context.save()
        pickerIDs = []
    }
    private func remove(_ log: ExerciseLog) {
        session.exercises.removeAll { $0.id == log.id }
        for (index, item) in exercises.enumerated() { item.order = index }
        selection = max(0, min(selection, session.exercises.count - 1))
        try? context.save()
    }
    private func startRest(for log: ExerciseLog) {
        guard autoRestTimer else { return }
        let duration = log.restSeconds ?? defaultRestSeconds
        guard duration > 0 else { return }
        restDuration = duration
        restExercise = ExerciseCatalog.find(log.exerciseID)?.name ?? ""
        restEnd = .now.addingTimeInterval(TimeInterval(duration))
        RestNotificationManager.shared.schedule(seconds: duration, exerciseName: restExercise)
        updateLiveActivity()
    }
    private func updateLiveActivity() {
        guard let restEnd else { return }
        RestTimerLiveActivityManager.startOrUpdate(
            workoutTitle: session.title, exerciseName: restExercise,
            endDate: restEnd, totalSeconds: restDuration
        )
    }
    private func stopRest() {
        restEnd = nil
        RestNotificationManager.shared.cancel()
        RestTimerLiveActivityManager.end()
    }
    private func finish() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil, from: nil, for: nil)
        session.endedAt = .now
        stopRest()
        try? context.save()
        Haptics.success()
        showSummary = true
    }
}

struct EFRestStrip: View {
    let end: Date
    let duration: Int
    let adjust: (Int) -> Void
    let skip: () -> Void
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let left = max(0, Int(ceil(end.timeIntervalSince(timeline.date))))
            VStack(spacing: 10) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        EFEyebrow(value: "REST TIMER")
                        Text(String(format: "%02d:%02d", left / 60, left % 60))
                            .font(.system(size: 25, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(EF.cobalt)
                    }
                    Spacer()
                    Button { adjust(-15) } label: { Text("−15s") }
                    Button { adjust(15) } label: { Text("+15s") }
                    Button(action: skip) {
                        Text("SKIP").foregroundStyle(EF.cobalt)
                    }
                }
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(EF.ink)
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 19)
            .padding(.vertical, 10)
            .background(EF.surface)
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    Rectangle().fill(EF.cobalt)
                        .frame(width: proxy.size.width * min(1, Double(left) / Double(max(1, duration))),
                               height: 3)
                }
                .allowsHitTesting(false)
            }
        }
    }
}
