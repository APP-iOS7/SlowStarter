import UIKit


class MyAttendanceCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = MyAttendanceViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
        
    }
}
