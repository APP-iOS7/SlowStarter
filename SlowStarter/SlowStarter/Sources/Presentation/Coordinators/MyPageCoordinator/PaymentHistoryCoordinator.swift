import UIKit


class PaymentHistoryCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = PaymentHistoryViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
        
    }
}
