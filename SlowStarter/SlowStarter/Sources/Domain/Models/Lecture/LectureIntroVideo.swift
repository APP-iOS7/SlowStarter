

import Foundation

struct LectureIntroVideo: Identifiable, Codable {
    var lectureId: String
    var videoURL: String?

    var id: String { lectureId }

    enum CodingKeys: String, CodingKey {
        case lectureId = "lecture_id"
        case videoURL = "video_url"
    }
}

extension LectureIntroVideo {
    static let mock: LectureIntroVideo = LectureIntroVideo(
        lectureId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C1",
        videoURL: "https://example.com/intro.mp4"
    )
}
