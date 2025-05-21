import UIKit


class ChatCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let coreDataManager: CoreDataManager
    
    init(navigationController: UINavigationController, coreDataManager: CoreDataManager) {
        self.navigationController = navigationController
        self.coreDataManager = coreDataManager
    }
    
    func start() {
        let chatApiService: ChatAPIService = ChatAPIService()
        let chatRepository: ChatRepository = ChatRepositoryImplementation(apiService: chatApiService)
        let chatUseCase: DefaultChatUseCase = DefaultChatUseCase(repository: chatRepository)
        let summaryMessageUseCase: DefaultSummaryUseCase = DefaultSummaryUseCase(repository: chatRepository)
        
        let chatViewModel = ChatViewModel(
            chat: chatUseCase,
            summary: summaryMessageUseCase,
            coredataMaanger: coreDataManager
        )
        
        let viewController = ChatViewController(viewModel: chatViewModel)
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "test name Chat", image: UIImage(systemName: "questionmark"), tag: 0)
        navigationController.viewControllers = [viewController]
    }
}
