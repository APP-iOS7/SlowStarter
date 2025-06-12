import UIKit


class RepeatitiveStudyMainCoordinator: Coordinator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = RepetitiveLearningViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "반복학습", image: UIImage(named: "tabLaptopChromebook"), tag: 1)
        navigationController.viewControllers = [viewController]
    }
    
    func showDetail(currentPlayingData: RepeatLearnData) {
        let viewController = RepeatLearnDetailViewController(currentPlayingData: currentPlayingData)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
