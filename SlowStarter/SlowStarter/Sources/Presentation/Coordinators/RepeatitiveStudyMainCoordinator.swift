import UIKit


class RepeatitiveStudyMainCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = RepeatitiveStudyMainViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name Repeat", image: UIImage(systemName: "questionmark"), tag: 1)
        navigationController.viewControllers = [viewController]
    }
    
    
}
