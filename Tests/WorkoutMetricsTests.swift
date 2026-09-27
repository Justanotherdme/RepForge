import XCTest
@testable import RepForge

final class WorkoutMetricsTests: XCTestCase {
    func testEstimated1RM() {
        XCTAssertEqual(WorkoutMetrics.estimated1RM(weightKg: 100, reps: 1), 100, accuracy: 0.001)
        XCTAssertEqual(WorkoutMetrics.estimated1RM(weightKg: 100, reps: 10), 133.333, accuracy: 0.01)
    }
}
