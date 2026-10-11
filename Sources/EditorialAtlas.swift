import SwiftUI
import SwiftData

/// The approved Atlas uses the original AnatomicalMuscleHeatmap.swift renderer,
/// shading palette and MuscleAnalytics data without modifying anatomical geometry.
struct EFAtlas: View {
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var recoveryMode = false
    @State private var period = 0
    @State private var showHistory = false
    @State private var selectedMuscle: String?
    @AppStorage("separateRecordsByGym") private var separateByGym = true
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID

    private var scoped: [WorkoutSession] {
        sessions.filter {
            $0.endedAt != nil && (!separateByGym || GymProfileStore.sessionGymID($0) == gymID)
        }
    }
    private var volume: [MuscleVolumeEntry] {
        switch period {
        case 1: return MuscleAnalytics.weeklyVolume(sessions: scoped, weeksBack: 1)
        case 2:
            return MuscleAnalytics.volume(
                sessions: scoped,
                since: Calendar.current.date(byAdding: .day, value: -28, to: .now) ?? .distantPast
            )
        default: return MuscleAnalytics.weeklyVolume(sessions: scoped)
        }
    }
    private var recovery: [MuscleRecoveryEntry] {
        MuscleAnalytics.recovery(sessions: scoped)
    }
    private var intensity: [String: Double] {
        var mapped: [String: Double] = [:]
        if recoveryMode {
            for item in recovery {
                mapped[item.muscle] = max(0, min(1, 1 - item.recovery))
            }
        } else {
            for item in volume {
                mapped[item.muscle] = max(0, min(1, item.sets / 12))
            }
        }
        return mapped
    }
    private var breakdown: [(name: String, amount: Double, description: String)] {
        if recoveryMode {
            return recovery.map {
                (name: $0.muscle, amount: 1 - $0.recovery,
                 description: "\(Int($0.recovery * 100))% EST. RECOVERY")
            }.sorted { $0.amount > $1.amount }
        }
        return volume.map {
            (name: $0.muscle, amount: $0.sets,
             description: $0.sets.formatted(
                .number.precision(.fractionLength(0...1))
             ) + " EFFECTIVE SETS")
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                HStack {
                    EFEyebrow(value: "03 / THE ATLAS")
                    Spacer()
                    EFEyebrow(value: "LIVE TRAINING DATA")
                }
                .padding(.top, 10)
                VStack(alignment: .leading, spacing: -7) {
                    Text(L10n.text("SEE THE", "ZIE JE"))
                        .foregroundStyle(EF.ink)
                    Text(L10n.text("WORK.", "INZET."))
                        .foregroundStyle(EF.cobalt)
                }
                .font(.system(size: 47, weight: .black, design: .rounded))
                .tracking(-2)
                .accessibilityElement(children: .combine)
                Text(L10n.text("Your original anatomical muscle map, powered by logged sets.",
                               "De originele anatomische spierkaart, gebaseerd op gelogde sets."))
                    .font(.subheadline).foregroundStyle(EF.faint)
                HStack(spacing: 7) {
                    atlasToggle(L10n.text("TRAINING LOAD", "BELASTING"), selected: !recoveryMode) {
                        recoveryMode = false
                    }
                    atlasToggle(L10n.text("RECOVERY", "HERSTEL"), selected: recoveryMode) {
                        recoveryMode = true
                    }
                }
                if !recoveryMode {
                    HStack(spacing: 6) {
                        periodToggle(L10n.text("THIS WEEK", "DEZE WEEK"), id: 0)
                        periodToggle(L10n.text("LAST WEEK", "VORIGE WEEK"), id: 1)
                        periodToggle("28 DAYS", id: 2)
                    }
                }
                bodyMap
                MuscleHeatLegend().padding(.horizontal, 5)
                Text(recoveryMode
                     ? L10n.text("Shading estimates residual fatigue; not a medical measurement.",
                                  "Kleuring schat restvermoeidheid en is geen medische meting.")
                     : L10n.text("Brighter shading means more effective logged sets, capped at 12 for display.",
                                  "Helderder gekleurd betekent meer effectieve sets, visueel tot 12 begrensd."))
                    .font(.caption).foregroundStyle(EF.faint)
                EFSection(title: "MUSCLE BREAKDOWN", detail: "\(breakdown.count) GROUPS")
                    .padding(.top, 12)
                breakdownList
                EFSection(title: "90-DAY CONSISTENCY")
                    .padding(.top, 12)
                WorkoutActivityHeatmap(sessions: scoped, lightStyle: true)
                Button { showHistory = true } label: {
                    EFLinkTile(symbol: "trophy", title: L10n.text("Full history & personal records",
                                                                 "Geschiedenis en records"),
                               subtitle: "See every completed session and personal best")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 19)
            .padding(.top, 23)
            .padding(.bottom, 110)
        }
        .background(EF.paper)
        .environment(\.colorScheme, .light)
        .sheet(isPresented: $showHistory) { HistoryView() }
    }

    private var bodyMap: some View {
        VStack(alignment: .leading, spacing: 12) {
            EFEyebrow(value: recoveryMode ? "ESTIMATED FATIGUE" : "EFFECTIVE SETS")
            HStack(alignment: .top, spacing: 12) {
                BodyMuscleFigure(side: .front, intensity: intensity)
                BodyMuscleFigure(side: .back, intensity: intensity)
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(EF.cobalt.opacity(0.055), in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(EF.cobalt.opacity(0.12)))
    }

    private var breakdownList: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if breakdown.isEmpty {
                Text("Complete a workout to light up your muscle map.")
                    .font(.subheadline).foregroundStyle(EF.faint)
                    .padding(16)
            }
            ForEach(Array(breakdown.prefix(20).enumerated()), id: \.offset) { index, item in
                Button {
                    selectedMuscle = selectedMuscle == item.name ? nil : item.name
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 11) {
                            Text(String(format: "%02d", index + 1))
                                .font(.caption.bold()).foregroundStyle(EF.cobalt)
                                .frame(width: 28, alignment: .leading)
                            Text(item.name)
                                .font(.subheadline.bold()).foregroundStyle(EF.ink)
                            Spacer()
                            Text(item.description)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(EF.faint)
                        }
                        if selectedMuscle == item.name {
                            Text(recoveryMode
                                 ? "Estimated from recent sessions and elapsed time; not medical advice."
                                 : "Weighted contributions from primary and assisting muscles.")
                                .font(.caption).foregroundStyle(EF.faint)
                        }
                        EFRule()
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func atlasToggle(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(selected ? .white : EF.ink)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(selected ? EF.cobalt : EF.cobalt.opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
    private func periodToggle(_ title: String, id: Int) -> some View {
        Button { period = id } label: {
            Text(title).font(.system(size: 10, weight: .heavy))
                .foregroundStyle(period == id ? .white : EF.ink)
                .frame(maxWidth: .infinity, minHeight: 45)
                .background(period == id ? EF.cobalt : EF.cobalt.opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
