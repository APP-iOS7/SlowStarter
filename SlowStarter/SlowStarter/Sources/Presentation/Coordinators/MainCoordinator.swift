import UIKit


class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    private let window: UIWindow
    private let tabBarController: UITabBarController
    private let coreDataManager: CoreDataManager
    
    private let lectureCoordinator: LectureCoordinator
    private let chatCoordinator: ChatCoordinator
    
    init(window: UIWindow, coreDataManager: CoreDataManager) {
        self.window = window
        self.coreDataManager = coreDataManager
        self.tabBarController = UITabBarController()
        
        // 강의 목록 탭을 위한 내비게이션 컨트롤러 생성 및 LectureCoordinator 초기화
        let lectureListNavigationController = UINavigationController()
        // 강의 목록 화면에서는 내비게이션 바를 숨겨야 할 수 있습니다.
//        lectureListNavigationController.navigationBar.isHidden = true
        self.lectureCoordinator = LectureCoordinator(navigationController: lectureListNavigationController)
        
        let chatNavigationController = UINavigationController()
        self.chatCoordinator = ChatCoordinator(
            navigationController: chatNavigationController,
            coreDataManager: coreDataManager
        )
        
        // MainCoordinator의 navigationController를 초기 탭의 navigationController로 설정
        // MainCoordinator가 직접 push/present를 하는 경우는 적을 수 있지만, 프로토콜 준수를 위함입니다.
        self.navigationController = lectureListNavigationController
        
        tabBarController.viewControllers = [lectureListNavigationController]
    }
    
    func start() {
        lectureCoordinator.start()
        chatCoordinator.start()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
