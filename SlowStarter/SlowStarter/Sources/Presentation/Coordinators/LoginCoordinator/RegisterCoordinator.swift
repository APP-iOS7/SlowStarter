import UIKit

class RegisterCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = RegisterViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}
