import Foundation
import CoreData

final class DataController {

// MARK: - Property

    static let shared = DataController()

    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PDFConverter")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

// MARK: - Methods

    func fetchAllPDFs() -> [SavedPDFModel] {
        let request: NSFetchRequest<SavedPDF> = SavedPDF.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                SavedPDFModel(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "Untitled",
                    fileExtension: entity.fileExtension ?? "pdf",
                    creationDate: entity.creationDate ?? Date(),
                    data: entity.data ?? Data()
                )
            }
        } catch {
            print("Failed to fetch PDFs: \(error)")
            return []
        }
    }

    func deletePDF(by id: UUID) {
        let request: NSFetchRequest<SavedPDF> = SavedPDF.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Failed to delete PDF: \(error)")
        }
    }

    func savePDF(title: String, data: Data) {
        let newPDF = SavedPDF(context: context)
        newPDF.id = UUID()
        newPDF.title = title
        newPDF.fileExtension = "pdf"
        newPDF.creationDate = Date()
        newPDF.data = data

        do {
            try context.save()
        } catch {
            print("Failed to save PDF: \(error)")
        }
    }
}
