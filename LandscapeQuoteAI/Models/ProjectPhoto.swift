import Foundation
import SwiftData

@Model
final class ProjectPhoto {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var imageData: Data
    var createdDate: Date
    var project: QuoteProject?

    init(
        id: UUID = UUID(),
        imageData: Data,
        createdDate: Date = .now,
        project: QuoteProject? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.createdDate = createdDate
        self.project = project
    }
}
