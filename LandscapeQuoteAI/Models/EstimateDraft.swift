import Foundation

struct EstimateDraft: Equatable {
    var clientName = ""
    var clientContact = ""
    var siteAddress = ""
    var projectType: ProjectType = .artificialGrass
    var length: Double = 0
    var width: Double = 0
    var manualArea: Double = 0
    var notes = ""
    var discount: Double = 0
    var taxEnabled = true

    var calculatedArea: Double {
        if manualArea > 0 { return manualArea }
        return max(0, length) * max(0, width)
    }

    var isReadyForEstimate: Bool {
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !siteAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        calculatedArea > 0
    }
}
