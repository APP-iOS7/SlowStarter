import UIKit

class LectureCoordinator: Coordinator, LectureFlowCoordinator {
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = LectureListViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name Lecture", image: UIImage(systemName: "questionmark"), tag: 0)
        navigationController.viewControllers = [viewController]
    }
    
    func showLectureDetail() {
        let lectureDetailViewController = LectureDetailViewController()
        lectureDetailViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureDetailViewController, animated: false)
    }

    // 강의 설명에서 수강 날짜 선택 버튼을 눌렀을 때 호출될 메서드
    func showLectureDateSelection() {
        let lectureDateViewController = LectureDateViewController()
        lectureDateViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureDateViewController, animated: false)
    }

    // 수강 날짜 선택에서 다음 버튼을 눌렀을 때 호출될 메서드 (모달로 표시)
    func showPayment() {
        let paymentViewController = PaymentViewController()
        
        // 모달 스타일 설정
        paymentViewController.modalPresentationStyle = .pageSheet
        navigationController.present(paymentViewController, animated: false, completion: nil)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: false)
    }
}
