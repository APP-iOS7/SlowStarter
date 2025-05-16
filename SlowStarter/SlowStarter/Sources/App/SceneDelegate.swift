import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let container: NSPersistentContainer
    
    private override init() {
        self.container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
        guard let windowScene = scene as? UIWindowScene else { return }
        
        
        let window = UIWindow(windowScene: windowScene)
        let chatApiService: ChatAPIService = ChatAPIService()
        let repository: ChatRepository = ChatRepositoryImpl(apiService: chatApiService)
        let sendAndReceiveMessageUseCase: SendAndReceiveMessageUseCase = SendAndReceiveMessageUseCase(repository: repository)
        let summaryMessageUseCase: SummaryMessageUseCase = SummaryMessageUseCase(repository: repository)
        let chatVM: ChatViewModel = ChatViewModel(
            sendAndReceive: sendAndReceiveMessageUseCase,
            summary: summaryMessageUseCase
        )
        let chatVC: ChatViewController = ChatViewController(viewModel: chatVM)
        
        window.rootViewController = UINavigationController(rootViewController: chatVC)
        self.window = window
        window.makeKeyAndVisible()
        
    }
    
}
