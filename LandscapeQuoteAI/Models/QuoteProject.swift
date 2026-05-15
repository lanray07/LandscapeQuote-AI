import Foundation
import SwiftData

@Model
final class QuoteProject {
    @Attribute(.unique) var id: UUID
    var clientName: String
    var clientContact: String
    var siteAddress: String
    var projectTypeRaw: String
    var statusRaw: String
    var length: Double
    var width: Double
    var area: Double
    var notes: String
    var businessName: String
    var currencyCode: String
    var discount: Double
    var taxEnabled: Bool
    var taxPercentage: Double
    var timelineEstimate: String
    var upsellSuggestions: [String]
    var contractorNotes: [String]
    var createdDate: Date
    var updatedDate: Date
    var validUntil: Date

    @Relationship(deleteRule: .cascade, inverse: \QuoteLineItem.project)
    var lineItems: [QuoteLineItem] = []

    @Relationship(deleteRule: .cascade, inverse: \ProjectPhoto.project)
    var photos: [ProjectPhoto] = []

    init(
        id: UUID = UUID(),
        clientName: String,
        clientContact: String,
        siteAddress: String,
        projectType: ProjectType,
        status: QuoteStatus = .draft,
        length: Double,
        width: Double,
        area: Double,
        notes: String,
        businessName: String,
        currencyCode: CurrencyCode,
        discount: Double,
        taxEnabled: Bool,
        taxPercentage: Double,
        timelineEstimate: String,
        upsellSuggestions: [String],
        contractorNotes: [String],
        createdDate: Date = .now,
        updatedDate: Date = .now,
        validUntil: Date = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
    ) {
        self.id = id
        self.clientName = clientName
        self.clientContact = clientContact
        self.siteAddress = siteAddress
        self.projectTypeRaw = projectType.rawValue
        self.statusRaw = status.rawValue
        self.length = length
        self.width = width
        self.area = area
        self.notes = notes
        self.businessName = businessName
        self.currencyCode = currencyCode.rawValue
        self.discount = discount
        self.taxEnabled = taxEnabled
        self.taxPercentage = taxPercentage
        self.timelineEstimate = timelineEstimate
        self.upsellSuggestions = upsellSuggestions
        self.contractorNotes = contractorNotes
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.validUntil = validUntil
    }

    var projectType: ProjectType {
        get { ProjectType(rawValue: projectTypeRaw) ?? .lawnMowing }
        set { projectTypeRaw = newValue.rawValue }
    }

    var status: QuoteStatus {
        get { QuoteStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    var currency: CurrencyCode {
        CurrencyCode(rawValue: currencyCode) ?? .gbp
    }

    var sortedLineItems: [QuoteLineItem] {
        lineItems.sorted { $0.sortOrder < $1.sortOrder }
    }

    var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }

    var taxableSubtotal: Double {
        lineItems.filter(\.taxable).reduce(0) { $0 + $1.total }
    }

    var discountAmount: Double {
        subtotal * max(0, discount) / 100
    }

    var taxAmount: Double {
        guard taxEnabled else { return 0 }
        return max(0, taxableSubtotal - discountAmount) * max(0, taxPercentage) / 100
    }

    var totalPrice: Double {
        max(0, subtotal - discountAmount + taxAmount)
    }
}
