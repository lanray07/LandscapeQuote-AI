import Foundation
import SwiftData

@Model
final class QuoteLineItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Double
    var unitCost: Double
    var labourCost: Double
    var markupPercentage: Double
    var taxable: Bool
    var sortOrder: Int
    var project: QuoteProject?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unitCost: Double,
        labourCost: Double,
        markupPercentage: Double,
        taxable: Bool = true,
        sortOrder: Int = 0,
        project: QuoteProject? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitCost = unitCost
        self.labourCost = labourCost
        self.markupPercentage = markupPercentage
        self.taxable = taxable
        self.sortOrder = sortOrder
        self.project = project
    }

    var baseTotal: Double {
        max(0, quantity) * max(0, unitCost) + max(0, labourCost)
    }

    var total: Double {
        baseTotal * (1 + max(0, markupPercentage) / 100)
    }
}
