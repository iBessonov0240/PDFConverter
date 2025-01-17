import Foundation

struct SavedPDFModel: Identifiable {
    var id: UUID
    var title: String
    var fileExtension: String
    var creationDate: Date
    var data: Data
}
