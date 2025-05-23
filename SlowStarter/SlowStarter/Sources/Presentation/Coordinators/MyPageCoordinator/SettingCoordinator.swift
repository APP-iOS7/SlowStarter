import UIKit


class SettingCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = SettingViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
        
    }
}
