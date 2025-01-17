import Foundation
import SwiftUI
import PDFKit

final class SavedFilesViewModel: ObservableObject {

// MARK: - Property

    @Published var savedFiles: [SavedPDFModel] = []
    @Published var isSharePresented = false
    @Published var isCombinePresented = false
    @Published var selectedFile: SavedPDFModel?
    @Published var selectedFileForCombine: SavedPDFModel?

    let dataController: DataController

// MARK: - Init

    init(dataController: DataController) {
        self.dataController = dataController
    }

// MARK: - View

    func loadSavedPDFs() {
        savedFiles = dataController.fetchAllPDFs()
    }

    func deletePDF(by id: UUID) {
        dataController.deletePDF(by: id)
        loadSavedPDFs()
    }

    func generateThumbnail(for file: SavedPDFModel) -> UIImage? {
        guard let document = PDFDocument(data: file.data) else { return nil }
        return document.page(at: 0)?.thumbnail(of: CGSize(width: 60, height: 80), for: .mediaBox)
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func destinationView(for file: SavedPDFModel) -> some View {
        let pdfViewModel = PdfPreviewViewModel(
            pdfDataArray: [file.data],
            dataController: dataController,
            showTopButtons: false
        )
        return PdfPreview(viewModel: pdfViewModel)
    }

    func combinePDF(file1: SavedPDFModel, file2: SavedPDFModel) {
        let combinedPDF = combineTwoPDFs(file1: file1, file2: file2)

        dataController.savePDF(title: "Combined PDF", data: combinedPDF)

        loadSavedPDFs()
    }

    private func combineTwoPDFs(file1: SavedPDFModel, file2: SavedPDFModel) -> Data {
        let pdfDocument1 = PDFDocument(data: file1.data)!
        let pdfDocument2 = PDFDocument(data: file2.data)!

        let combinedDocument = PDFDocument()

        for i in 0..<pdfDocument1.pageCount {
            if let page = pdfDocument1.page(at: i) {
                combinedDocument.insert(page, at: combinedDocument.pageCount)
            }
        }

        for i in 0..<pdfDocument2.pageCount {
            if let page = pdfDocument2.page(at: i) {
                combinedDocument.insert(page, at: combinedDocument.pageCount)
            }
        }

        return combinedDocument.dataRepresentation()!
    }
}
