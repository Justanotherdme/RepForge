import Foundation
import ActivityKit

struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var totalSeconds: Int
        var exerciseName: String
    }

    var workoutTitle: String
}
