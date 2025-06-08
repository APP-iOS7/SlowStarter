import UIKit


class CourseHistoryCoordinator: Coordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = CourseHistoryViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showDetail(_ course: UserCourseHistory) {
        let viewController = CourseHistoryDetailViewController()
        viewController.course = course
        navigationController.pushViewController(viewController, animated: true)
    }
}
