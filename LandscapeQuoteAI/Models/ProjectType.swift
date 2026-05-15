import Foundation

enum ProjectType: String, CaseIterable, Identifiable, Codable {
    case lawnMowing
    case artificialGrass
    case patioPaving
    case gardenClearance
    case fencing
    case decking
    case hedgeTrimming
    case drainage
    case fullGardenMakeover

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lawnMowing: "Lawn mowing"
        case .artificialGrass: "Artificial grass"
        case .patioPaving: "Patio paving"
        case .gardenClearance: "Garden clearance"
        case .fencing: "Fencing"
        case .decking: "Decking"
        case .hedgeTrimming: "Hedge trimming"
        case .drainage: "Drainage"
        case .fullGardenMakeover: "Full garden makeover"
        }
    }

    var symbolName: String {
        switch self {
        case .lawnMowing: "leaf"
        case .artificialGrass: "square.grid.3x3.fill"
        case .patioPaving: "squareshape.split.3x3"
        case .gardenClearance: "trash"
        case .fencing: "line.3.horizontal"
        case .decking: "rectangle.split.3x1"
        case .hedgeTrimming: "scissors"
        case .drainage: "drop"
        case .fullGardenMakeover: "sparkles"
        }
    }
}
