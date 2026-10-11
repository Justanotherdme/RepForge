import SwiftUI

/// Editorial exercise selector used from the live session; selection stays local
/// until dismissal so the SwiftData session is mutated only once.
struct EFExerciseSelector: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIDs: [String]
    @State private var search = ""
    @State private var equipment = "All"
    @State private var muscle = "All"
    private var results: [ExerciseDefinition] {
        ExerciseCatalog.all.filter {
            ExerciseSearch.matches($0, query: search) &&
            GymEquipmentFilter.matches($0, selected: equipment) &&
            (muscle == "All" || $0.muscle == muscle)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    EFEyebrow(value: "REP FORGE / SELECT")
                    EFTitle(lines: L10n.text("FIND YOUR|MOVE.", "VIND JOUW|OEFENING.")
                        .components(separatedBy: "|"))
                        .padding(.top, 12)
                    TextField(L10n.text("Search by machine or exercise",
                                        "Zoek op apparaat of oefening"), text: $search)
                        .font(.title3.weight(.semibold))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.vertical, 15)
                        .overlay(alignment: .bottom) { EFRule() }
                        .padding(.top, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(GymEquipmentFilter.options, id: \.self) { kind in
                                Button {
                                    equipment = kind
                                } label: {
                                    Text(GymEquipmentFilter.label(kind).uppercased())
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundStyle(equipment == kind ? .white : EF.ink)
                                        .padding(.horizontal, 12)
                                        .frame(minHeight: 44)
                                        .background(equipment == kind ? EF.ink : .clear)
                                        .overlay(Rectangle().stroke(EF.rule))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 17)

                    Menu {
                        Button(L10n.text("All muscles", "Alle spiergroepen")) {
                            muscle = "All"
                        }
                        ForEach(ExerciseCatalog.muscles, id: \.self) { group in
                            Button(group) { muscle = group }
                        }
                    } label: {
                        Label(muscle == "All" ? L10n.text("All muscles", "Alle spieren") : muscle,
                              systemImage: "line.3.horizontal.decrease")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(EF.cobalt)
                            .frame(minHeight: 49)
                    }

                    EFSection(title: L10n.text("MOVEMENTS", "OEFENINGEN"),
                              detail: "\(results.count)")
                    ForEach(Array(results.enumerated()), id: \.element.id) { i, ex in
                        let chosen = selectedIDs.contains(ex.id)
                        Button {
                            if chosen {
                                selectedIDs.removeAll { $0 == ex.id }
                            } else {
                                selectedIDs.append(ex.id)
                                ExerciseShortcutStore.recordRecent(ex.id)
                            }
                            Haptics.light()
                        } label: {
                            HStack(spacing: 12) {
                                Text(String(format: "%02d", i + 1))
                                    .font(.system(size: 19, weight: .black))
                                    .foregroundStyle(EF.cobalt)
                                    .frame(width: 30, alignment: .leading)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(ex.name.uppercased())
                                        .font(.system(size: 12, weight: .heavy))
                                        .foregroundStyle(EF.ink)
                                    Text(ex.muscle + " • " + ex.equipment)
                                        .font(.caption)
                                        .foregroundStyle(EF.faint)
                                }
                                Spacer()
                                Image(systemName: chosen ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(chosen ? EF.cobalt : EF.rule)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(chosen ? .isSelected : [])
                        EFRule()
                    }
                }
                .padding(24)
                .padding(.bottom, 25)
            }
            .background(EF.paper)
            .navigationTitle(L10n.addExercise)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text("Cancel", "Annuleren")) {
                        selectedIDs = []
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                EFAction(title: selectedIDs.isEmpty ?
                         L10n.done :
                         L10n.text("ADD", "VOEG TOE") + " \(selectedIDs.count)",
                         symbol: "checkmark") {
                    dismiss()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(EF.paper)
            }
        }
        
        .tint(EF.cobalt)
    }
}
