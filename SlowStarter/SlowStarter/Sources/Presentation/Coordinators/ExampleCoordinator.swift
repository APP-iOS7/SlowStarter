import UIKit


class ExampleCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func goLectureListView() {
        let lectureViewController = LectureListViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
    
    func goRepeatStudyView() {
        let lectureViewController = LectureListViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
    
    func goChatView() {
        let lectureViewController = LectureListViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
    
    func goMyPageView() {
        let lectureViewController = LectureListViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
}
