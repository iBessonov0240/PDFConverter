import SwiftUI

@main
struct PDFConverterApp: App {

    let dataController = DataController()

    var body: some Scene {
        WindowGroup {
            Welcome(viewModel: WelcomeViewModel(dataController: dataController))
        }
    }
}
