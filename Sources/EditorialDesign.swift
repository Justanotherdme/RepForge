import SwiftUI
import SwiftData

/// Approved six-screen concept: paper/ink/cobalt planning, ink/navy workout,
/// orange primary action. Design tokens are independent of old RFTheme cards.
enum EF {
    static let paper = Color(red: 0.952, green: 0.955, blue: 0.928)
    static let ink = Color(red: 0.043, green: 0.078, blue: 0.141)
    static let cobalt = Color(red: 0.176, green: 0.342, blue: 0.980)
    static let orange = Color(red: 0.985, green: 0.417, blue: 0.219)
    static let faint = Color(red: 0.410, green: 0.454, blue: 0.518)
    static let rule = Color(red: 0.788, green: 0.811, blue: 0.814)
    static let night = Color(red: 0.036, green: 0.074, blue: 0.130)
    static let nightPanel = Color(red: 0.060, green: 0.132, blue: 0.220)
    static let nightField = Color(red: 0.085, green: 0.174, blue: 0.289)
    static let ice = Color(red: 0.46, green: 0.72, blue: 1.0)
    static let mint = Color(red: 0.32, green: 0.95, blue: 0.76)
    static let white = Color(red: 0.96, green: 0.98, blue: 1.0)
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
            .foregroundStyle(orange ? EF.ink : .white)
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
                    .foregroundStyle(EF.ink)
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
