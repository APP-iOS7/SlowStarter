import Foundation

struct Lecture: Identifiable, Codable {
    var lectureId: String
    var instructorId: String
    var title: String?
    var description: String?
    var thumbCount: Int

    var id: String { lectureId }

    enum CodingKeys: String, CodingKey {
        case lectureId = "lecture_id"
        case instructorId = "instructor_id"
        case title
        case description
        case thumbCount = "thumb_count"
    }
}

extension Lecture {
    static let mock: Lecture = Lecture(
        lectureId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C1",
        instructorId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C4",
        title: "iOS Development Basics",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt eget nullam non. Quis hendrerit dolor magna eget est lorem ipsum dolor sit. Volutpat odio facilisis mauris sit amet massa. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Mi eget mauris pharetra et. Non tellus orci ac auctor augue. Elit at imperdiet dui accumsan sit. Ornare arcu dui vivamus arcu felis. Egestas integer eget aliquet nibh praesent. In hac habitasse platea dictumst quisque sagittis purus. Pulvinar elementum integer enim neque volutpat ac.",
        thumbCount: 0
    )
}
