

import Foundation

struct Lecture: Identifiable, Codable {
    var lectureId: String
    var instructorId: String
    var title: String?
    var description: String?

    var id: String { lectureId }

    enum CodingKeys: String, CodingKey {
        case lectureId = "lecture_id"
        case instructorId = "instructor_id"
        case title
        case description
    }
}

extension Lecture {
    static let mock: Lecture = Lecture(
        lectureId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C1",
        instructorId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C4",
        title: "iOS Development Basics",
        description: "Learn SwiftUI and Combine from scratch"
    )
}
