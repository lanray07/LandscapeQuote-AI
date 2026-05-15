import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .foregroundStyle(.white)
            .background(isDisabled ? Color.gray.opacity(0.55) : AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
