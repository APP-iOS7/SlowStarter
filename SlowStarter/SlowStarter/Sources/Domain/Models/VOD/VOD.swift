
import Foundation

struct VOD: Identifiable, Codable {
    var vodId: String
    var title: String?
    var description: String?
    var createdAt: Date?

    var id: String { vodId }

    enum CodingKeys: String, CodingKey {
        case vodId = "vod_id"
        case title
        case description
        case createdAt = "created_at"
    }
}

extension VOD {
    static let mock: VOD = VOD(
        vodId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C3",
        title: "VOD #1",
        description: "Introduction to Swift",
        createdAt: Date()
    )
}
