
import Foundation

struct UserItem: Identifiable, Codable {
    var userId: String
    var itemId: String
    var acquiredAt: Date?

    var id: String { userId + "_" + itemId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case itemId = "item_id"
        case acquiredAt = "acquired_at"
    }
}

extension UserItem {
    static let mock: UserItem = UserItem(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        itemId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C2",
        acquiredAt: Date()
    )
}
