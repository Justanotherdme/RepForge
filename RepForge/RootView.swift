import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @State private var selectedTab = 2

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView().tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }.tag(0)
            HistoryView().tabItem { Label("History", systemImage: "clock.fill") }.tag(1)
            StartWorkoutView().tabItem { Label("Workout", systemImage: "plus.circle.fill") }.tag(2)
            ExerciseLibraryView().tabItem { Label("Exercises", systemImage: "dumbbell.fill") }.tag(3)
        }
        .tint(AppTheme.accent)
        .preferredColorScheme(.dark)
        .task { ensureProfile() }
    }

    private func ensureProfile() {
        guard profiles.isEmpty else { return }
        context.insert(UserProfile(displayName: "Athlete"))
        try? context.save()
    }
}
