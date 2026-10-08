import SwiftUI
import SwiftData
import UIKit

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
                LazyVStack(alignment: .leading, spacing: 19) {
                    toolbar
                    HStack(alignment: .lastTextBaseline) {
                        VStack(alignment: .leading, spacing: 6) {
                            EFEyebrow(value: "● LIVE SESSION", light: true)
                            Text(session.title.uppercased())
                                .font(.system(size: 29, weight: .black, design: .rounded))
                                .tracking(-1.4)
                                .foregroundStyle(EF.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityAddTraits(.isHeader)
                        }
                        Spacer()
                        TimelineView(.periodic(from: .now, by: 1)) { _ in
                            Text(durationString(session.duration))
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(EF.white)
                        }
                    }
                    HStack {
                        Text("\(complete) / \(total) SETS LOGGED")
                        Spacer()
                        Text("\(Int(percent * 100))% COMPLETE")
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(EF.ice)
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(EF.nightField)
                            Rectangle().fill(EF.mint).frame(width: proxy.size.width * percent)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        EFEyebrow(value: "EXERCISE QUEUE", light: true)
                        Spacer()
                        Button { showAdvanced = true } label: {
                            Text(L10n.text("ALL EXERCISES →", "ALLE OEFENINGEN →"))
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundStyle(EF.ice)
                                .frame(minHeight: 44)
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, log in
                                Button {
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil
                                    )
                                    selection = index
                                } label: {
                                    Text("\(String(format: "%02d", index + 1)) / " +
                                         (ExerciseCatalog.find(log.exerciseID)?.name ?? "Exercise").uppercased())
                                        .font(.system(size: 10, weight: .heavy))
                                        .lineLimit(1)
                                        .padding(.horizontal, 13)
                                        .frame(minHeight: 44)
                                        .foregroundStyle(selection == index ? EF.night : EF.ice)
                                        .background(selection == index ? EF.white : EF.nightPanel)
                                        .overlay(Rectangle().stroke(EF.ice.opacity(0.25)))
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(selection == index ? .isSelected : [])
                            }
                        }
                    }

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
                        VStack(alignment: .leading, spacing: 10) {
                            EFSection(title: "NO EXERCISES YET", dark: true)
                            Text(L10n.text("Add your first exercise to begin.",
                                            "Voeg een oefening toe om te beginnen."))
                                .foregroundStyle(EF.ice)
                        }
                        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                        .background(EF.nightPanel)
                    }

                    Button {
                        pickerIDs = []
                        chooseExercises = true
                    } label: {
                        Label(L10n.addExercise.uppercased(), systemImage: "plus")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(EF.ice)
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .overlay(Rectangle().stroke(EF.ice.opacity(0.6)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        noteDraft = session.note ?? ""
                        editNote = true
                    } label: {
                        Label(L10n.text("Workout notes", "Trainingsnotities"),
                              systemImage: "square.and.pencil")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(EF.ice)
                            .frame(minHeight: 45)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .background(EF.night)
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
        .environment(\.colorScheme, .dark)
        .tint(EF.ice)
    }

    private var toolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("× CLOSE")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(EF.white)
                    .padding(.horizontal, 13)
                    .frame(minHeight: 45)
                    .overlay(Rectangle().stroke(EF.ice.opacity(0.7)))
            }
            .accessibilityLabel(L10n.text("Close, keep workout open", "Sluit, behoud training"))
            Spacer()
            Button { showFinish = true } label: {
                Text("FINISH ↗")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(EF.ice)
                    .padding(.horizontal, 13)
                    .frame(minHeight: 45)
                    .overlay(Rectangle().stroke(EF.ice.opacity(0.7)))
            }
        }
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
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 4) {
                    EFEyebrow(value: "REST TIMER", light: true)
                    Text(String(format: "%02d:%02d", left / 60, left % 60))
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(EF.white)
                }
                Spacer()
                Button { adjust(-15) } label: { Text("−15") }
                Button { adjust(15) } label: { Text("+15") }
                Button(action: skip) {
                    Text("SKIP").foregroundStyle(EF.mint)
                }
            }
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(EF.white)
            .buttonStyle(.bordered)
            .padding(.horizontal, 20)
            .frame(minHeight: 80)
            .background(Color(red: 0.11, green: 0.20, blue: 0.29))
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    Rectangle().fill(EF.mint)
                        .frame(width: proxy.size.width * min(1, Double(left) / Double(max(1, duration))),
                               height: 3)
                }
                .allowsHitTesting(false)
            }
        }
    }
}
