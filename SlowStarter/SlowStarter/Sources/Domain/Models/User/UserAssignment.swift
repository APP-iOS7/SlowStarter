

import Foundation

struct UserAssignment: Identifiable, Codable {
    var userId: String
    var vodId: String
    var imageURL: String?
    var description: String?
    var submittedAt: Date?

    var id: String { userId + "_" + vodId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case vodId = "vod_id"
        case imageURL = "image_url"
        case description
        case submittedAt = "submitted_at"
    }
}

extension UserAssignment {
    static let mock: UserAssignment = UserAssignment(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        vodId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C3",
        imageURL: "https://example.com/assignment.jpg",
        description: "My first assignment",
        submittedAt: Date()
    )
}
