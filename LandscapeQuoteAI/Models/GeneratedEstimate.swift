import Foundation

struct EditableLineItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unitCost: Double
    var labourCost: Double
    var markupPercentage: Double
    var taxable: Bool = true

    var baseTotal: Double {
        max(0, quantity) * max(0, unitCost) + max(0, labourCost)
    }

    var total: Double {
        baseTotal * (1 + max(0, markupPercentage) / 100)
    }
}

struct GeneratedEstimate: Equatable {
    var lineItems: [EditableLineItem]
    var labourHours: Double
    var wasteAllowancePercentage: Double
    var profitMarginPercentage: Double
    var timelineEstimate: String
    var upsellSuggestions: [String]
    var contractorNotes: [String]

    var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }

    static let empty = GeneratedEstimate(
        lineItems: [],
        labourHours: 0,
        wasteAllowancePercentage: 0,
        profitMarginPercentage: 0,
        timelineEstimate: "",
        upsellSuggestions: [],
        contractorNotes: []
    )
}
