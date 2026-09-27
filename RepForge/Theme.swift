import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.055, green: 0.075, blue: 0.085)
    static let surface = Color(red: 0.105, green: 0.135, blue: 0.15)
    static let surfaceRaised = Color(red: 0.14, green: 0.175, blue: 0.19)
    static let field = Color(red: 0.075, green: 0.10, blue: 0.11)
    static let accent = Color(red: 0.18, green: 0.63, blue: 1.0)
    static let success = Color(red: 0.16, green: 0.78, blue: 0.43)
    static let muted = Color.white.opacity(0.52)
}

extension View {
    func appBackground() -> some View {
        self.background(AppTheme.background.ignoresSafeArea())
    }
}
