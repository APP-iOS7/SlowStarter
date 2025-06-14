import Foundation

struct VOD: Identifiable, Codable {
    var vodId: String
    var lectureId: String
    var vodURL: String
    var title: String?
    var description: String?
    var createdAt: Date?

    var id: String { vodId }

    enum CodingKeys: String, CodingKey {
        case vodId = "vod_id"
        case lectureId = "lecture_id"
        case vodURL = "vod_url"
        case title
        case description
        case createdAt = "created_at"
    }
}

extension VOD {
    static let mock: VOD = VOD(
        vodId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C3",
        lectureId: "",
        vodURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        title: "VOD #1",
        description: "Introduction to Swift",
        createdAt: Date()
    )
}
