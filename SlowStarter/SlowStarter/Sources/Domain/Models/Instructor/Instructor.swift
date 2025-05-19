

import Foundation

struct Instructor: Identifiable, Codable {
    var instructorId: String
    var name: String?
    var nickname: String?
    var profileImageURL: String?

    var id: String { instructorId }

    enum CodingKeys: String, CodingKey {
        case instructorId = "instructor_id"
        case name
        case nickname
        case profileImageURL = "profile_image_url"
    }
}

extension Instructor {
    static let mock: Instructor = Instructor(
        instructorId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C4",
        name: "Jane Smith",
        nickname: "jane",
        profileImageURL: "https://example.com/instructor.jpg"
    )
}
