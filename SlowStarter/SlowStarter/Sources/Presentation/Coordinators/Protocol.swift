import UIKit

// MARK: - Example

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func goLectureListView()
    func goRepeatStudyView()
    func goChatView()
    func goMyPageView()
}
