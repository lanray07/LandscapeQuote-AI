import Foundation

enum QuoteStatus: String, CaseIterable, Identifiable, Codable {
    case draft
    case sent
    case approved
    case rejected

    var id: String { rawValue }

    var title: String {
        switch self {
        case .draft: "Draft"
        case .sent: "Sent"
        case .approved: "Approved"
        case .rejected: "Rejected"
        }
    }
}
