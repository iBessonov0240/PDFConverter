import SwiftUI
import PDFKit

struct DocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var viewModel: MainViewModel

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var viewModel: MainViewModel

        init(viewModel: MainViewModel) {
            self.viewModel = viewModel
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            viewModel.pdfDataArray.removeAll()
            
            for url in urls {
                do {
                    let pdfData = try Data(contentsOf: url)

                    viewModel.pdfDataArray.append(pdfData)
                    viewModel.isShowPdfPreview = true

                } catch {
                    print("Failed to load PDF data from \(url): \(error.localizedDescription)")
                }
            }
        }
    }
}
