import SwiftUI
import SwiftData

// Shared editorial surfaces for the distinct account and training destinations.
struct EFPageHeading: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .tracking(-1.3)
                .foregroundStyle(EF.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(EF.faint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EFLinkTile: View {
    let symbol: String
    let title: String
    let subtitle: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(EF.cobalt)
                .frame(width: 48, height: 48)
                .background(EF.cobalt.opacity(0.09), in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.bold)).foregroundStyle(EF.ink)
                Text(subtitle).font(.caption).foregroundStyle(EF.faint)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 5)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold)).foregroundStyle(EF.faint)
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(EF.rule.opacity(0.65)))
        .contentShape(RoundedRectangle(cornerRadius: 17))
    }
}

struct EFInfoTile: View {
    let label: String
    let value: String
    let symbol: String
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol).foregroundStyle(EF.cobalt)
            Text(value).font(.headline.bold()).foregroundStyle(EF.ink).lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label).font(.caption2).foregroundStyle(EF.faint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(EF.rule.opacity(0.55)))
    }
}

struct EFSettingsHub: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                EFPageHeading(title: L10n.text("Settings", "Instellingen"),
                              subtitle: L10n.text("Your preferences, organized.", "Jouw voorkeuren, overzichtelijk."))
                EFEyebrow(value: "PREFERENCES").padding(.top, 16)
                NavigationLink {
                    SettingsView(mode: .preferences)
                } label: {
                    EFLinkTile(symbol: "slider.horizontal.3", title: L10n.settings,
                               subtitle: "Language, units, theme, workout defaults")
                }
                NavigationLink {
                    EFAccessibilityPage()
                } label: {
                    EFLinkTile(symbol: "accessibility", title: "Accessibility",
                               subtitle: "Text size, contrast, feedback and motion")
                }
                EFEyebrow(value: "YOUR DATA").padding(.top, 13)
                NavigationLink {
                    SettingsView(mode: .data)
                } label: {
                    EFLinkTile(symbol: "externaldrive", title: "Data & Backup",
                               subtitle: "Full backups, restore, CSV export and import")
                }
                EFEyebrow(value: "TRAINING").padding(.top, 13)
                NavigationLink {
                    EFGymPage()
                } label: {
                    EFLinkTile(symbol: "dumbbell", title: "Gym",
                               subtitle: "Gym locations and gym-specific records")
                }
            }
            .padding(20)
            .padding(.bottom, 60)
        }
        .background(EF.paper)
        .navigationTitle(L10n.settings)
        .navigationBarTitleDisplayMode(.inline)
        .tint(EF.cobalt)
    }
}

struct EFAccessibilityPage: View {
    @AppStorage("textSize") private var textSize = "standard"
    @AppStorage("highContrastWorkout") private var highContrast = false
    @AppStorage("compactWorkoutMode") private var compact = false
    @AppStorage("hapticsEnabled") private var haptics = true
    @AppStorage("keepScreenAwake") private var screenAwake = true

    var body: some View {
        Form {
            Section {
                Picker(L10n.text("Text size", "Tekstgrootte"), selection: $textSize) {
                    Text("Compact").tag("compact")
                    Text("Standard").tag("standard")
                    Text("Large").tag("large")
                    Text("Extra large").tag("xlarge")
                }
                Toggle("High-contrast workout cards", isOn: $highContrast)
                Toggle("Compact workout layout", isOn: $compact)
            } header: { Text("Display") }
            Section {
                Toggle("Haptic feedback", isOn: $haptics)
                Toggle("Keep screen awake during workout", isOn: $screenAwake)
            } header: { Text("Interaction") }
            Section {
                Text("RepForge respects iOS Reduce Motion and Dynamic Type where supported.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(EF.paper)
        .navigationTitle("Accessibility")
        .tint(EF.cobalt)
    }
}

struct EFGymPage: View {
    @AppStorage("activeGymID") private var gymID = GymProfileStore.defaultID
    @AppStorage("gymRevision") private var revision = 0
    @AppStorage("separateRecordsByGym") private var separateRecords = true
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    private var selected: GymProfile { GymProfileStore.profile(id: gymID) }
    private var completedCount: Int {
        sessions.filter { $0.endedAt != nil && GymProfileStore.sessionGymID($0) == gymID }.count
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                EFPageHeading(title: "Gym", subtitle: "Manage training locations and records.")
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.largeTitle).foregroundStyle(EF.cobalt)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selected.name).font(.title3.bold()).foregroundStyle(EF.ink)
                            Text(selected.note.isEmpty ? "Active training location" : selected.note)
                                .font(.caption).foregroundStyle(EF.faint)
                        }
                        Spacer()
                        Text("CURRENT").font(.caption2.bold()).foregroundStyle(EF.cobalt)
                    }
                    HStack(spacing: 10) {
                        EFInfoTile(label: "Sessions", value: "\(completedCount)", symbol: "figure.strengthtraining.traditional")
                        EFInfoTile(label: "Locations", value: "\(GymProfileStore.load().count)", symbol: "building.2")
                    }
                }
                .padding(15)
                .background(EF.surface, in: RoundedRectangle(cornerRadius: 18))
                EFEyebrow(value: "YOUR GYMS").padding(.top, 15)
                ForEach(GymProfileStore.load()) { gym in
                    Button {
                        gymID = gym.id
                    } label: {
                        HStack {
                            EFLinkTile(symbol: gym.id == gymID ? "checkmark.circle.fill" : "building.2",
                                       title: gym.name, subtitle: gym.note.isEmpty ? "Training location" : gym.note)
                        }
                    }
                    .buttonStyle(.plain)
                }
                NavigationLink {
                    GymManagerView(activeGymID: $gymID)
                } label: {
                    EFLinkTile(symbol: "plus.circle", title: "Manage gym locations",
                               subtitle: "Create, edit, switch or delete a gym")
                }
                EFEyebrow(value: "RECORDS").padding(.top, 12)
                Toggle("Separate personal records by gym", isOn: $separateRecords)
                    .tint(EF.cobalt)
                    .padding(17)
                    .background(EF.surface, in: RoundedRectangle(cornerRadius: 17))
            }
            .padding(20)
            .padding(.bottom, 55)
        }
        .id(revision)
        .background(EF.paper)
        .navigationTitle("Gym")
        .navigationBarTitleDisplayMode(.inline)
        .tint(EF.cobalt)
    }
}

struct EFMeasurementsPage: View {
    @Query(sort: \BodyMeasurement.date, order: .reverse) private var measurements: [BodyMeasurement]
    @Query private var profiles: [UserProfile]
    @State private var editing = false
    private var latest: BodyMeasurement? { measurements.first }
    private func length(_ value: Double?) -> String {
        guard let value, value > 0 else { return "—" }
        return "\(AppPreferences.displayHeight(value).formatted(.number.precision(.fractionLength(0...1)))) \(AppPreferences.heightLabel)"
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                EFPageHeading(title: "Measurements", subtitle: "Your body data and progress over time.")
                HStack(spacing: 8) {
                    EFInfoTile(label: "Weight", value: latest.map {
                        "\(AppPreferences.displayWeight($0.bodyWeightKg).formatted(.number.precision(.fractionLength(0...1)))) \(AppPreferences.weightLabel)"
                    } ?? "—", symbol: "scalemass")
                    EFInfoTile(label: "Body fat", value: latest?.bodyFatPercent.map {
                        "\($0.formatted(.number.precision(.fractionLength(0...1))))%"
                    } ?? "—", symbol: "percent")
                    EFInfoTile(label: "Waist", value: length(latest?.waistCm), symbol: "ruler")
                }
                BodyMeasurementsCard(measurements: measurements) { editing = true }
                EFEyebrow(value: "MEASUREMENT HISTORY").padding(.top, 10)
                if measurements.isEmpty {
                    Text("No measurements logged yet. Add your first entry to get started.")
                        .foregroundStyle(EF.faint)
                }
                ForEach(measurements.prefix(30)) { measurement in
                    HStack(spacing: 10) {
                        Image(systemName: "calendar").foregroundStyle(EF.cobalt)
                        Text(measurement.date.formatted(date: .abbreviated, time: .omitted))
                        Spacer()
                        Text("\(AppPreferences.displayWeight(measurement.bodyWeightKg).formatted(.number.precision(.fractionLength(0...1)))) \(AppPreferences.weightLabel)")
                    }
                    .font(.subheadline)
                    .padding(15)
                    .background(EF.surface, in: RoundedRectangle(cornerRadius: 13))
                }
            }
            .padding(20)
            .padding(.bottom, 70)
        }
        .background(EF.paper)
        .navigationTitle("Measurements")
        .navigationBarTitleDisplayMode(.inline)
        .tint(EF.cobalt)
        .sheet(isPresented: $editing) {
            if let profile = profiles.first {
                BodyMeasurementEditorView(profile: profile)
            }
        }
    }
}

struct EFAthleteDetailsPage: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var editing = false
    private var profile: UserProfile? { profiles.first }
    private var completed: [WorkoutSession] { sessions.filter { $0.endedAt != nil } }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 17) {
                EFPageHeading(title: "Athlete Details",
                              subtitle: "Personal profile, training identity and goals.")
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 49)).foregroundStyle(EF.cobalt)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(profile?.displayName ?? "Athlete")
                                .font(.title2.bold()).foregroundStyle(EF.ink)
                            Text(profile?.bio ?? "Consistency compounds.")
                                .font(.caption).foregroundStyle(EF.faint)
                        }
                        Spacer()
                    }
                    HStack(spacing: 9) {
                        EFInfoTile(label: "Sessions", value: "\(completed.count)", symbol: "checkmark.circle")
                        EFInfoTile(label: "Training gyms", value: "\(GymProfileStore.load().count)", symbol: "building.2")
                    }
                    Button {
                        editing = true
                    } label: {
                        Label("Edit athlete profile", systemImage: "pencil")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(EF.cobalt)
                }
                .padding(16)
                .background(EF.surface, in: RoundedRectangle(cornerRadius: 18))
                EFEyebrow(value: "PERSONAL INFORMATION")
                EFInfoLine(label: "Name", value: profile?.displayName ?? "Athlete")
                EFInfoLine(label: "Body weight", value: profile.map {
                    "\(AppPreferences.displayWeight($0.bodyWeightKg).formatted(.number.precision(.fractionLength(0...1)))) \(AppPreferences.weightLabel)"
                } ?? "—")
                EFInfoLine(label: "Height", value: profile.map {
                    "\(AppPreferences.displayHeight($0.heightCm).formatted(.number.precision(.fractionLength(0...1)))) \(AppPreferences.heightLabel)"
                } ?? "—")
                EFEyebrow(value: "PERFORMANCE").padding(.top, 12)
                NavigationLink {
                    HistoryView()
                } label: {
                    EFLinkTile(symbol: "trophy", title: "Workout history & records",
                               subtitle: "Personal bests, history and completed sessions")
                }
                NavigationLink {
                    ProfileView()
                } label: {
                    EFLinkTile(symbol: "chart.xyaxis.line", title: "Advanced athlete analytics",
                               subtitle: "Muscle volume, recovery and progress insights")
                }
            }
            .padding(20)
            .padding(.bottom, 60)
        }
        .background(EF.paper)
        .navigationTitle("Athlete Details")
        .navigationBarTitleDisplayMode(.inline)
        .tint(EF.cobalt)
        .sheet(isPresented: $editing) {
            if let profile { EditProfileView(profile: profile) }
        }
    }
}

struct EFInfoLine: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(EF.ink)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(EF.cobalt)
                .lineLimit(2).minimumScaleFactor(0.8)
        }
        .padding(17)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}
