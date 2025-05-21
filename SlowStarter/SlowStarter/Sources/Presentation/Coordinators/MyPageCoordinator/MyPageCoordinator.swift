import UIKit


class MyPageCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = MyPageViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name MyPage", image: UIImage(systemName: "questionmark"), tag: 3)
        navigationController.viewControllers = [viewController]
    }
}
