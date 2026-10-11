import SwiftUI
import SwiftData

struct EFHome: View {
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    let start: () -> Void
    let profile: () -> Void
    let openPlans: () -> Void
    let selectPlan: (CoachWorkout) -> Void
    private var complete: [WorkoutSession] { sessions.filter { $0.endedAt != nil } }
    private var stats: ForgeProgress { ForgeProgress(sessions: sessions) }
    private var thisMonth: Int {
        complete.filter { Calendar.current.isDate($0.startedAt, equalTo: .now, toGranularity: .month) }.count
    }
    private var days: [Date] {
        let cal = Calendar.current
        let monday = cal.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 0) {
                            Text("REP").foregroundStyle(EF.ink)
                            Text("FORGE").foregroundStyle(EF.cobalt)
                            Text(" / LAB").foregroundStyle(EF.ink)
                        }
                        .font(.system(size: 15, weight: .black))
                        .tracking(-0.65)
                        EFEyebrow(value: "TRAINING, WITHOUT FRICTION.")
                    }
                    Spacer()
                    Button(action: profile) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundStyle(EF.ink)
                            .frame(width: 46, height: 46)
                            .overlay(Circle().stroke(EF.rule))
                    }
                    .accessibilityLabel(L10n.profile)
                }
                .padding(.bottom, 38)

                EFEyebrow(value: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                EFTitle(lines: L10n.text("MAKE|IT COUNT.", "MAAK HET|WAAR.").components(separatedBy: "|"))
                    .padding(.top, 14)
                Text(L10n.text("Your next workout should be the easiest decision of your day.",
                               "Je volgende training moet de makkelijkste keuze van vandaag zijn."))
                    .font(.subheadline)
                    .foregroundStyle(EF.faint)
                    .padding(.top, 16)
                    .padding(.bottom, 25)

                hero

                VStack(alignment: .leading, spacing: 16) {
                    EFSection(title: L10n.text("The work adds up.", "Elke training telt."),
                              detail: L10n.text("This week ↗", "Deze week ↗"))
                    activityDays
                    HStack {
                        Text("\(weeklyCount) " + L10n.text("training days", "trainingsdagen"))
                        Spacer()
                        Text(weeklyCount > 0 ? L10n.text("ON TRACK", "GOED BEZIG") :
                             L10n.text("START TODAY", "BEGIN VANDAAG"))
                            .foregroundStyle(EF.cobalt)
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(0.5)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 14) {
                    Button(action: openPlans) {
                        HStack {
                            EFSection(title: L10n.text("Your playbook", "Jouw trainingen"))
                            Spacer(minLength: 3)
                            Text("EXPLORE ↗")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(EF.ink)
                                .padding(9)
                                .overlay(Rectangle().stroke(EF.ink))
                        }
                    }
                    .buttonStyle(.plain)
                    ForEach(Array(CoachWorkoutLibrary.all.prefix(3).enumerated()), id: \.element.id) { index, workout in
                        Button { selectPlan(workout) } label: {
                            EFNumberRow(order: index + 1, title: workout.name,
                                        detail: "~\(workout.estimatedMinutes) MIN • \(workout.exercises.count) EXERCISES")
                        }
                        .buttonStyle(.plain)
                        EFRule()
                    }
                }
                .padding(.top, 34)
                .padding(.bottom, 25)
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .background(EF.paper)
        }
        .background(EF.paper)
        .scrollIndicators(.hidden)
    }

    private var weeklyCount: Int {
        let cal = Calendar.current
        return Set(complete.filter {
            cal.isDate($0.startedAt, equalTo: .now, toGranularity: .weekOfYear)
        }.map { cal.startOfDay(for: $0.startedAt) }).count
    }

    private var activityDays: some View {
        HStack(spacing: 6) {
            ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                let trained = complete.contains { Calendar.current.isDate($0.startedAt, inSameDayAs: day) }
                let today = Calendar.current.isDateInToday(day)
                VStack(spacing: 6) {
                    Text(["M","T","W","T","F","S","S"][i])
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(trained ? .white : EF.ink)
                }
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(trained ? EF.cobalt : EF.rule.opacity(0.48))
                .overlay(Rectangle().stroke(today ? EF.orange : .clear, lineWidth: 2))
                .accessibilityLabel(day.formatted(date: .abbreviated, time: .omitted) +
                                    (trained ? " trained" : " no workout"))
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                EFEyebrow(value: "TODAY'S MISSION • READY", light: true)
                Spacer()
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(EF.mint)
            }
            Text("BUILD MOMENTUM.")
                .font(.system(size: 27, weight: .black, design: .rounded))
                .tracking(-1.5)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
            Button(action: start) {
                HStack {
                    Text(L10n.text("START WORKOUT", "START TRAINING"))
                        .font(.system(size: 13, weight: .heavy))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.headline.weight(.heavy))
                }
                // The CTA stays on an intentionally light surface even in dark themes.
                // Semantic EF.ink becomes white in dark mode and disappears here.
                .foregroundStyle(Color(red: 0.043, green: 0.078, blue: 0.141))
                .padding(.horizontal, 16)
                .frame(minHeight: 57)
                .background(EF.white)
            }
            .buttonStyle(EFPressStyle())
            HStack(spacing: 0) {
                heroStat("\(stats.weeklyStreak)", "WEEK STREAK")
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 1, height: 34)
                heroStat(String(format: "%02d", thisMonth), "SESSIONS / MO")
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 1, height: 34)
                heroStat("LV.\(stats.level)", "PROGRESSION")
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(EF.cobalt)
        .overlay(alignment: .topTrailing) {
            Circle().stroke(.white.opacity(0.2), lineWidth: 1)
                .frame(width: 285, height: 285)
                .offset(x: 110, y: -170)
                .allowsHitTesting(false)
                .clipped()
        }
    }
    private func heroStat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Text(label).font(.system(size: 9, weight: .medium))
                .opacity(0.8).lineLimit(1).minimumScaleFactor(0.8)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
