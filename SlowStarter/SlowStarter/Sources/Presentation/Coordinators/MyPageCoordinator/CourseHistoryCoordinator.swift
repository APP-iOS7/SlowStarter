import UIKit


class CourseHistoryCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = CourseHistoryViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showDetail() {
        print("clicked")
        let viewController = CourseHistoryDetailViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
}
