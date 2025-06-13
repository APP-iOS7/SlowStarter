import UIKit

class LoginCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    private var completion: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = LoginViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
    func start(_ completion: (() -> Void)? = nil) {
        self.completion = completion
        let viewController = LoginViewController()
        viewController.coordinator = self
        viewController.completion = { [weak self] in
            self?.navigationController.dismiss(animated: true) {
                print("11111111")
                self?.completion?()
            }
        }
        let uINavigationController = UINavigationController(rootViewController: viewController)
        navigationController.present(uINavigationController, animated: true)
        
    }
    
    func showRegister() {
        let coordinator = RegisterCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    func didFinishLogin() {
        navigationController.popViewController(animated: true)
    }
    
}
