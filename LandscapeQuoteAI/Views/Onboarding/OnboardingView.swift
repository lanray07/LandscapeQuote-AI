import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var selection = 0

    private let pages: [OnboardingPage] = [
        .init(title: "Create landscaping quotes faster", message: "Build clear estimates from rough measurements without starting from a blank spreadsheet.", symbol: "timer"),
        .init(title: "Save client and project details", message: "Keep draft, sent, approved, and rejected quotes organised on this device.", symbol: "person.text.rectangle"),
        .init(title: "Generate professional PDFs", message: "Send client-ready estimates with line items, terms, totals, and a signature line.", symbol: "doc.richtext"),
        .init(title: "Upgrade for unlimited quotes", message: "Pro unlocks unlimited quote creation, PDF export, photo uploads, and AI upsell ideas.", symbol: "crown")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selection) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 28) {
                        Spacer()

                        Image(systemName: page.symbol)
                            .font(.system(size: 62, weight: .semibold))
                            .foregroundStyle(AppTheme.primary)
                            .frame(width: 112, height: 112)
                            .background(AppTheme.primary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(spacing: 12) {
                            Text(page.title)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppTheme.text)
                                .minimumScaleFactor(0.8)

                            Text(page.message)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppTheme.mutedText)
                                .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding(24)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 12) {
                PrimaryButton(
                    title: selection == pages.count - 1 ? "Start Estimating" : "Continue",
                    systemImage: selection == pages.count - 1 ? "checkmark" : "arrow.right"
                ) {
                    if selection == pages.count - 1 {
                        onComplete()
                    } else {
                        withAnimation(.easeInOut) {
                            selection += 1
                        }
                    }
                }

                Button("Skip") {
                    onComplete()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.primary)
                .opacity(selection == pages.count - 1 ? 0 : 1)
            }
            .padding(20)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}

private struct OnboardingPage {
    let title: String
    let message: String
    let symbol: String
}
