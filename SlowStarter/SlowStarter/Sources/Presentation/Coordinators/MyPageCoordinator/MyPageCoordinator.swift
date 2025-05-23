import UIKit


class MyPageCoordinator: NSObject, Coordinator {
    private let navigationController: UINavigationController
    
    private var childCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
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

extension MyPageCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(fromViewController) else { return }
        
        if fromViewController is CourseHistoryViewController {
            childCoordinator = nil
            print("Coordinator status: \(childCoordinator as Any)")
        }
    }
}
