import Foundation

struct ChatRoom: Identifiable, Codable {
    var roomId: String
    var title: String?
    var createdAt: Date?

    var id: String { roomId }

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case title
        case createdAt = "created_at"
    }
}

extension ChatRoom {
    static let mock: ChatRoom = ChatRoom(
        roomId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C6",
        title: "General Chat",
        createdAt: Date()
    )
}
