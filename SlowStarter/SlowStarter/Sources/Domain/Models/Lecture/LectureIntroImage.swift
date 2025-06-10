

import Foundation


struct LectureIntroImage: Identifiable, Codable {
    var lectureId: String
    var imageURL: String?

    var id: String { lectureId }

    enum CodingKeys: String, CodingKey {
        case lectureId = "lecture_id"
        case imageURL = "image_url"
    }
}

extension LectureIntroImage {
    static let mock: LectureIntroImage = LectureIntroImage(
        lectureId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C1",
        imageURL: "https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    )
}
