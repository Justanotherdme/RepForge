import SwiftUI
import SwiftData

struct EFProfile: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var showSettings = false
    @State private var showAdvanced = false
    @State private var showGym = false
    @State private var showMeasurements = false
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID
    private var progress: ForgeProgress { ForgeProgress(sessions: sessions) }
    private var unlocked: Int { progress.milestones.filter(\.unlocked).count }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 23) {
                        EFEyebrow(value: "04 / ATHLETE FILE", light: true)
                        EFTitle(lines: L10n.text("YOUR|STORY.", "JOUW|VERHAAL.").components(separatedBy: "|"), highlight: -1, inverted: true)
                        Text(L10n.text("Built, not bought.", "Verdiend, niet gekocht."))
                            .font(.subheadline).foregroundStyle(EF.ice)
                        HStack(spacing: 23) {
                            stat("\(progress.level)", "LEVEL")
                            stat("\(progress.points)", "XP EARNED")
                            stat("\(progress.weeklyStreak)", "WEEK STREAK")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .padding(.top, 17)
                    .background(EF.night)

                    VStack(alignment: .leading, spacing: 20) {
                        EFSection(title: L10n.text("MILESTONES", "MIJLPALEN"),
                                  detail: "\(unlocked) / \(progress.milestones.count) UNLOCKED")
                        ForEach(Array(progress.milestones.enumerated()), id: \.element.id) { index, badge in
                            HStack(spacing: 13) {
                                Image(systemName: badge.symbol)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(badge.unlocked ? .white : EF.ice)
                                    .frame(width: 52, height: 52)
                                    .background(badge.unlocked ? EF.cobalt : EF.ink)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(badge.title.uppercased())
                                        .font(.system(size: 13, weight: .heavy))
                                        .foregroundStyle(EF.ink)
                                    if badge.unlocked {
                                        Text(L10n.text("Unlocked", "Behaald"))
                                            .font(.caption).foregroundStyle(EF.faint)
                                    } else {
                                        ProgressView(value: badge.progress).tint(EF.cobalt)
                                    }
                                }
                                Spacer(minLength: 4)
                                Text(badge.unlocked ? "✓" : "\(badge.current) / \(badge.target)")
                                    .foregroundStyle(EF.cobalt)
                                    .font(.caption.bold())
                            }
                            .padding(.vertical, 7)
                            EFRule()
                        }
                        EFSection(title: L10n.text("CONTROL CENTER", "INSTELLINGEN"))
                            .padding(.top, 10)
                        controlRow(1, title: L10n.text("Settings & accessibility", "Instellingen en toegankelijkheid"),
                                   description: "DISPLAY • TEXT • REDUCED MOTION") { showSettings = true }
                        controlRow(2, title: L10n.text("Your data & backups", "Gegevens en back-ups"),
                                   description: "EXPORT • IMPORT • PRIVACY") { showSettings = true }
                        controlRow(3, title: L10n.text("Gyms & measurements", "Gyms en metingen"),
                                   description: "BODY RECORDS • TRAINING LOCATIONS") { showAdvanced = true }
                        controlRow(4, title: L10n.text("Detailed athlete profile", "Uitgebreid profiel"),
                                   description: "PERSONAL BESTS • PROGRESSION") { showAdvanced = true }
                    }
                    .padding(24)
                }
            }
            .background(EF.paper)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.done) { dismiss() }.foregroundStyle(EF.cobalt)
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showAdvanced) { ProfileView() }
        }
    }
    private func stat(_ number: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(number).font(.system(size: 23, weight: .heavy)).foregroundStyle(.white)
            Text(label).font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(EF.ice)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func controlRow(_ index: Int, title: String, description: String,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            EFNumberRow(order: index, title: title, detail: description)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { EFRule() }
    }
}
