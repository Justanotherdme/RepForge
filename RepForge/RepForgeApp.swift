import SwiftUI
import SwiftData

@main
struct RepForgeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutTemplate.self,
            TemplateExercise.self,
            WorkoutSession.self,
            ExerciseLog.self,
            WorkoutSet.self,
            UserProfile.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do { return try ModelContainer(for: schema, configurations: [configuration]) }
        catch { fatalError("Unable to create SwiftData store: \(error)") }
    }()

    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(sharedModelContainer)
    }
}
