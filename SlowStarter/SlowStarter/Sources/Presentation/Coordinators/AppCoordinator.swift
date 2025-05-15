import UIKit


class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func goLectureListView() {
        // 초기 뷰 컨트롤러를 여기서 설정
        // 스켈레톤 UI를 보여줄 LectureListViewController를 시작점으로 설정
        let lectureViewController = LectureSearchViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
    
    func goRepeatStudyView() {
        let lectureViewController = LectureListViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
    
    func goChatView() {
        let lectureViewController = LectureSearchViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
    
    func goMyPageView() {
        let lectureViewController = LectureSearchViewController()
        navigationController.pushViewController(lectureViewController, animated: true)
    }
}
