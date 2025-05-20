import UIKit
import CoreData

//TODO: - 테스트 필요

final class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()
    private let configContext: NSManagedObjectContext
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate를 가져올 수 없습니다.")
        }
        self.configContext = appDelegate.persistentConfigContainer.viewContext
    }

    // MARK: - Create

    /// 새로운 사용자 정보를 생성하여 저장.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - name: 사용자 이름
    /// - Returns: 저장 성공 여부
    func createUserInfo(userId: String, name: String) -> Bool {
        let userInfo = UserInfo(context: configContext)
        userInfo.userId = userId
        userInfo.userName = name

        do {
            try configContext.save()
            return true
        } catch {
            print("COREDATA SAVE USER INFO ERROR: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Read

    /// 사용자 정보를 조회.
    /// - Parameters:
    ///   - predicate: 필터링 조건
    ///   - sortDescriptors: 정렬 조건
    /// - Returns: 조회된 사용자 정보 배열
    func fetchUserInfo(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [UserInfo] {
        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        do {
            return try configContext.fetch(request)
        } catch {
            print("COREDATA FETCH USER INFO ERROR: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Update

    /// 기존 사용자 정보를 업데이트.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - name: 새로운 사용자 이름
    /// - Returns: 업데이트 성공 여부
    func updateUserInfo(userId: String, name: String) -> Bool {
        guard let userInfo = fetchUserInfo(predicate: NSPredicate(format: "userId == %@", userId)).first else {
            print("COREDATA UPDATE USER INFO ERROR: 사용자 정보를 찾을 수 없습니다.")
            return false
        }

        userInfo.userName = name

        do {
            try configContext.save()
            return true
        } catch {
            print("COREDATA UPDATE USER INFO ERROR: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Delete

    /// 특정 사용자 정보를 삭제.
    /// - Parameter userId: 사용자 ID
    /// - Returns: 삭제 성공 여부
    func deleteUserInfo(userId: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            let users = try configContext.fetch(fetchRequest)
            guard let userToDelete = users.first else {
                print("COREDATA DELETE USER INFO ERROR: 사용자 정보를 찾을 수 없습니다.")
                return false
            }
            configContext.delete(userToDelete)
            try configContext.save()
            return true
        } catch {
            print("COREDATA DELETE USER INFO ERROR: \(error.localizedDescription)")
            return false
        }
    }
}
