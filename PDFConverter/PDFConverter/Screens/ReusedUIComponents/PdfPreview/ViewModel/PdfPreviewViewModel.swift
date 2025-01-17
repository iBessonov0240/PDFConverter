import Foundation
import SwiftUI
import PDFKit

final class PdfPreviewViewModel: ObservableObject {

// MARK: - Property

    @Published var isSharePresented = false
    @Published var pdfDataArray: [Data]
    @Published var selectedPages: [Int: Set<Int>] = [:]
    @Published var showTopButtons: Bool

    private let dataController: DataController
    var onClose: (() -> Void)?

// MARK: - Init

    init(pdfDataArray: [Data], dataController: DataController, showTopButtons: Bool) {
        self.pdfDataArray = pdfDataArray
        self.dataController = dataController
        self.showTopButtons = showTopButtons
    }

// MARK: - View

    func closeSheet() {
        onClose?()
    }

    func togglePageSelection(pdfIndex: Int, pageIndex: Int) {
        if selectedPages[pdfIndex]?.contains(pageIndex) == true {
            selectedPages[pdfIndex]?.remove(pageIndex)
        } else {
            if selectedPages[pdfIndex] == nil {
                selectedPages[pdfIndex] = []
            }
            selectedPages[pdfIndex]?.insert(pageIndex)
        }
    }

    func isPageSelected(pdfIndex: Int, pageIndex: Int) -> Bool {
        return selectedPages[pdfIndex]?.contains(pageIndex) == true
    }

    func deleteSelectedPages() {
        for (pdfIndex, pages) in selectedPages {
            if let document = PDFDocument(data: pdfDataArray[pdfIndex]) {
                for pageIndex in pages.sorted(by: >) {
                    document.removePage(at: pageIndex)
                }
                pdfDataArray[pdfIndex] = document.dataRepresentation() ?? Data()
            }
        }
        selectedPages.removeAll()
    }

    /// For share conect in one document
    func createPdfFromSelectedPages() -> Data? {
        guard !selectedPages.isEmpty else { return nil }

        let newPdfDocument = PDFDocument()

        for (pdfIndex, pages) in selectedPages {
            if let originalDocument = PDFDocument(data: pdfDataArray[pdfIndex]) {
                for pageIndex in pages.sorted() {
                    if let page = originalDocument.page(at: pageIndex) {
                        newPdfDocument.insert(page, at: newPdfDocument.pageCount)
                    }
                }
            }
        }

        return newPdfDocument.dataRepresentation()
    }

    /// For unique title
    func generateUniqueTitle(baseName: String, existingTitles: [String]) -> String {
        var uniqueTitle = baseName
        var counter = 1

        while existingTitles.contains(uniqueTitle) {
            uniqueTitle = "\(baseName)_\(counter)"
            counter += 1
        }

        return uniqueTitle
    }

    /// Save to CoreData
    func saveSelectedPagesToCoreData() {
        guard !selectedPages.isEmpty else { return }

        var existingTitles = dataController.fetchAllPDFs().map { $0.title }

        for (pdfIndex, pages) in selectedPages {
            if let originalDocument = PDFDocument(data: pdfDataArray[pdfIndex]) {
                for pageIndex in pages.sorted() {
                    if let page = originalDocument.page(at: pageIndex) {
                        let singlePageDocument = PDFDocument()
                        singlePageDocument.insert(page, at: 0)

                        let uniqueTitle = generateUniqueTitle(
                            baseName: "Document_\(pdfIndex + 1)_Page_\(pageIndex + 1)",
                            existingTitles: existingTitles
                        )
                        existingTitles.append(uniqueTitle)

                        if let pdfData = singlePageDocument.dataRepresentation() {
                            dataController.savePDF(title: uniqueTitle, data: pdfData)

                            print("Saved document: \(uniqueTitle), Page: \(pageIndex)")
                        } else {
                            print("Failed to generate PDF data for page \(pageIndex) in document \(pdfIndex)")
                        }
                    }
                }
            }
        }

        selectedPages.removeAll()
    }
}
