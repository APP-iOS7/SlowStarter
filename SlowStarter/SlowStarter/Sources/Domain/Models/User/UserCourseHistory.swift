import Foundation

struct UserCourseHistory: Identifiable, Codable {
    let courseId: String
    let userId: String
    let courseTitle: String
    let isActive: Bool
    let subscribedAt: Date

    var id: String { courseId }

    enum CodingKeys: String, CodingKey {
        case courseId = "course_id"
        case userId = "user_id"
        case courseTitle = "course_title"
        case isActive = "is_active"
        case subscribedAt = "subscribed_at"
    }
}
