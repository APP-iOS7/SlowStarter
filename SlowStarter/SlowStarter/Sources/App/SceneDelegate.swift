import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var mainCoordinator: MainCoordinator?
    
    var dataManager: SupabaseDataManager?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
//        dataManager = SupabaseDataManager()
        let coreDataManager = CoreDataManager.shared
        self.window = window
        let mainCoordinator = MainCoordinator(window: window, coreDataManager: coreDataManager)
        self.mainCoordinator = mainCoordinator
        mainCoordinator.start()
        
    }
    
}
