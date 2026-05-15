import Foundation
import Observation
import StoreKit

private enum StoreVerificationError: Error {
    case failedVerification
}

@MainActor
@Observable
final class StoreKitManager {
    static let monthlyProductID = "landscapequote.pro.monthly"
    static let yearlyProductID = "landscapequote.pro.yearly"
    static let productIDs: Set<String> = [monthlyProductID, yearlyProductID]

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    var errorMessage: String?

    #if DEBUG
    var debugProAccess = false
    #endif

    var isPro: Bool {
        #if DEBUG
        if debugProAccess { return true }
        #endif
        return !purchasedProductIDs.isDisjoint(with: Self.productIDs)
    }

    var subscriptionStatusText: String {
        isPro ? "Pro active" : "Free plan"
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Array(Self.productIDs))
                .sorted { $0.id < $1.id }
            await updateCustomerProductStatus()
            errorMessage = nil
        } catch {
            errorMessage = "Subscriptions are temporarily unavailable. Please try again later."
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                errorMessage = nil
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "Purchase could not be completed."
            }
        } catch {
            errorMessage = "Purchase failed. Please try again from the App Store purchase sheet."
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
            errorMessage = nil
        } catch {
            errorMessage = "Restore failed. Check your App Store account and try again."
        }
    }

    func updateCustomerProductStatus() async {
        var activeProductIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if Self.productIDs.contains(transaction.productID) {
                    activeProductIDs.insert(transaction.productID)
                }
            } catch {
                continue
            }
        }

        purchasedProductIDs = activeProductIDs
    }

    #if DEBUG
    func enableDemoProAccess() {
        debugProAccess = true
    }
    #endif

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreVerificationError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
