import Foundation
import SwiftData

enum PersistenceController {
    static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema([
            QuoteProject.self,
            QuoteLineItem.self,
            ProjectPhoto.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
