import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Data]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let fileURLs = activityItems.compactMap { data -> URL? in
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")

            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("Error writing PDF data to file: \(error)")
                return nil
            }
        }

        let activityViewController = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = window.rootViewController?.view
                    popoverController.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                }
            }
        }

        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
