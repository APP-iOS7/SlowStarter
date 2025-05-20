

import Foundation

struct ChatMessage: Identifiable, Codable {
    var messageId: String
    var roomId: String
    var userId: String
    var messages: String?
    var createdAt: Date?

    var id: String { messageId }

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case roomId = "room_id"
        case userId = "user_id"
        case messages
        case createdAt = "created_at"
    }
}

extension ChatMessage {
    static let mock: ChatMessage = ChatMessage(
        messageId: UUID().uuidString,
        roomId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C6",
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        messages: "Hello, world!",
        createdAt: Date()
    )
}
