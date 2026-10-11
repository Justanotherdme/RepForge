import SwiftUI
import SwiftData

struct EFProfile: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    private var progress: ForgeProgress { ForgeProgress(sessions: sessions) }
    private var unlocked: Int { progress.milestones.filter(\.unlocked).count }
    private var completed: Int { sessions.filter { $0.endedAt != nil }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    EFPageHeading(title: L10n.text("Profile", "Profiel"),
                                  subtitle: L10n.text("Your training, your story.",
                                                      "Jouw training, jouw verhaal."))
                    profileCard
                    EFEyebrow(value: "PROFILE & PROGRESS").padding(.top, 17)
                    NavigationLink {
                        EFGymPage()
                    } label: {
                        EFLinkTile(symbol: "dumbbell.fill", title: L10n.text("Gym", "Gym"),
                                   subtitle: "Training locations and record settings")
                    }
                    NavigationLink {
                        EFMeasurementsPage()
                    } label: {
                        EFLinkTile(symbol: "chart.xyaxis.line",
                                   title: L10n.text("Measurements", "Metingen"),
                                   subtitle: "Weight, body composition and trends")
                    }
                    NavigationLink {
                        EFAthleteDetailsPage()
                    } label: {
                        EFLinkTile(symbol: "person.crop.rectangle",
                                   title: L10n.text("Athlete Details", "Atleetgegevens"),
                                   subtitle: "Profile, performance and personal records")
                    }
                    EFEyebrow(value: "SETTINGS & DATA").padding(.top, 17)
                    NavigationLink {
                        EFSettingsHub()
                    } label: {
                        EFLinkTile(symbol: "gearshape",
                                   title: L10n.settings,
                                   subtitle: "Preferences, appearance and accessibility")
                    }
                    NavigationLink {
                        SettingsView(mode: .data)
                    } label: {
                        EFLinkTile(symbol: "externaldrive",
                                   title: L10n.text("Data & Backup", "Gegevens en back-ups"),
                                   subtitle: "Import, export and restore safely")
                    }
                    EFEyebrow(value: "MILESTONES").padding(.top, 17)
                    Text("\(unlocked) / \(progress.milestones.count) UNLOCKED")
                        .font(.caption.weight(.semibold)).foregroundStyle(EF.faint)
                    ForEach(progress.milestones) { badge in
                        HStack(spacing: 12) {
                            Image(systemName: badge.symbol)
                                .foregroundStyle(badge.unlocked ? EF.cobalt : EF.faint)
                                .frame(width: 38, height: 38)
                                .background(EF.cobalt.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(badge.title).font(.subheadline.bold()).foregroundStyle(EF.ink)
                                if !badge.unlocked {
                                    ProgressView(value: badge.progress).tint(EF.cobalt)
                                } else {
                                    Text("Unlocked").font(.caption2).foregroundStyle(EF.faint)
                                }
                            }
                            Spacer()
                        }
                        .padding(13)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(20)
                .padding(.bottom, 80)
            }
            .background(EF.paper)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.done) { dismiss() }.foregroundStyle(EF.cobalt)
                }
            }
            .tint(EF.cobalt)
        }
        .environment(\.colorScheme, .light)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(spacing: 13) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 55))
                    .foregroundStyle(EF.ice)
                VStack(alignment: .leading, spacing: 4) {
                    Text(profiles.first?.displayName ?? "Athlete")
                        .font(.title2.bold()).foregroundStyle(EF.white)
                    Text(profiles.first?.bio ?? "Consistency compounds.")
                        .font(.subheadline).foregroundStyle(EF.ice)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                stat("\(progress.level)", "LEVEL", "star.fill")
                stat("\(completed)", "SESSIONS", "dumbbell.fill")
                stat("\(progress.weeklyStreak)", "WEEK STREAK", "flame.fill")
            }
        }
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EF.night, in: RoundedRectangle(cornerRadius: 21))
    }
    private func stat(_ value: String, _ label: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).foregroundStyle(EF.orange)
            Text(value).font(.headline.bold()).foregroundStyle(EF.white)
            Text(label).font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(EF.ice)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
