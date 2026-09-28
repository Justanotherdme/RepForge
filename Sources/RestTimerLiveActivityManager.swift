import ActivityKit
import Foundation

enum RestTimerLiveActivityManager {
    @MainActor
    private static var currentActivity: Activity<RestTimerAttributes>?

    @MainActor
    static func startOrUpdate(
        workoutTitle: String,
        exerciseName: String,
        endDate: Date,
        totalSeconds: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let state = RestTimerAttributes.ContentState(
            endDate: endDate,
            totalSeconds: max(totalSeconds, 1),
            exerciseName: exerciseName
        )
        let content = ActivityContent(
            state: state,
            staleDate: endDate
        )

        if let activity = currentActivity ?? Activity<RestTimerAttributes>.activities.first {
            currentActivity = activity
            Task {
                await activity.update(content)
            }
            return
        }

        do {
            currentActivity = try Activity.request(
                attributes: RestTimerAttributes(workoutTitle: workoutTitle),
                content: content,
                pushType: nil
            )
        } catch {
            print("[RepForge] Could not start rest-timer Live Activity: \(error)")
        }
    }

    @MainActor
    static func end() {
        var activities = Activity<RestTimerAttributes>.activities

        if let currentActivity,
           !activities.contains(where: { $0.id == currentActivity.id }) {
            activities.append(currentActivity)
        }

        currentActivity = nil
        guard !activities.isEmpty else { return }

        Task {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
