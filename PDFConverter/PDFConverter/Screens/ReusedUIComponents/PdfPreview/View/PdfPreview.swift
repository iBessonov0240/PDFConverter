import SwiftUI
import PDFKit

struct PdfPreview: View {

// MARK: - Property

    @StateObject var viewModel: PdfPreviewViewModel
    @Environment(\.presentationMode) var presentationMode

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
                if viewModel.showTopButtons {
                    HStack {
                        
                        Button {
                            if !viewModel.selectedPages.isEmpty {
                                viewModel.isSharePresented = true
                            }
                        } label: {
                            Text("Share")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.deleteSelectedPages()
                            viewModel.closeSheet()
                        } label: {
                            Text("Delete")
                                .foregroundColor(.orange)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Button {
                            viewModel.saveSelectedPagesToCoreData()
                            viewModel.closeSheet()
                        } label: {
                            Text("Save")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(.leading, 15)
                    }
                    .padding()
                }

                ScrollView {
                    ForEach(viewModel.pdfDataArray.indices, id: \.self) { pdfIndex in
                        if let document = PDFDocument(data: viewModel.pdfDataArray[pdfIndex]) {
                            ForEach(0..<document.pageCount, id: \.self) { pageIndex in
                                if let page = document.page(at: pageIndex) {
                                    VStack {

                                        PDFKitView(page: page)
                                            .frame(height: 500)
                                        if viewModel.showTopButtons {
                                            Button(action: {
                                                viewModel.togglePageSelection(
                                                    pdfIndex: pdfIndex,
                                                    pageIndex: pageIndex
                                                )
                                            }) {
                                                Image(
                                                    systemName: viewModel.isPageSelected(
                                                        pdfIndex: pdfIndex,
                                                        pageIndex: pageIndex
                                                    ) ? "checkmark.circle.fill" : "circle"
                                                )
                                                .foregroundColor(
                                                    viewModel.isPageSelected(
                                                        pdfIndex: pdfIndex,
                                                        pageIndex: pageIndex
                                                    ) ? .blue : .gray
                                                )
                                                .font(.system(size: 24))
                                            }
                                            .padding(.top, 8)
                                        }
                                    }
                                    .padding()
                                }
                            }
                        } else {
                            Text("No PDF available")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isSharePresented) {
                if let selectedPdfData = viewModel.createPdfFromSelectedPages() {
                    ShareSheet(activityItems: [selectedPdfData])
                }
            }
        }
        .onAppear {
            viewModel.onClose = {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
