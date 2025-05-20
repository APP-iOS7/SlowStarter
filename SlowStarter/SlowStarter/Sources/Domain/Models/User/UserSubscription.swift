

import Foundation

struct UserSubscription: Identifiable, Codable {
    var userId: String
    var lectureId: String

    var id: String { userId + "_" + lectureId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case lectureId = "lecture_id"
    }
}

extension UserSubscription {
    static let mock: UserSubscription = UserSubscription(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        lectureId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C1"
    )
}
