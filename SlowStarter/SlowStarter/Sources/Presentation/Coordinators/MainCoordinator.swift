import UIKit


class MainCoordinator: Coordinator {
    private let window: UIWindow
    private let tabBarController: UITabBarController
    private let coreDataManager: CoreDataManager
    
    private let lectureCoordinator: LectureCoordinator
    private let chatCoordinator: ChatCoordinator
    private let repeatitiveStudyMainCoordinator: RepeatitiveStudyMainCoordinator

    init(window: UIWindow, coreDataManager: CoreDataManager) {
        self.window = window
        self.coreDataManager = coreDataManager
        self.tabBarController = UITabBarController()
        
        let lectureNavigationController = UINavigationController()
        self.lectureCoordinator = LectureCoordinator(navigationController: lectureNavigationController)

        let chatNavigationController = UINavigationController()
        self.chatCoordinator = ChatCoordinator(
            navigationController: chatNavigationController,
            coreDataManager: coreDataManager
        )
        
        let repeatitiveStudyMainNavigationController = UINavigationController()
        self.repeatitiveStudyMainCoordinator = RepeatitiveStudyMainCoordinator(navigationController: repeatitiveStudyMainNavigationController)

        tabBarController.viewControllers = [
            lectureNavigationController,
            chatNavigationController,
            repeatitiveStudyMainNavigationController
        ]
    }

    func start() {
        lectureCoordinator.start()
        chatCoordinator.start()
        repeatitiveStudyMainCoordinator.start()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
