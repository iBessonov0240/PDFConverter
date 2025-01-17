import Foundation

final class WelcomeViewModel: ObservableObject {

// MARK: - Property

    @Published var isShowMain: Bool = false

    let dataController: DataController

// MARK: - Init

    init(dataController: DataController) {
        self.dataController = dataController
    }
}
