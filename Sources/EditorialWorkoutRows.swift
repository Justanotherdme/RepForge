import SwiftUI
import SwiftData
import UIKit

struct EFWorkoutExercise: View {
    @Environment(\.modelContext) private var context
    @Bindable var log: ExerciseLog
    let history: [WorkoutSession]
    let gymID: String
    let setCompleted: () -> Void
    let removeExercise: () -> Void
    @State private var previous: [(Double, Int)] = []
    @State private var showOptions = false
    @State private var confirmDelete = false
    private var exercise: ExerciseDefinition? { ExerciseCatalog.find(log.exerciseID) }
    private var sets: [WorkoutSet] { log.sets.sorted { $0.order < $1.order } }
    private var isCardio: Bool { exercise?.movement == "cardio" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            exerciseActions
            exerciseTitle
            exerciseMetadata
            EFRule()
            setHeaders
            setRows
            addSetButton
            previousSetSummary
        }
        .padding(17)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(EF.rule))
        .onAppear {
            previous = Metrics.previousSets(
                exerciseID: log.exerciseID, sessions: history, gymID: gymID
            )
        }
        .sheet(isPresented: $showOptions) {
            ExerciseLogOptionsView(log: log)
        }
        .confirmationDialog(
            L10n.text("Remove this exercise?", "Oefening verwijderen?"),
            isPresented: $confirmDelete
        ) {
            Button(L10n.text("Remove", "Verwijderen"), role: .destructive, action: removeExercise)
            Button(L10n.text("Cancel", "Annuleren"), role: .cancel) {}
        }
    }
    private var exerciseActions: some View {
        HStack {
            EFEyebrow(value: "CURRENT EXERCISE")
            Spacer()
            if let exercise {
                NavigationLink {
                    ExerciseDetailView(exercise: exercise)
                } label: {
                    Label("VIDEO", systemImage: "play.rectangle")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(EF.faint)
                        .frame(minHeight: 44)
                }
            }
            Menu {
                Button(L10n.text("Exercise options", "Oefeningopties"), systemImage: "slider.horizontal.3") {
                    showOptions = true
                }
                Button(L10n.text("Remove exercise", "Oefening verwijderen"),
                       systemImage: "trash", role: .destructive) {
                    confirmDelete = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(EF.faint)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(L10n.text("Exercise actions", "Oefeningacties"))
        }
    }

    private var exerciseTitle: some View {
        Text(exercise?.name ?? "Exercise")
            .font(.system(size: 24, weight: .black, design: .rounded))
            .tracking(-0.8)
            .foregroundStyle(EF.ink)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
    }

    private var exerciseMetadata: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("\(exercise?.muscle ?? "") • \(exercise?.equipment ?? "")")
                .font(.caption.weight(.medium))
                .foregroundStyle(EF.faint)
            Label("\(log.restSeconds ?? AppPreferences.defaultRestSeconds)s rest between sets",
                  systemImage: "timer")
                .font(.caption.weight(.medium))
                .foregroundStyle(EF.cobalt)
        }
        .padding(.top, 8)
        .padding(.bottom, 17)
    }

    @ViewBuilder private var setHeaders: some View {
        if isCardio {
            HStack {
                heading("INTERVAL")
                Spacer()
                heading("MIN")
                Spacer()
                heading("DIST")
                Spacer()
                heading("LOG")
            }
            .padding(.vertical, 10)
        } else {
            HStack(spacing: 7) {
                heading("SET").frame(width: 24, alignment: .leading)
                heading(AppPreferences.weightLabel.uppercased()).frame(maxWidth: .infinity)
                heading("REPS").frame(maxWidth: .infinity)
                heading("LOG").frame(width: 44)
            }
            .padding(.vertical, 9)
        }
    }

    private var setRows: some View {
        ForEach(sets) { set in
            if isCardio {
                EFCardioLine(set: set, canDelete: sets.count > 1,
                             completed: { if $0 { setCompleted() } },
                             delete: { delete(set) })
            } else {
                EFStrengthLine(
                    set: set,
                    previous: previous.indices.contains(set.order) ? previous[set.order] : nil,
                    canDelete: sets.count > 1,
                    completed: { if $0 { setCompleted() } },
                    delete: { delete(set) }
                )
            }
            EFRule()
        }
    }

    private var addSetButton: some View {
        Button {
            log.sets.append(WorkoutSet(order: sets.count))
            try? context.save()
            Haptics.light()
        } label: {
            Label(L10n.text("Add set", "Set toevoegen"), systemImage: "plus")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(EF.cobalt)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(EF.cobalt.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(EF.cobalt.opacity(0.25)))
        }
        .buttonStyle(.plain)
        .padding(.top, 15)
    }

    @ViewBuilder private var previousSetSummary: some View {
        if let last = previous.last {
            previousSetRow(last)
        }
    }

    private func previousSetRow(_ last: (Double, Int)) -> some View {
        HStack {
            Text(previousSetText(for: last))
            Spacer()
            Button {
                copyPreviousSet(last)
            } label: {
                Text("COPY LAST ↗").foregroundStyle(EF.faint)
            }
        }
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .foregroundStyle(EF.faint)
        .frame(minHeight: 46)
    }

    private func previousSetText(for last: (Double, Int)) -> String {
        let weight: Double = AppPreferences.displayWeight(last.0)
        let formattedWeight = weight.formatted(.number.precision(.fractionLength(0...2)))
        return "\(L10n.text("PREVIOUS", "VORIG"))  \(formattedWeight) \(AppPreferences.weightLabel) × \(last.1)"
    }

    private func copyPreviousSet(_ last: (Double, Int)) {
        guard let next = sets.first(where: { !$0.completed }) else { return }
        next.weightKg = last.0
        next.reps = last.1
        try? context.save()
        Haptics.light()
    }

    private func heading(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 10, weight: .heavy, design: .monospaced))
            .foregroundStyle(EF.faint)
    }
    private func delete(_ set: WorkoutSet) {
        guard log.sets.count > 1 else { return }
        log.sets.removeAll { $0.id == set.id }
        for (i, item) in sets.enumerated() { item.order = i }
        try? context.save()
    }
}

struct EFStrengthLine: View {
    @Environment(\.modelContext) private var context
    @Bindable var set: WorkoutSet
    let previous: (Double, Int)?
    let canDelete: Bool
    let completed: (Bool) -> Void
    let delete: () -> Void
    @State private var showSetOptions = false
    @Environment(\.dynamicTypeSize) private var dynamicType

    var body: some View {
        VStack(spacing: 8) {
            row
            if dynamicType.isAccessibilitySize {
                Text("KG × REPS").font(.caption).foregroundStyle(EF.faint)
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showSetOptions) { SetOptionsView(set: set) }
    }
    private var row: some View {
        HStack(spacing: 7) {
            Menu {
                Button(L10n.text("Set options", "Setopties"), systemImage: "slider.horizontal.3") {
                    showSetOptions = true
                }
                if canDelete {
                    Button(L10n.text("Delete set", "Set verwijderen"),
                           systemImage: "trash", role: .destructive, action: delete)
                }
            } label: {
                VStack(spacing: 2) {
                    Text("\(set.order + 1)")
                    if set.setType != "working" {
                        Circle().fill(EF.orange).frame(width: 5, height: 5)
                    }
                }
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundStyle(EF.cobalt)
                .frame(width: 24, height: 48)
            }
            weightInput
            repsInput
            Button {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                )
                set.completed.toggle()
                set.completedAt = set.completed ? .now : nil
                try? context.save()
                if set.completed { Haptics.success() } else { Haptics.light() }
                completed(set.completed)
            } label: {
                Image(systemName: set.completed ? "checkmark" : "circle")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(set.completed ? EF.night : EF.ice)
                    .frame(width: 44, height: 48)
                    .background(set.completed ? EF.mint : EF.field, in: RoundedRectangle(cornerRadius: 11))
                    .overlay(Circle().stroke(set.completed ? .clear : EF.rule))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(set.completed ? "Undo completed set" : "Complete set \(set.order + 1)")
        }
    }
    private var weightInput: some View {
        DoneNumberField(
            value: Binding(
                get: { AppPreferences.displayWeight(set.weightKg) },
                set: { set.weightKg = AppPreferences.storedWeightKg($0) }
            ),
            integerOnly: false, placeholder: "0"
        )
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(EF.field, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityLabel("Weight set \(set.order + 1)")
    }
    private var repsInput: some View {
        DoneNumberField(
            value: Binding(
                get: { Double(set.reps) },
                set: { set.reps = max(0, Int($0.rounded())) }
            ),
            integerOnly: true, placeholder: "0"
        )
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(EF.field, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityLabel("Reps set \(set.order + 1)")
    }
}

struct EFCardioLine: View {
    @Environment(\.modelContext) private var context
    @Bindable var set: WorkoutSet
    let canDelete: Bool
    let completed: (Bool) -> Void
    let delete: () -> Void
    @State private var showOptions = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Menu {
                    Button(L10n.text("Set options", "Setopties"), systemImage: "slider.horizontal.3") {
                        showOptions = true
                    }
                    if canDelete {
                        Button(L10n.text("Delete", "Verwijderen"),
                               systemImage: "trash", role: .destructive, action: delete)
                    }
                } label: {
                    Text("\(set.order + 1)")
                        .font(.caption.bold()).foregroundStyle(EF.faint)
                        .frame(width: 24, height: 48)
                }
                DoneNumberField(value: Binding(
                    get: { (set.durationSeconds ?? 0) / 60 },
                    set: { set.durationSeconds = $0 > 0 ? $0 * 60 : nil }
                ), integerOnly: false, placeholder: "0")
                .frame(height: 48).background(EF.field)
                DoneNumberField(value: Binding(
                    get: { AppPreferences.displayDistance(set.distanceKm ?? 0) },
                    set: {
                        let km = AppPreferences.storedDistanceKm($0)
                        set.distanceKm = km > 0 ? km : nil
                    }
                ), integerOnly: false, placeholder: "0")
                .frame(height: 48).background(EF.field)
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                    )
                    set.completed.toggle()
                    set.completedAt = set.completed ? .now : nil
                    try? context.save()
                    completed(set.completed)
                } label: {
                    Image(systemName: set.completed ? "checkmark" : "circle")
                        .foregroundStyle(set.completed ? EF.night : EF.ice)
                        .frame(width: 44, height: 48)
                        .background(set.completed ? EF.mint : EF.field, in: RoundedRectangle(cornerRadius: 11))
                }
            }
            .padding(.vertical, 7)
        }
        .sheet(isPresented: $showOptions) {
            SetOptionsView(set: set)
        }
    }
}
