

import Foundation

struct UserPointLog: Identifiable, Codable {
    var userId: String
    var actionType: String
    var description: String?
    var amount: Int
    var balance: Int
    var createdAt: Date?

    var id: String { userId + "_" + ISO8601DateFormatter().string(from: createdAt ?? Date()) }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case actionType = "action_type"
        case description
        case amount
        case balance
        case createdAt = "created_at"
    }
}

extension UserPointLog {
    static let mock: UserPointLog = UserPointLog(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        actionType: "daily_login",
        description: "Daily login reward",
        amount: 10,
        balance: 120,
        createdAt: Date()
    )
}
