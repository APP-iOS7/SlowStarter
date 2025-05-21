import UIKit
import CoreData

//TODO: - 테스트 필요



final class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()
    private let configContext: NSManagedObjectContext
    private let messageContext: NSManagedObjectContext
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate를 가져올 수 없습니다.")
        }
        self.configContext = appDelegate.persistentConfigContainer.viewContext
        self.messageContext = appDelegate.persistentMessageContainer.viewContext
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
    
    /// 메시지를 저장.
    /// - Parameter message: 저장할 메시지 객체
    /// - Throws: Core Data 저장 중 발생할 수 있는 오류
    func saveMessage(_ message: Messages) async throws {
        // 메시지를 관리 객체로 변환하여 컨텍스트에 추가
        _ = message.toManagedObject(in: messageContext)
        // 변경 사항을 저장
        try messageContext.save()
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
    
    /// 저장된 모든 메시지를 비동기적으로 조회
    /// - Returns: 메시지 객체 배열
    /// - Throws: Core Data 조회 중 발생할 수 있는 오류
    func fetchMessages() async throws -> [Messages] {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        // 메시지 엔티티를 관리 객체로 변환하여 반환
        let result = try messageContext.fetch(request).compactMap { Messages.from($0) }
        return result
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
    
    /// 특정 메시지를 업데이트.
    /// - Parameter message: 업데이트할 메시지 객체
    /// - Throws: Core Data 업데이트 중 발생할 수 있는 오류
    func updateMessage(_ message: Messages) async throws {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", message.id as CVarArg)
        
        if let entity = try messageContext.fetch(request).first {
            // 메시지 텍스트 업데이트
            entity.text = message.text
            // 변경 사항 저장
            try messageContext.save()
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
    
    /// 특정 메시지를 삭제.
    /// - Parameter message: 삭제할 메시지 객체
    /// - Throws: Core Data 삭제 중 발생할 수 있는 오류
    func deleteMessage(_ message: Messages) async throws {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", message.id as CVarArg)
        
        if let entity = try messageContext.fetch(request).first {
            // 관리 객체 삭제
            messageContext.delete(entity)
            // 변경 사항 저장
            try messageContext.save()
        }
    }
}
