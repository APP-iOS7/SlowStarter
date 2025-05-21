
import UIKit

class LectureCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = LectureListViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name Lecture", image: UIImage(systemName: "questionmark"), tag: 0)
        navigationController.viewControllers = [viewController]
    }
}
