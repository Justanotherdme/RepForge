import SwiftUI

struct EFIndex: View {
    @State private var query = ""
    @State private var equipment = "All"
    @State private var muscle = "All"
    @State private var showCreate = false
    @State private var showManage = false
    @State private var refresh = 0

    private var muscles: [String] {
        ["All"] + Array(Set(ExerciseCatalog.all.map(\.muscle))).sorted()
    }
    private var items: [ExerciseDefinition] {
        _ = refresh
        return ExerciseCatalog.all.filter {
            ExerciseSearch.matches($0, query: query) &&
            GymEquipmentFilter.matches($0, selected: equipment) &&
            (muscle == "All" || $0.muscle == muscle)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top) {
                        EFPageHeading(title: L10n.text("Exercise Index", "Oefeningen"),
                                      subtitle: L10n.text("Every movement, one place.",
                                                          "Alle oefeningen op één plek."))
                        Button { showCreate = true } label: {
                            Image(systemName: "plus")
                                .font(.headline.weight(.heavy))
                                .frame(width: 44, height: 44)
                                .background(EF.cobalt.opacity(0.09), in: Circle())
                        }
                        .accessibilityLabel(L10n.text("Create exercise", "Oefening toevoegen"))
                    }
                    searchField
                    filters
                    HStack {
                        Text("\(items.count) EXERCISES")
                            .font(.caption.weight(.bold)).foregroundStyle(EF.faint)
                        Spacer()
                    }
                    .padding(.top, 7)
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            row(exercise, number: index + 1)
                        }
                        .buttonStyle(.plain)
                    }
                    Button { showManage = true } label: {
                        Label(L10n.text("Manage custom exercises", "Beheer eigen oefeningen"),
                              systemImage: "square.and.pencil")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(EF.cobalt.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .tint(EF.cobalt)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 17)
                .padding(.top, 26)
                .padding(.bottom, 115)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(EF.paper)
            .toolbar(.hidden, for: .navigationBar)
            .tint(EF.cobalt)
            .sheet(isPresented: $showCreate, onDismiss: { refresh += 1 }) {
                CustomExerciseEditorView()
            }
            .sheet(isPresented: $showManage, onDismiss: { refresh += 1 }) {
                ExerciseLibraryView()
            }
        }
    }
    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").foregroundStyle(EF.faint)
            TextField(L10n.text("Find an exercise...", "Zoek een oefening..."), text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(EF.ink)
        }
        .padding(16)
        .background(EF.cobalt.opacity(0.055), in: RoundedRectangle(cornerRadius: 15))
    }
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                Menu {
                    ForEach(muscles, id: \.self) { option in
                        Button(option == "All" ? "All muscles" : option) { muscle = option }
                    }
                } label: {
                    chip(muscle == "All" ? "All muscles" : muscle, active: true)
                }
                Menu {
                    ForEach(GymEquipmentFilter.options, id: \.self) { option in
                        Button(option == "All" ? "All equipment" : option) {
                            equipment = option
                        }
                    }
                } label: {
                    chip(equipment == "All" ? "All equipment" : equipment, active: equipment != "All")
                }
                Button { showManage = true } label: { chip("My exercises", active: false) }
            }
        }
    }
    private func chip(_ title: String, active: Bool) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(active ? .white : EF.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 45)
            .background(active ? EF.cobalt : EF.cobalt.opacity(0.07),
                        in: RoundedRectangle(cornerRadius: 14))
    }
    private func row(_ exercise: ExerciseDefinition, number: Int) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Text(String(number))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(EF.cobalt)
                .frame(width: 31, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EF.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(exercise.muscle.uppercased()) • \(exercise.equipment.uppercased())")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(EF.faint)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold)).foregroundStyle(EF.ink)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 75, alignment: .leading)
        .padding(.vertical, 5)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(EF.rule.opacity(0.65)))
    }
}
