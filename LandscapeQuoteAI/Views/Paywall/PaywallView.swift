import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                freePlan
                proPlans
                privacyNote
            }
            .padding(16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Upgrade")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .task {
            await storeKitManager.loadProducts()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.largeTitle)
                .foregroundStyle(AppTheme.accent)

            Text("Pro tools for busy landscaping teams")
                .font(.title.bold())
                .foregroundStyle(AppTheme.text)
                .fixedSize(horizontal: false, vertical: true)

            Text("Unlimited quotes, PDF export, site photo uploads, and AI upsell suggestions. Purchases use StoreKit and Apple in-app purchase only.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedText)
        }
        .appCard()
    }

    private var freePlan: some View {
        PlanCard(
            title: "Free",
            price: "3 quotes per month",
            systemImage: "leaf",
            features: ["Local quote saving", "Manual measurements", "Editable line items"],
            buttonTitle: storeKitManager.isPro ? "Current fallback" : "Current plan",
            isPrimary: false,
            isLoading: false,
            action: {}
        )
    }

    private var proPlans: some View {
        VStack(spacing: 12) {
            if storeKitManager.isLoading {
                ProgressView("Loading subscriptions")
                    .frame(maxWidth: .infinity)
                    .appCard()
            }

            if let monthly = storeKitManager.products.first(where: { $0.id == StoreKitManager.monthlyProductID }) {
                productCard(monthly, title: "Pro Monthly", systemImage: "calendar")
            } else {
                unavailablePlan(title: "Pro Monthly", systemImage: "calendar")
            }

            if let yearly = storeKitManager.products.first(where: { $0.id == StoreKitManager.yearlyProductID }) {
                productCard(yearly, title: "Pro Yearly", systemImage: "calendar.badge.clock")
            } else {
                unavailablePlan(title: "Pro Yearly", systemImage: "calendar.badge.clock")
            }

            Button("Restore Purchases") {
                Task {
                    await storeKitManager.restorePurchases()
                }
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)

            if let message = storeKitManager.errorMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            #if DEBUG
            Button {
                storeKitManager.enableDemoProAccess()
                dismiss()
            } label: {
                Label("Enable Demo Pro Access", systemImage: "hammer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            #endif
        }
    }

    private var privacyNote: some View {
        Text("No external payment links are used in the iOS app. Subscription purchases and restores are handled by Apple's StoreKit purchase sheet.")
            .font(.footnote)
            .foregroundStyle(AppTheme.mutedText)
            .padding(.horizontal, 4)
    }

    private func productCard(_ product: Product, title: String, systemImage: String) -> some View {
        PlanCard(
            title: title,
            price: product.displayPrice,
            systemImage: systemImage,
            features: ["Unlimited quotes", "PDF export", "Photo uploads", "AI upsell suggestions"],
            buttonTitle: storeKitManager.isPro ? "Active" : "Subscribe",
            isPrimary: true,
            isLoading: storeKitManager.isLoading
        ) {
            Task {
                await storeKitManager.purchase(product)
                if storeKitManager.isPro {
                    dismiss()
                }
            }
        }
    }

    private func unavailablePlan(title: String, systemImage: String) -> some View {
        PlanCard(
            title: title,
            price: "Unavailable",
            systemImage: systemImage,
            features: ["Unlimited quotes", "PDF export", "Photo uploads", "AI upsell suggestions"],
            buttonTitle: "Try again later",
            isPrimary: false,
            isLoading: false,
            action: {}
        )
    }
}

private struct PlanCard: View {
    let title: String
    let price: String
    let systemImage: String
    let features: [String]
    let buttonTitle: String
    let isPrimary: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(isPrimary ? .white : AppTheme.primary)
                    .frame(width: 42, height: 42)
                    .background(isPrimary ? AppTheme.primary : AppTheme.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.text)
                    Text(price)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.text)
                }
            }

            PrimaryButton(title: buttonTitle, systemImage: isPrimary ? "crown" : "checkmark", isLoading: isLoading, isDisabled: !isPrimary) {
                action()
            }
        }
        .appCard()
    }
}
