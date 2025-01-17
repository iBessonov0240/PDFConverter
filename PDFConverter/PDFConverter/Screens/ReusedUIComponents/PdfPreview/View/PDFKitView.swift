import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let page: PDFPage

    func makeUIView(context: Context) -> UIView {
        let pdfThumbnailView = UIImageView()
        pdfThumbnailView.contentMode = .scaleAspectFit
        pdfThumbnailView.image = page.thumbnail(of: CGSize(width: 300, height: 400), for: .artBox)
        return pdfThumbnailView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView as? UIImageView {
            imageView.image = page.thumbnail(of: CGSize(width: 300, height: 400), for: .artBox)
        }
    }
}
