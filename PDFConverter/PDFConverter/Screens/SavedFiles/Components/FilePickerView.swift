import SwiftUI

struct FilePickerView: View {

// MARK: - Property

    var files: [SavedPDFModel]
    var onSelect: (SavedPDFModel?) -> Void

// MARK: - View

    var body: some View {
        List(files) { file in
            Button(action: {
                onSelect(file)
            }) {
                Text(file.title)
            }
        }
        .navigationTitle("Select Another PDF")
    }
}
