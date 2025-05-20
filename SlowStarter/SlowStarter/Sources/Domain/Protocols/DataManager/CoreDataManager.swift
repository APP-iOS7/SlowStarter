
import Foundation


protocol CoreDataManagerProtocol {
    /// 새로운 사용자 정보를 생성합니다.
    func createUserInfo(userId: String, name: String) -> Bool

    /// 사용자 정보를 조회합니다.
    func fetchUserInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [UserInfo]

    /// 기존 사용자 정보를 업데이트합니다.
    func updateUserInfo(userId: String, name: String) -> Bool

    /// 특정 사용자 정보를 삭제합니다.
    func deleteUserInfo(userId: String) -> Bool
}
