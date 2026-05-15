import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(AppTheme.primary)
                .frame(width: 72, height: 72)
                .background(AppTheme.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.text)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.mutedText)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .padding()
    }
}
