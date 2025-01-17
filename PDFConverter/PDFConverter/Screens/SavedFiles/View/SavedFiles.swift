import SwiftUI

struct SavedFiles: View {

// MARK: - Property

    @StateObject var viewModel: SavedFilesViewModel

// MARK: - View
    
    var body: some View {
        List {
            ForEach(viewModel.savedFiles) { file in
                NavigationLink(
                    destination: viewModel.destinationView(for: file),
                    label: {
                        HStack {
                            if let thumbnail = viewModel.generateThumbnail(for: file) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 80)
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 80)
                                    .cornerRadius(8)
                                    .overlay(
                                        Text("No Preview")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(file.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(file.fileExtension.uppercased())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(viewModel.formatDate(file.creationDate))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contextMenu {
                            Button(action: {
                                viewModel.isSharePresented = true
                                viewModel.selectedFile = file
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }

                            Button(action: {
                                viewModel.deletePDF(by: file.id)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }

                            Button(action: {
                                viewModel.isCombinePresented = true
                                viewModel.selectedFileForCombine = file
                            }) {
                                Label("Combine", systemImage: "plus.circle")
                            }
                        }
                    }
                )
            }
        }
        .navigationTitle("Saved Files")
        .onAppear {
            viewModel.loadSavedPDFs()
        }
        .sheet(isPresented: $viewModel.isSharePresented) {
            if let fileToShare = viewModel.selectedFile {
                ShareSheet(activityItems: [fileToShare.data])
            }
        }
        .sheet(isPresented: $viewModel.isCombinePresented) {
            FilePickerView(files: viewModel.savedFiles.filter { $0.id != viewModel.selectedFileForCombine?.id }) { selectedFile in
                if let selectedFile = selectedFile {
                    viewModel.combinePDF(file1: viewModel.selectedFileForCombine!, file2: selectedFile)
                    viewModel.isCombinePresented = false
                }
            }
        }
    }
}

#Preview {
    SavedFiles(viewModel: SavedFilesViewModel(dataController: DataController()))
}
