import Foundation
import UIKit
import Photos

final class MainViewModel: ObservableObject {

// MARK: - Property

    @Published var isShowPhotoPicker = false
    @Published var isShowDocumentPicker = false
    @Published var isShowPdfPreview = false

    @Published var assets: [PHAsset] = []
    @Published var pdfDataArray: [Data] = []
    @Published var pdfData: Data? = nil
    @Published var pdfUrl: URL? = nil

    @Published var hasPhotoLibraryAccess = false
    @Published var showGaleryAlert: Bool = false
    @Published var hasFileAccess = false

    let dataController: DataController

// MARK: - Init

    init(dataController: DataController) {
        self.dataController = dataController
    }

// MARK: - Functions

    func checkAndRequestPermissions() {
        checkPhotoLibraryPermission()
        checkFileAccessPermission()
    }

    private func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.hasPhotoLibraryAccess = (status == .authorized || status == .limited)
            }
        }
    }

    func resetSelection() {
        DispatchQueue.main.async {
            self.assets.removeAll()
            self.pdfDataArray.removeAll()
        }
    }

    private func checkFileAccessPermission() {
        let fileManager = FileManager.default
        let testDirectory = NSTemporaryDirectory()
        let testFilePath = (testDirectory as NSString).appendingPathComponent("testFile")

        do {
            try "Test".write(toFile: testFilePath, atomically: true, encoding: .utf8)
            self.hasFileAccess = true
            try fileManager.removeItem(atPath: testFilePath)
        } catch {
            self.hasFileAccess = false
        }
    }

    func convertImagesToPdf() async {
        DispatchQueue.main.async {
            self.pdfDataArray.removeAll()
        }

        let images = await fetchImagesFromAssets()

        if images.isEmpty {
            print("No images to convert to PDF")
            return
        }

        let pdfData = createPdf(from: images)

        DispatchQueue.main.async {
            self.pdfDataArray.append(pdfData)
            self.isShowPdfPreview = true
        }
    }

    private func fetchImagesFromAssets() async -> [UIImage] {
        var images: [UIImage] = []
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        for asset in assets {
            await withCheckedContinuation { continuation in
                imageManager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 1024, height: 1024),
                    contentMode: .aspectFit,
                    options: options
                ) { image, _ in
                    if let image = image {
                        images.append(image)
                    }
                    continuation.resume()
                }
            }
        }
        return images
    }

    private func createPdf(from images: [UIImage]) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        return pdfRenderer.pdfData { context in
            for image in images {
                context.beginPage()
                image.draw(in: CGRect(x: 0, y: 0, width: 595, height: 842))
            }
        }
    }
}
