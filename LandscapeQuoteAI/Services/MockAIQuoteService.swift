import Foundation

enum EstimateError: LocalizedError {
    case missingRequiredFields

    var errorDescription: String? {
        switch self {
        case .missingRequiredFields:
            "Add a client name, site address, and project area before generating an estimate."
        }
    }
}

struct MockAIQuoteService {
    @MainActor
    func generateEstimate(
        for draft: EstimateDraft,
        settings: AppSettings,
        includeUpsells: Bool
    ) async throws -> GeneratedEstimate {
        guard draft.isReadyForEstimate else { throw EstimateError.missingRequiredFields }

        // TODO: Replace this local estimator with an OpenAI API call once backend auth, logging, and privacy controls are in place.
        try await Task.sleep(for: .milliseconds(450))

        let area = max(1, draft.calculatedArea)
        let labourRate = max(1, settings.defaultLabourRate)
        let margin = max(0, settings.defaultProfitMargin)
        let labourHours = labourHours(for: draft.projectType, area: area)
        let labourCost = labourHours * labourRate
        var items = baseItems(for: draft.projectType, area: area, labourCost: labourCost, margin: margin)

        if draft.projectType != .lawnMowing && draft.projectType != .hedgeTrimming {
            items.append(EditableLineItem(
                name: "Waste disposal",
                quantity: max(1, area * 0.08),
                unitCost: 8,
                labourCost: 0,
                markupPercentage: margin,
                taxable: true
            ))
        }

        return GeneratedEstimate(
            lineItems: items,
            labourHours: labourHours,
            wasteAllowancePercentage: wasteAllowance(for: draft.projectType),
            profitMarginPercentage: margin,
            timelineEstimate: timeline(for: draft.projectType, area: area),
            upsellSuggestions: includeUpsells ? upsells(for: draft.projectType) : [],
            contractorNotes: contractorNotes(for: draft.projectType, area: area)
        )
    }

    private func labourHours(for type: ProjectType, area: Double) -> Double {
        switch type {
        case .lawnMowing: max(1, area / 140)
        case .artificialGrass: max(8, area / 4.5)
        case .patioPaving: max(10, area / 3.8)
        case .gardenClearance: max(4, area / 18)
        case .fencing: max(6, area / 9)
        case .decking: max(10, area / 4)
        case .hedgeTrimming: max(2, area / 35)
        case .drainage: max(8, area / 6)
        case .fullGardenMakeover: max(24, area / 2.8)
        }
    }

    private func wasteAllowance(for type: ProjectType) -> Double {
        switch type {
        case .lawnMowing, .hedgeTrimming: 5
        case .gardenClearance: 20
        case .fullGardenMakeover: 18
        default: 12
        }
    }

    private func timeline(for type: ProjectType, area: Double) -> String {
        switch type {
        case .lawnMowing: "Same day service"
        case .hedgeTrimming: area > 80 ? "1-2 days" : "Half day"
        case .gardenClearance: area > 120 ? "2-3 days" : "1 day"
        case .fullGardenMakeover: area > 120 ? "2-3 weeks" : "5-8 working days"
        default: area > 80 ? "3-5 working days" : "1-3 working days"
        }
    }

    private func upsells(for type: ProjectType) -> [String] {
        switch type {
        case .lawnMowing:
            ["Monthly maintenance plan", "Seasonal lawn feed", "Edge trimming"]
        case .artificialGrass:
            ["Garden edging", "Weed membrane upgrade", "Annual artificial grass clean"]
        case .patioPaving:
            ["Premium jointing compound", "Patio sealant", "Low-voltage path lighting"]
        case .gardenClearance:
            ["Skip hire coordination", "Regular grounds maintenance", "Mulch installation"]
        case .fencing:
            ["Post caps", "Gate installation", "Fence staining"]
        case .decking:
            ["Anti-slip strips", "Deck lighting", "Annual deck oiling"]
        case .hedgeTrimming:
            ["Quarterly hedge plan", "Green waste removal", "Tree pruning survey"]
        case .drainage:
            ["Soakaway inspection", "Decorative gravel finish", "Gutter drainage check"]
        case .fullGardenMakeover:
            ["Planting plan", "Irrigation system", "Maintenance retainer"]
        }
    }

    private func contractorNotes(for type: ProjectType, area: Double) -> [String] {
        var notes = [
            "Confirm access, parking, and waste collection before booking.",
            "Prices assume clear working access and standard ground conditions."
        ]

        if area > 100 {
            notes.append("Large area detected. Consider staged payments or milestone billing.")
        }

        switch type {
        case .artificialGrass:
            notes.append("Check drainage and base depth before finalising material quantities.")
        case .patioPaving:
            notes.append("Confirm sub-base condition and fall away from property walls.")
        case .drainage:
            notes.append("Recommend site inspection before committing to drainage layout.")
        default:
            break
        }

        return notes
    }

    private func baseItems(for type: ProjectType, area: Double, labourCost: Double, margin: Double) -> [EditableLineItem] {
        switch type {
        case .lawnMowing:
            [
                item("Cut lawn and tidy edges", area, 0.18, labourCost, margin),
                item("Green waste handling", 1, 12, 0, margin)
            ]
        case .artificialGrass:
            [
                item("Remove existing turf", area, 3.25, labourCost * 0.2, margin),
                item("Sand base", area, 9.5, labourCost * 0.15, margin),
                item("Weed membrane", area, 2.1, labourCost * 0.05, margin),
                item("Supply and install artificial grass", area, 24, labourCost * 0.6, margin)
            ]
        case .patioPaving:
            [
                item("Excavate and prepare area", area, 4.5, labourCost * 0.25, margin),
                item("MOT type 1 sub-base", area, 13.5, labourCost * 0.15, margin),
                item("Supply and lay paving slabs", area, 32, labourCost * 0.55, margin),
                item("Jointing compound", area, 4.25, labourCost * 0.05, margin)
            ]
        case .gardenClearance:
            [
                item("Clear vegetation and debris", area, 2.2, labourCost * 0.75, margin),
                item("Load and transport green waste", area * 0.15, 18, labourCost * 0.25, margin)
            ]
        case .fencing:
            [
                item("Fence panels and posts", area, 18, labourCost * 0.45, margin),
                item("Concrete post mix", max(1, area / 2), 8, labourCost * 0.1, margin),
                item("Install fencing", area, 0, labourCost * 0.45, margin)
            ]
        case .decking:
            [
                item("Decking boards", area, 34, labourCost * 0.35, margin),
                item("Timber frame and fixings", area, 16, labourCost * 0.2, margin),
                item("Build and finish decking", area, 0, labourCost * 0.45, margin)
            ]
        case .hedgeTrimming:
            [
                item("Trim and shape hedge", area, 0.75, labourCost * 0.8, margin),
                item("Green waste bagging", max(1, area / 40), 14, labourCost * 0.2, margin)
            ]
        case .drainage:
            [
                item("Excavate drainage channel", area, 7.5, labourCost * 0.35, margin),
                item("Perforated pipe and membrane", area, 14, labourCost * 0.25, margin),
                item("Drainage gravel backfill", area, 18, labourCost * 0.3, margin),
                item("Finish and tidy site", 1, 45, labourCost * 0.1, margin)
            ]
        case .fullGardenMakeover:
            [
                item("Site preparation and clearance", area, 5, labourCost * 0.2, margin),
                item("Hard landscaping allowance", area, 38, labourCost * 0.35, margin),
                item("Soft landscaping and planting", area, 18, labourCost * 0.25, margin),
                item("Final finish and handover", 1, 180, labourCost * 0.2, margin)
            ]
        }
    }

    private func item(_ name: String, _ quantity: Double, _ unitCost: Double, _ labourCost: Double, _ margin: Double) -> EditableLineItem {
        EditableLineItem(
            name: name,
            quantity: quantity,
            unitCost: unitCost,
            labourCost: labourCost,
            markupPercentage: margin,
            taxable: true
        )
    }
}
