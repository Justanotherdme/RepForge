import ActivityKit
import WidgetKit
import SwiftUI

@main
struct RepForgeLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        RepForgeRestTimerLiveActivity()
    }
}

struct RepForgeRestTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.18))
                    Image(systemName: "timer")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 3) {
                    Text("RepForge Rest")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(context.state.exerciseName.isEmpty ? context.attributes.workoutTitle : context.state.exerciseName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(
                            timerInterval: context.state.endDate.addingTimeInterval(-TimeInterval(context.state.totalSeconds))...context.state.endDate,
                            countsDown: true
                        )
                        .font(.title2.monospacedDigit().bold())
                        .foregroundStyle(.blue)
                }

                Spacer()

                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.92))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .font(.headline.bold())
                        .foregroundStyle(.blue)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.exerciseName.isEmpty ? context.attributes.workoutTitle : context.state.exerciseName)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(
                        timerInterval: context.state.endDate.addingTimeInterval(-TimeInterval(context.state.totalSeconds))...context.state.endDate,
                        countsDown: true
                    )
                    .font(.subheadline.monospacedDigit().bold())
                    .foregroundStyle(.blue)
                }
            } compactLeading: {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2.5)
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 27, height: 27)
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                    .fixedSize()
            } minimal: {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 22, height: 22)
            }
            .widgetURL(URL(string: "repforge://workout"))
            .keylineTint(.blue)
        }
    }
}
