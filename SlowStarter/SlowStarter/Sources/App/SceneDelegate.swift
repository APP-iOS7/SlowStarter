import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let container: NSPersistentContainer
    
    var appCoordinator: AppCoordinator? // AppCoordinator 인스턴스를 유지하기 위함
    
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
        
        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.goLectureListView()// 코디네이터 시작
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: LectureSearchViewController()) // 네비게이션 컨트롤러를 루트로 설정
        self.window = window
        window.makeKeyAndVisible()
        
    }
    
}
