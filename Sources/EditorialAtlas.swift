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
            LazyVStack(alignment: .leading, spacing: 21) {
                HStack {
                    EFEyebrow(value: "03 / THE ATLAS", light: true)
                    Spacer()
                    Text(L10n.text("LIVE TRAINING DATA", "TRAININGSGEGEVENS"))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(EF.ice)
                }
                .padding(.top, 21)

                EFTitle(lines: L10n.text("SEE THE|WORK.", "ZIE JE|INZET.").components(separatedBy: "|"), inverted: true)
                Text(L10n.text("Your original anatomical muscle map, powered by logged sets.",
                                "De originele anatomische spierkaart, gebaseerd op gelogde sets."))
                    .font(.subheadline)
                    .foregroundStyle(EF.ice.opacity(0.74))
                    .padding(.top, -2)

                HStack(spacing: 7) {
                    atlasToggle(L10n.text("TRAINING LOAD", "BELASTING"), selected: !recoveryMode) {
                        recoveryMode = false
                    }
                    atlasToggle(L10n.text("RECOVERY", "HERSTEL"), selected: recoveryMode) {
                        recoveryMode = true
                    }
                }
                .padding(.top, 4)

                if !recoveryMode {
                    HStack(spacing: 6) {
                        periodToggle(L10n.text("THIS WEEK", "DEZE WEEK"), id: 0)
                        periodToggle(L10n.text("LAST WEEK", "VORIGE WEEK"), id: 1)
                        periodToggle("28 DAYS", id: 2)
                    }
                }

                HStack {
                    EFEyebrow(value: "FRONT", light: true)
                    Spacer()
                    EFEyebrow(value: recoveryMode ? "ESTIMATED FATIGUE" : "EFFECTIVE SETS",
                              light: true)
                    Spacer()
                    EFEyebrow(value: "BACK", light: true)
                }

                HStack(alignment: .top, spacing: 12) {
                    BodyMuscleFigure(side: .front, intensity: intensity)
                    BodyMuscleFigure(side: .back, intensity: intensity)
                }
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background {
                    RadialGradient(
                        colors: [EF.ice.opacity(0.14), .clear],
                        center: .center, startRadius: 12, endRadius: 240
                    )
                }

                MuscleHeatLegend()
                Text(recoveryMode
                     ? L10n.text("Brighter shading means higher estimated residual fatigue.",
                                  "Helderder gekleurd betekent meer geschatte restvermoeidheid.")
                     : L10n.text("Brighter shading means more effective logged sets, capped at 12 for display.",
                                  "Helderder gekleurd betekent meer effectieve sets, visueel tot 12 begrensd."))
                    .font(.caption)
                    .foregroundStyle(EF.ice.opacity(0.74))

                EFSection(title: "MUSCLE BREAKDOWN", detail: "\(breakdown.count) GROUPS ↗", dark: true)
                    .padding(.top, 4)
                ForEach(Array(breakdown.prefix(20).enumerated()), id: \.offset) { index, item in
                    Button {
                        selectedMuscle = selectedMuscle == item.name ? nil : item.name
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(spacing: 12) {
                                Text(String(format: "%02d", index + 1))
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundStyle(index.isMultiple(of: 2) ? EF.orange : EF.ice)
                                    .frame(width: 23, alignment: .leading)
                                Text(item.name.uppercased())
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundStyle(EF.white)
                                Spacer()
                                Text(item.description)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(EF.ice)
                            }
                            if selectedMuscle == item.name {
                                Text(recoveryMode
                                     ? L10n.text("Estimated from recent sessions and elapsed time, not a medical reading.",
                                                  "Schatting op basis van trainingen en tijd, geen medische meting.")
                                     : L10n.text("Weighted contributions from primary and assisting muscles.",
                                                  "Gewogen bijdrage van primaire en ondersteunende spieren."))
                                    .font(.caption)
                                    .foregroundStyle(EF.ice)
                            }
                            EFRule(dark: true)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                }

                EFSection(title: "90-DAY CONSISTENCY", detail: "↗", dark: true)
                    .padding(.top, 12)
                WorkoutActivityHeatmap(sessions: scoped)
                    .environment(\.colorScheme, .dark)
                Button { showHistory = true } label: {
                    HStack {
                        Text(L10n.text("FULL HISTORY & PERSONAL RECORDS",
                                        "TRAININGSGESCHIEDENIS EN RECORDS"))
                            .font(.system(size: 12, weight: .heavy))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .frame(minHeight: 54)
                    .foregroundStyle(EF.ice)
                    .overlay(alignment: .bottom) { EFRule(dark: true) }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 32)
        }
        .background(EF.night)
        .environment(\.colorScheme, .dark)
        .sheet(isPresented: $showHistory) { HistoryView() }
    }

    private func atlasToggle(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(selected ? EF.ink : EF.ice)
                .padding(.horizontal, 13)
                .frame(minHeight: 46)
                .background(selected ? EF.ice : .clear)
                .overlay(Rectangle().stroke(EF.ice.opacity(0.4)))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
    private func periodToggle(_ title: String, id: Int) -> some View {
        Button { period = id } label: {
            Text(title).font(.system(size: 10, weight: .heavy))
                .foregroundStyle(period == id ? EF.ink : EF.ice)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(period == id ? EF.ice : .clear)
                .overlay(Rectangle().stroke(EF.ice.opacity(0.25)))
        }
        .buttonStyle(.plain)
    }
}
