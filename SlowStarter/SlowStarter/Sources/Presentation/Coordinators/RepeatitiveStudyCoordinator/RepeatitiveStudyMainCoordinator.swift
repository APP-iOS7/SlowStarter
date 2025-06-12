import UIKit


class RepeatitiveStudyMainCoordinator: Coordinator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = RepetitiveLearningViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name Repeat", image: UIImage(systemName: "questionmark"), tag: 1)
        navigationController.viewControllers = [viewController]
    }
    
    func showDetail() {
        let viewController = RepeatLearnDetailViewController()
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
}
