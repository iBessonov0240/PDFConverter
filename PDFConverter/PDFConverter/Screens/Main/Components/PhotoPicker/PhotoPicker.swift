import SwiftUI
import PhotosUI
import Photos

struct PhotoPicker: UIViewControllerRepresentable {
    @ObservedObject var viewModel: MainViewModel

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 10

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let viewModel: MainViewModel

        init(viewModel: MainViewModel) {
            self.viewModel = viewModel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let identifiers = results.compactMap { $0.assetIdentifier }

            if identifiers.isEmpty {
                print("No assets selected.")
                return
            }

            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)

            fetchResult.enumerateObjects { asset, _, _ in
                self.viewModel.assets.append(asset)
            }

            if self.viewModel.assets.isEmpty {
                return
            }

            Task {
                await self.viewModel.convertImagesToPdf()
            }
        }
    }
}
