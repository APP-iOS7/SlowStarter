import UIKit


class MainCoordinator: NSObject, Coordinator {
    private let window: UIWindow
    private let tabBarController: UITabBarController
    private let coreDataManager: CoreDataManager
    
    private let lectureCoordinator: LectureCoordinator
    private let chatCoordinator: ChatCoordinator
    private let repeatitiveStudyMainCoordinator: RepeatitiveStudyMainCoordinator
    private let myPageCoordinator: MyPageCoordinator
    
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
        
        let myPageNavigationController = UINavigationController()
        self.myPageCoordinator = MyPageCoordinator(navigationController: myPageNavigationController)
        
        tabBarController.viewControllers = [
            lectureNavigationController,
            chatNavigationController,
            repeatitiveStudyMainNavigationController,
            myPageNavigationController
        ]
        
        super.init()
        self.tabBarController.delegate = self
    }
    
    func start() {
        // tab bar item coordinator 실행
        lectureCoordinator.start()
        chatCoordinator.start()
        repeatitiveStudyMainCoordinator.start()
        myPageCoordinator.start()
        
        // tab bar item setting
        setupTabBarStyle()
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    func setupTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 선택된 탭 바 아이템 색상
        appearance.stackedLayoutAppearance.selected.iconColor = .systemCyan
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemRed,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        
        // 선택되지 않은 아이템 색상
        appearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.isTranslucent = false
    }
}

// TabBar Delegate 수정
extension MainCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
