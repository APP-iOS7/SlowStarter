import UIKit


class MyPageCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    private var childCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = MyPageViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name MyPage", image: UIImage(systemName: "questionmark"), tag: 3)
        navigationController.viewControllers = [viewController]
    }
    
    func showMyAttendance() {
        let coordinator = MyAttendanceCoordinator(navigationController: navigationController)
        coordinator.start()
        
    }
    
    func showCourseHistory() {
        let coordinator = CourseHistoryCoordinator(navigationController: navigationController)
        childCoordinator = coordinator
        coordinator.start()
    }
    
    func showPaymentHistory() {
        let coordinator = PaymentHistoryCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    func showSetting() {
        let coordinator = SettingCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}
