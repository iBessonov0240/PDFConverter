import SwiftUI

struct Main: View {

// MARK: - Property

    @StateObject var viewModel: MainViewModel

// MARK: - View

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.white]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            VStack {

                Button {
                    viewModel.resetSelection()
                    
                    if viewModel.hasPhotoLibraryAccess {
                        viewModel.isShowPhotoPicker = true
                    } else {
                        viewModel.showGaleryAlert = true
                    }
                } label: {

                    Image(systemName: "photo")
                        .foregroundColor(.white)

                    Text("Open Galery")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .regular))
                        .shadow(color: .blue.opacity(0.7), radius: 15)
                }

                Button {
                    viewModel.isShowDocumentPicker = true
                } label: {

                    Image(systemName: "folder")
                        .foregroundColor(.white)

                    Text("Open File Source")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .regular))
                        .shadow(color: .blue.opacity(0.7), radius: 15)
                }
                .padding(.top, 30)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SavedFiles(
                    viewModel: SavedFilesViewModel(dataController: DataController()))
                ) {

                    Image(systemName: "folder.fill")
                        .foregroundColor(.white)

                    Text("Saved Files")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .regular))
                }
            }
        }
        .onAppear {
            viewModel.checkAndRequestPermissions()
        }
        .alert("Access to the gallery is denied", isPresented: $viewModel.showGaleryAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("To proceed, grant access to the gallery in the settings.")
        }
        .sheet(isPresented: $viewModel.isShowPhotoPicker) {
            PhotoPicker(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowDocumentPicker) {
            DocumentPicker(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowPdfPreview, onDismiss: {
            viewModel.pdfDataArray.removeAll()
        }) {
            PdfPreview(viewModel: PdfPreviewViewModel(
                pdfDataArray: viewModel.pdfDataArray,
                dataController: viewModel.dataController,
                showTopButtons: true
            ))
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Main(viewModel: MainViewModel(dataController: DataController()))
}
