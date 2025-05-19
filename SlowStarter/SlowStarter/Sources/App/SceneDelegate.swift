import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
        guard let windowScene = scene as? UIWindowScene else { return }
        
        
        let window = UIWindow(windowScene: windowScene)
        let chatApiService: ChatAPIService = ChatAPIService()
        let chatRepository: ChatRepository = ChatRepositoryImpl(apiService: chatApiService)
        let sendAndReceiveMessageUseCase: SendAndReceiveMessageUseCase = SendAndReceiveMessageUseCase(repository: chatRepository)
        let summaryMessageUseCase: SummaryMessageUseCase = SummaryMessageUseCase(repository: chatRepository)
        
        let coreDataMessageRepository: CoreDataMessageRepository =
            CoreDataMessageRepositoryImplementation(context: CoreDataStack.shared.viewContext)
        let saveUseCase: SaveMessageUseCase = DefaultSaveMessageUseCase(repository: coreDataMessageRepository)
        let fetchUseCase: FetchMessageUseCase = DefaultFetchMessageUseCase(repository: coreDataMessageRepository)
        let deleteUseCase: DeleteMessageUseCase = DefaultDeleteMessageUseCase(repository: coreDataMessageRepository)
        let updateUseCase: UpdateMessageUseCase = DefaultUpdateMessageUseCase(repository: coreDataMessageRepository)
        
        let chatVM: ChatViewModel = ChatViewModel(
            sendAndReceive: sendAndReceiveMessageUseCase,
            summary: summaryMessageUseCase,
            save: saveUseCase,
            fetch: fetchUseCase,
            delete: deleteUseCase,
            update: updateUseCase
        )
        let chatVC: ChatViewController = ChatViewController(viewModel: chatVM)
        
        window.rootViewController = UINavigationController(rootViewController: chatVC)
        self.window = window
        window.makeKeyAndVisible()
        
    }
    
}
