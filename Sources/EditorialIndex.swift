import SwiftUI

struct EFIndex: View {
    @State private var query = ""
    @State private var equipment = "All"
    @State private var showCreate = false
    @State private var showManage = false
    @State private var refresh = 0
    private var items: [ExerciseDefinition] {
        _ = refresh
        return ExerciseCatalog.all.filter {
            ExerciseSearch.matches($0, query: query) &&
            GymEquipmentFilter.matches($0, selected: equipment)
        }
    }
    private var featured: [ExerciseDefinition] {
        let keys = ["Converging Chest Press", "Cable Pulldown"]
        return keys.compactMap { ExerciseCatalog.findByName($0) }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            (
                                Text("REP").foregroundColor(EF.ink) +
                                Text("FORGE").foregroundColor(EF.cobalt) +
                                Text(" / INDEX").foregroundColor(EF.ink)
                            )
                            .font(.system(size: 15, weight: .black))
                            EFEyebrow(value: "EVERY MACHINE. EVERY MOVEMENT.")
                        }
                        Spacer()
                        Button { showCreate = true } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(EF.ink)
                                .frame(width: 46, height: 46)
                                .overlay(Circle().stroke(EF.rule))
                        }
                        .accessibilityLabel(L10n.text("Create exercise", "Oefening toevoegen"))
                    }
                    .padding(.bottom, 38)

                    EFTitle(lines: ["FIND YOUR", "MOVE."])
                    TextField(L10n.text("Search by machine or exercise ↗",
                                        "Zoek op apparaat of oefening ↗"), text: $query)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(EF.ink)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.vertical, 16)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(EF.ink).frame(height: 2)
                        }
                        .padding(.top, 25)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(GymEquipmentFilter.options, id: \.self) { option in
                                Button {
                                    equipment = option
                                } label: {
                                    Text(option.uppercased())
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundStyle(equipment == option ? .white : EF.ink)
                                        .padding(.horizontal, 12)
                                        .frame(minHeight: 44)
                                        .background(equipment == option ? EF.ink : .clear)
                                        .overlay(Rectangle().stroke(EF.rule))
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(equipment == option ? .isSelected : [])
                            }
                        }
                    }
                    .padding(.top, 17)
                    .padding(.bottom, 25)

                    EFSection(title: L10n.text("DISCOVER MOVEMENTS.", "ONTDEK OEFENINGEN."),
                              detail: "\(items.count) EXERCISES")
                    HStack(spacing: 9) {
                        ForEach(Array(featured.enumerated()), id: \.element.id) { i, ex in
                            NavigationLink {
                                ExerciseDetailView(exercise: ex)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: i == 0 ? "arrow.up.right" : "arrow.down.left")
                                        .font(.title2.weight(.heavy))
                                        .foregroundStyle(EF.cobalt)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    Spacer(minLength: 0)
                                    Text(ex.muscle.uppercased() + " / " + ex.equipment.uppercased())
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(EF.faint)
                                        .lineLimit(2)
                                    Text(ex.name.uppercased())
                                        .font(.system(size: 12, weight: .heavy))
                                        .foregroundStyle(EF.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
                                .padding(11)
                                .overlay(Rectangle().stroke(EF.rule))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 7)

                    ForEach(Array(items.enumerated()), id: \.element.id) { i, exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            EFNumberRow(order: i + 1, title: exercise.name,
                                        detail: "\(exercise.muscle) • \(exercise.equipment)" +
                                        (exercise.sourceID == nil ? "" : " • VIDEO"))
                        }
                        .buttonStyle(.plain)
                        EFRule()
                    }
                    Button { showManage = true } label: {
                        Label(L10n.text("Manage custom exercises", "Beheer eigen oefeningen"),
                              systemImage: "square.and.pencil")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .tint(EF.cobalt)
                    .padding(.top, 22)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 25)
            }
            .background(EF.paper)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCreate, onDismiss: { refresh += 1 }) {
                CustomExerciseEditorView()
            }
            .sheet(isPresented: $showManage, onDismiss: { refresh += 1 }) {
                ExerciseLibraryView()
            }
        }
    }
}
