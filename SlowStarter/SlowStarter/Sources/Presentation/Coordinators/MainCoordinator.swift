import UIKit


class MainCoordinator: Coordinator {
    private let window: UIWindow
    private let tabBarController: UITabBarController
    private let coreDataManager: CoreDataManager

    private let chatCoordinator: ChatCoordinator

    init(window: UIWindow, coreDataManager: CoreDataManager) {
        self.window = window
        self.coreDataManager = coreDataManager
        self.tabBarController = UITabBarController()

        let chatNavigationController = UINavigationController()
        self.chatCoordinator = ChatCoordinator(
            navigationController: chatNavigationController,
            coreDataManager: coreDataManager
        )

        tabBarController.viewControllers = [chatNavigationController]
    }

    func start() {
        chatCoordinator.start()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
