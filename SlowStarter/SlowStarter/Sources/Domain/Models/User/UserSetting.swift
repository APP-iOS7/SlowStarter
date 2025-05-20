
import Foundation

struct UserSetting: Identifiable, Codable {
    var userId: String
    var notifyChat: Bool
    var notifyPush: Bool
    var updatedAt: Date?

    var id: String { userId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case notifyChat = "notify_chat"
        case notifyPush = "notify_push"
        case updatedAt = "updated_at"
    }
}

extension UserSetting {
    static let mock: UserSetting = UserSetting(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        notifyChat: true,
        notifyPush: false,
        updatedAt: Date()
    )
}
