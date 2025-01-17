import SwiftUI

struct Welcome: View {

// MARK: - Property

    @StateObject var viewModel: WelcomeViewModel

// MARK: - View

    var body: some View {
        NavigationView {
            ZStack {

                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.white]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()

                VStack {

                    Text("PDF Converter")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))

                    Text("This app help you to convert files\nto pdf format\nand interact with it.")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 22, weight: .regular))
                        .padding(.top, 20)
                        .shadow(color: .blue.opacity(0.7), radius: 15)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation {
                        viewModel.isShowMain = true
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: Main(viewModel: MainViewModel(dataController: viewModel.dataController)),
                    isActive: $viewModel.isShowMain,
                    label: { EmptyView() }
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    Welcome(viewModel: WelcomeViewModel(dataController: DataController()))
}
