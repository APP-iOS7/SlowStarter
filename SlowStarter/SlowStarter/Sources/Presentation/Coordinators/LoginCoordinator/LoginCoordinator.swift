import UIKit

class LoginCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = LoginViewController()
        viewController.coordinator = self
        print("sss")
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
    func showRegister() {
        let coordinator = RegisterCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    func didFinishLogin() {
        navigationController.popViewController(animated: true)
    }
    
}
