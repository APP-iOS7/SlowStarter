//
//  RepeatitiveDetailCoordinator.swift
//  SlowStarter
//
//  Created by jdios on 5/23/25.
//

import Foundation
import UIKit

class RepeatitiveDetailCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let coreDataManager: CoreDataManager
    
    init(navigationController: UINavigationController, coreDataManager: CoreDataManager) {
        self.navigationController = navigationController
        self.coreDataManager = coreDataManager
    }
    
    func start() {
        
        let viewController = RepeatLearnDetailViewController(coder: <#NSCoder#>)
        navigationController.viewControllers = [viewController]
    }
}
