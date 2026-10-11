import SwiftUI
import SwiftData
import UIKit

/// Approved six-screen concept: paper/ink/cobalt planning, ink/navy workout,
/// orange primary action. Design tokens are independent of old RFTheme cards.
enum EF {
    // Shared semantic palette. The app root observes these settings and
    // re-renders every editorial destination when the theme changes.
    static var dark: Bool {
        let choice = AppPreferences.appearance
        return choice == "dark" ||
            (choice == "system" && UITraitCollection.current.userInterfaceStyle == .dark)
    }

    static var paper: Color {
        guard dark else { return Color(red: 0.973, green: 0.978, blue: 0.974) }
        switch AppPreferences.themePreset {
        case "oled": return .black
        case "graphite", "slate": return Color(red: 0.10, green: 0.115, blue: 0.135)
        case "navy", "midnight": return Color(red: 0.025, green: 0.055, blue: 0.106)
        case "purple": return Color(red: 0.086, green: 0.055, blue: 0.136)
        case "forest", "emerald": return Color(red: 0.039, green: 0.089, blue: 0.078)
        case "orange": return Color(red: 0.12, green: 0.068, blue: 0.056)
        default: return Color(red: 0.055, green: 0.079, blue: 0.12)
        }
    }

    static var surface: Color {
        guard dark else { return .white }
        switch AppPreferences.themePreset {
        case "oled": return Color(red: 0.06, green: 0.06, blue: 0.065)
        case "graphite", "slate": return Color(red: 0.16, green: 0.18, blue: 0.205)
        case "navy", "midnight": return Color(red: 0.070, green: 0.115, blue: 0.18)
        case "purple": return Color(red: 0.15, green: 0.10, blue: 0.21)
        case "forest", "emerald": return Color(red: 0.07, green: 0.14, blue: 0.12)
        default: return Color(red: 0.102, green: 0.137, blue: 0.19)
        }
    }

    static var ink: Color {
        dark ? Color(red: 0.96, green: 0.975, blue: 1) :
               Color(red: 0.043, green: 0.078, blue: 0.141)
    }
    static var cobalt: Color {
        switch AppPreferences.themePreset {
        case "custom":
            switch UserDefaults.standard.string(forKey: "customAccent") ?? "blue" {
            case "purple": return Color(red: 0.60, green: 0.42, blue: 0.96)
            case "green": return Color(red: 0.16, green: 0.72, blue: 0.43)
            case "orange": return Color(red: 0.99, green: 0.40, blue: 0.20)
            case "pink": return Color(red: 0.93, green: 0.36, blue: 0.56)
            default: return Color(red: 0.14, green: 0.36, blue: 0.98)
            }
        case "purple": return Color(red: 0.65, green: 0.46, blue: 1.0)
        case "forest", "emerald": return Color(red: 0.19, green: 0.76, blue: 0.46)
        case "orange": return Color(red: 0.99, green: 0.48, blue: 0.24)
        case "cyan": return Color(red: 0.10, green: 0.75, blue: 0.86)
        case "teal": return Color(red: 0.10, green: 0.70, blue: 0.66)
        case "crimson", "rose": return Color(red: 0.95, green: 0.35, blue: 0.52)
        case "gold": return Color(red: 0.96, green: 0.70, blue: 0.21)
        default: return Color(red: 0.176, green: 0.342, blue: 0.980)
        }
    }
    // Contrasting text over the selected accent, including bright purple/green presets.
    static var onAccent: Color {
        switch AppPreferences.themePreset {
        case "purple", "forest", "emerald", "orange", "gold",
             "cyan", "teal", "neon":
            return Color(red: 0.043, green: 0.078, blue: 0.141)
        case "custom":
            let accent = UserDefaults.standard.string(forKey: "customAccent") ?? "blue"
            return accent == "blue" ? .white : Color(red: 0.043, green: 0.078, blue: 0.141)
        default:
            return .white
        }
    }
    static var orange: Color { Color(red: 0.985, green: 0.417, blue: 0.219) }
    static var faint: Color {
        dark ? Color(red: 0.69, green: 0.74, blue: 0.82) :
               Color(red: 0.410, green: 0.454, blue: 0.518)
    }
    static var rule: Color { dark ? .white.opacity(0.17) : Color(red: 0.825, green: 0.848, blue: 0.86) }
    // Hero panels intentionally retain stronger contrast inside light layouts.
    static var night: Color {
        dark ? surface : Color(red: 0.036, green: 0.074, blue: 0.130)
    }
    static var nightPanel: Color { dark ? surface : Color(red: 0.060, green: 0.132, blue: 0.220) }
    static var nightField: Color { dark ? paper : Color(red: 0.085, green: 0.174, blue: 0.289) }
    static var ice: Color { dark ? Color(red: 0.73, green: 0.82, blue: 0.99) :
                                   Color(red: 0.46, green: 0.72, blue: 1.0) }
    static var mint: Color { Color(red: 0.32, green: 0.85, blue: 0.68) }
    static var white: Color { Color(red: 0.96, green: 0.98, blue: 1.0) }
    static var field: Color { dark ? paper : Color(red: 0.935, green: 0.948, blue: 0.97) }
}
struct EFEyebrow: View {
    let value: String
    var light = false
    var body: some View {
        Text(value.uppercased())
            .font(.system(size: 10, weight: .heavy, design: .monospaced))
            .tracking(2.0)
            .foregroundStyle(light ? EF.ice : EF.faint)
            .accessibilityAddTraits(.isHeader)
    }
}
struct EFTitle: View {
    let lines: [String]
    var highlight: Int = 1
    var inverted = false
    var body: some View {
        VStack(alignment: .leading, spacing: -7) {
            ForEach(Array(lines.enumerated()), id: \.offset) { i, word in
                Text(word.uppercased())
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .tracking(-2.7)
                    .foregroundStyle(i == highlight ? (inverted ? EF.ice : EF.cobalt) :
                                     (inverted ? EF.white : EF.ink))
                    .minimumScaleFactor(0.68)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
struct EFSection: View {
    let title: String
    var detail = ""
    var dark = false
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(dark ? EF.white : EF.ink)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            if !detail.isEmpty {
                Text(detail.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(dark ? EF.ice : EF.faint)
                    .lineLimit(2)
            }
        }
    }
}
struct EFRule: View {
    var dark = false
    var body: some View {
        Rectangle()
            .fill(dark ? EF.ice.opacity(0.21) : EF.rule)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
struct EFAction: View {
    let title: String
    var symbol = "arrow.up.right"
    var orange = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(0.5)
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .heavy))
            }
            .padding(.horizontal, 17)
            .frame(minHeight: 56)
            .foregroundStyle(orange ? Color(red: 0.043, green: 0.078, blue: 0.141) : EF.onAccent)
            .background(orange ? EF.orange : EF.cobalt)
        }
        .buttonStyle(EFPressStyle())
        .accessibilityLabel(title)
    }
}
struct EFPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(reduceMotion ? 1 : configuration.isPressed ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
struct EFNumberRow: View {
    let order: Int
    let title: String
    let detail: String
    var inverted = false
    var body: some View {
        HStack(spacing: 12) {
            Text(String(format: "%02d", order))
                .font(.system(size: 16, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(inverted ? EF.ice : EF.cobalt)
                .frame(width: 30, alignment: .leading)
            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(inverted ? EF.white : EF.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(inverted ? EF.ice : EF.faint)
            }
            Spacer(minLength: 2)
            Image(systemName: "arrow.up.right")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(inverted ? EF.ice : EF.ink)
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
enum EFTab: Int, CaseIterable {
    case home = 0, plans = 1, index = 2, atlas = 3
    var label: String {
        switch self {
        case .home: return "HOME"
        case .plans: return "PLANS"
        case .index: return "INDEX"
        case .atlas: return "ATLAS"
        }
    }
    var icon: String {
        switch self {
        case .home: return "house"
        case .plans: return "list.bullet.rectangle"
        case .index: return "magnifyingglass"
        case .atlas: return "circle.hexagongrid"
        }
    }
}
struct EFNavigation: View {
    @Binding var selected: Int
    let start: () -> Void
    var dark = false
    @Environment(\.dynamicTypeSize) private var typeSize
    var body: some View {
        HStack(spacing: 4) {
            tab(.home)
            tab(.plans)
            Button(action: start) {
                Image(systemName: "plus")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(Color(red: 0.043, green: 0.078, blue: 0.141))
                    .frame(width: 56, height: 56)
                    .background(EF.orange, in: Circle())
            }
            .buttonStyle(EFPressStyle())
            .accessibilityLabel(L10n.text("Start or resume workout", "Training starten of hervatten"))
            tab(.index)
            tab(.atlas)
        }
        .padding(.horizontal, 9)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(dark ? EF.night : EF.paper)
        .overlay(alignment: .top) { EFRule(dark: dark) }
    }
    private func tab(_ item: EFTab) -> some View {
        Button { selected = item.rawValue } label: {
            VStack(spacing: 5) {
                Image(systemName: item.icon)
                    .font(.system(size: 19, weight: selected == item.rawValue ? .bold : .regular))
                Text(item.label)
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .tracking(0.3)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(selected == item.rawValue ? (dark ? EF.ice : EF.cobalt) :
                                     (dark ? EF.ice.opacity(0.64) : EF.faint))
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(selected == item.rawValue ? .isSelected : [])
    }
}
