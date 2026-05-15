import Foundation

enum CurrencyCode: String, CaseIterable, Identifiable, Codable {
    case gbp = "GBP"
    case usd = "USD"
    case eur = "EUR"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gbp: "GBP"
        case .usd: "USD"
        case .eur: "EUR"
        }
    }

    var symbol: String {
        switch self {
        case .gbp: "poundsign"
        case .usd: "dollarsign"
        case .eur: "eurosign"
        }
    }
}
