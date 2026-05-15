import SwiftUI

enum AppTheme {
    static let primary = Color(red: 0.13, green: 0.42, blue: 0.25)
    static let primaryDark = Color(red: 0.08, green: 0.25, blue: 0.16)
    static let accent = Color(red: 0.83, green: 0.63, blue: 0.25)
    static let background = Color(red: 0.95, green: 0.97, blue: 0.94)
    static let card = Color.white
    static let text = Color(red: 0.1, green: 0.13, blue: 0.1)
    static let mutedText = Color(red: 0.36, green: 0.42, blue: 0.36)
}

extension View {
    func appCard(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

extension Double {
    func currency(_ code: String) -> String {
        formatted(.currency(code: code))
    }
}
