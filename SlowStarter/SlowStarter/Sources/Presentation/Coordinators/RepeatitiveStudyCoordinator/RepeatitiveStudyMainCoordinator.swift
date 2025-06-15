import UIKit


class RepeatitiveStudyMainCoordinator: Coordinator {
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = RepetitiveLearningViewController()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: "반복학습", image: UIImage(named: "tabLaptopChromebook"), tag: 1)
        navigationController.viewControllers = [viewController]
    }
    
    // ✅ (수정) 상세 화면으로 전환 시, 전체 강의 목록도 함께 전달합니다.
       func showDetail(currentPlayingData: RepeatLearnData, allData: [RepeatLearnData]) {
           let viewController = RepeatLearnDetailViewController(
               currentPlayingData: currentPlayingData,
               allData: allData // 전체 목록 주입
           )
           // viewController.coordinator = self // 필요 시 코디네이터 주입
           navigationController.pushViewController(viewController, animated: true)
       }
    
}
