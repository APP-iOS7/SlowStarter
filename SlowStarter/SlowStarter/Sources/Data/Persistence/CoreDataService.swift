//
//  CoreDataStack.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

import Foundation
import CoreData

final class CoreDataService {
    static let shared: CoreDataService = CoreDataService()
    
    private let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData 로드 실패: \(error.userInfo)")
            }
        }
    }
}
