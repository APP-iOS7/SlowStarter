import UIKit

class LectureCoordinator: Coordinator {
    internal var navigationController: UINavigationController
    private weak var tabBarController: UITabBarController?
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController? = nil) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let viewController = LectureListViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "강의목록", image: UIImage(named: "tabLectureList"), tag: 0)
        navigationController.viewControllers = [viewController]
    }
    
    func showLectureDetail(_ lectureDetail: LectureDetail) {
        let lectureDetailViewController = LectureDetailViewController(lectureDetail)
        lectureDetailViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureDetailViewController, animated: true)
    }
    
    // 강의 설명에서 수강 날짜 선택 버튼을 눌렀을 때 호출될 메서드
    func showLectureDateSelection() {
        let lectureDateViewController = LectureDateViewController()
        lectureDateViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureDateViewController, animated: true)
    }
    
    // 수강 날짜 선택에서 다음 버튼을 눌렀을 때 호출될 메서드 (모달로 표시)
    func showPayment(date: Date? = nil, time: String? = nil) {
        let paymentViewController = PaymentViewController()
        paymentViewController.coordinator = self
        paymentViewController.selectedDate = date
        paymentViewController.selectedTime = time
        // 모달 스타일 설정
        paymentViewController.modalPresentationStyle = .pageSheet
        navigationController.present(paymentViewController, animated: true, completion: nil)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func goHome() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            if let first = self.navigationController.viewControllers.first {
                self.navigationController.setViewControllers([first], animated: false)
            }

            self.tabBarController?.selectedIndex = 0
        }
    }
    
    func goRepeatLecture() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            if let rootViewController = self.navigationController.viewControllers.first {
                self.navigationController.setViewControllers([rootViewController], animated: false)
            }

            self.tabBarController?.selectedIndex = 1
        }
    }
}
