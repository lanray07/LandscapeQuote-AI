import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    var businessName: String {
        didSet { save("businessName", businessName) }
    }

    var defaultLabourRate: Double {
        didSet { save("defaultLabourRate", defaultLabourRate) }
    }

    var defaultProfitMargin: Double {
        didSet { save("defaultProfitMargin", defaultProfitMargin) }
    }

    var taxPercentage: Double {
        didSet { save("taxPercentage", taxPercentage) }
    }

    var currencyCode: String {
        didSet { save("currencyCode", currencyCode) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.businessName = defaults.string(forKey: "businessName") ?? "Greenline Landscapes"
        self.defaultLabourRate = defaults.object(forKey: "defaultLabourRate") as? Double ?? 38
        self.defaultProfitMargin = defaults.object(forKey: "defaultProfitMargin") as? Double ?? 28
        self.taxPercentage = defaults.object(forKey: "taxPercentage") as? Double ?? 20
        self.currencyCode = defaults.string(forKey: "currencyCode") ?? CurrencyCode.gbp.rawValue
    }

    var currency: CurrencyCode {
        get { CurrencyCode(rawValue: currencyCode) ?? .gbp }
        set { currencyCode = newValue.rawValue }
    }

    private func save(_ key: String, _ value: String) {
        defaults.set(value, forKey: key)
    }

    private func save(_ key: String, _ value: Double) {
        defaults.set(value, forKey: key)
    }
}
