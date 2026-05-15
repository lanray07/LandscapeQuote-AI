import Foundation
import SwiftData

@MainActor
enum SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        var descriptor = FetchDescriptor<QuoteProject>()
        descriptor.fetchLimit = 1

        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        let sample = QuoteProject(
            clientName: "Amelia Carter",
            clientContact: "amelia@example.com",
            siteAddress: "42 Willow Lane, Bristol",
            projectType: .artificialGrass,
            status: .draft,
            length: 8,
            width: 5,
            area: 40,
            notes: "Rear garden with side gate access.",
            businessName: "Greenline Landscapes",
            currencyCode: .gbp,
            discount: 0,
            taxEnabled: true,
            taxPercentage: 20,
            timelineEstimate: "1-3 working days",
            upsellSuggestions: ["Garden edging", "Annual artificial grass clean"],
            contractorNotes: ["Confirm drainage and base depth during site visit."],
            createdDate: .now.addingTimeInterval(-86_400)
        )

        context.insert(sample)

        let items = [
            QuoteLineItem(name: "Remove existing turf", quantity: 40, unitCost: 3.25, labourCost: 120, markupPercentage: 28, sortOrder: 0, project: sample),
            QuoteLineItem(name: "Sand base", quantity: 40, unitCost: 9.5, labourCost: 90, markupPercentage: 28, sortOrder: 1, project: sample),
            QuoteLineItem(name: "Weed membrane", quantity: 40, unitCost: 2.1, labourCost: 40, markupPercentage: 28, sortOrder: 2, project: sample),
            QuoteLineItem(name: "Supply and install artificial grass", quantity: 40, unitCost: 24, labourCost: 360, markupPercentage: 28, sortOrder: 3, project: sample)
        ]

        items.forEach {
            context.insert($0)
            sample.lineItems.append($0)
        }

        try? context.save()
    }
}
