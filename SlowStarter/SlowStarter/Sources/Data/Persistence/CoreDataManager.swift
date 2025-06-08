import UIKit
import CoreData
import Combine

final class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()
    
    private let configContext: NSManagedObjectContext
    private let messageContext: NSManagedObjectContext
    private let paymentContext: NSManagedObjectContext
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate를 가져올 수 없음")
        }
        self.configContext = appDelegate.persistentConfigContainer.viewContext
        self.messageContext = appDelegate.persistentMessageContainer.viewContext
        self.paymentContext = appDelegate.persistentPaymentContainer.viewContext
    }
    
    // MARK: - Create
    
    /// 사용자 정보를 생성하고 저장함
    /// - Parameters:
    ///   - userId: 사용자 ID (고유 식별자)
    ///   - name: 사용자 이름
    ///   - image: 프로필 이미지 경로 또는 Base64 문자열 (옵션)
    /// - Returns: 저장 성공 시 true, 실패 시 false 반환
    func createUserInfo(userId: String, name: String, image: String? = nil) -> Bool {
        let userInfo = UserInfo(context: configContext)
        userInfo.userId = userId
        userInfo.userName = name
        userInfo.profileImage = image
        
        do {
            try configContext.save()
            return true
        } catch {
            print("COREDATA SAVE USER INFO ERROR: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 메시지를 Core Data에 저장함
    /// - Parameter message: 저장할 AIChatMessage 객체
    /// - Throws: 저장 실패 시 에러 throw함
    func saveMessage(_ message: AIChatMessage) async throws {
        _ = message.toManagedObject(in: messageContext)
        try messageContext.save()
    }
    
    func savePaymentsToCoreData(_ payments: [UserPayment]) {
        for payment in payments {
            let entity = PaymentEntity(context: paymentContext)
            entity.paymentId = payment.paymentId
            entity.userId = payment.userId
            entity.amount = Int64(payment.amount)
            entity.paymentDescription = payment.description
            entity.paymentMethod = payment.paymentMethod
            entity.paymentGateway = payment.paymentGateway
            entity.paymentStatus = payment.paymentStatus
            entity.externalId = payment.externalTransactionId
            entity.createdAt = payment.createdAt
        }
        
        do {
            try paymentContext.save()
        } catch {
            print("COREDATA SAVE PAYMENTS ERROR: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Read
    
    /// 조건에 따라 사용자 정보를 조회함
    /// - Parameters:
    ///   - predicate: 필터링 조건 (옵션)
    ///   - sortDescriptors: 정렬 기준 배열 (옵션)
    /// - Returns: 조건에 맞는 사용자 정보 배열
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
    
    /// 페이지 단위로 저장된 메시지를 조회함
    /// - Parameter page: 페이지 번호 (0부터 시작)
    /// - Returns: 조회된 메시지 배열
    /// - Throws: 조회 실패 시 에러 throw함
    func fetchMessages(at page: Int) async throws -> [AIChatMessage] {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 20
        request.fetchOffset = 20 * page
        
        return try messageContext.fetch(request).compactMap { AIChatMessage.from($0) }
    }
    
    func fetchPayments(forUserId userId: String?) -> [PaymentEntity] {
        guard let userId else { return [] }
        let request: NSFetchRequest<PaymentEntity> = PaymentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try paymentContext.fetch(request)
        } catch {
            print("COREDATA FETCH PAYMENTS ERROR: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Update
    
    /// 사용자 정보를 업데이트함
    /// - Parameters:
    ///   - userId: 대상 사용자 ID
    ///   - name: 변경할 이름 (옵션)
    ///   - image: 변경할 프로필 이미지 (옵션)
    /// - Returns: 업데이트 성공 시 true, 실패 시 false 반환
    func updateUserInfo(userId: String, name: String? = nil, image: String? = nil) -> Bool {
        guard let userInfo = fetchUserInfo(predicate: NSPredicate(format: "userId == %@", userId)).first else {
            print("COREDATA UPDATE USER INFO ERROR: 사용자 정보를 찾을 수 없음")
            return false
        }
        
        if let name = name {
            userInfo.userName = name
        }
        
        if let image = image {
            userInfo.profileImage = image
        }
        
        do {
            try configContext.save()
            return true
        } catch {
            print("COREDATA UPDATE USER INFO ERROR: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 메시지를 업데이트함
    /// - Parameter message: 업데이트할 메시지 객체
    /// - Throws: 업데이트 실패 시 에러 throw함
    func updateMessage(_ message: AIChatMessage) async throws {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", message.id as CVarArg)
        
        if let entity = try messageContext.fetch(request).first {
            entity.text = message.text
            try messageContext.save()
        }
    }
    
    // MARK: - Delete
    
    /// 사용자 정보를 삭제함
    /// - Parameter userId: 삭제할 사용자 ID
    /// - Returns: 삭제 성공 시 true, 실패 시 false 반환
    func deleteUserInfo(userId: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let users = try configContext.fetch(fetchRequest)
            guard let userToDelete = users.first else {
                print("COREDATA DELETE USER INFO ERROR: 사용자 정보를 찾을 수 없음")
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
    
    /// 메시지를 삭제함
    /// - Parameter message: 삭제할 메시지 객체
    /// - Throws: 삭제 실패 시 에러 throw함
    func deleteMessage(_ message: AIChatMessage) async throws {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", message.id as CVarArg)
        
        if let entity = try messageContext.fetch(request).first {
            messageContext.delete(entity)
            try messageContext.save()
        }
    }
    
    // MARK: - Combine
    
    /// 사용자 정보 변경 시 이벤트 발생하는 퍼블리셔
    var userInfoDidChangePublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: configContext)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
