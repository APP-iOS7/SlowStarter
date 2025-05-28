import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

// 강의 관련 플로우 코디네이터가 가져야 할 기능
protocol LectureFlowCoordinator: LectureCoordinator {
    func showLectureDetail()
    func showLectureDateSelection()
    func showPayment()
    
    // 뒤로가기 기능을 위한 메서드
    func popViewController()
}
