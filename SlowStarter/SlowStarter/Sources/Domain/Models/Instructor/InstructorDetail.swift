

import Foundation

struct InstructorDetail: Identifiable, Codable {
    var instructorId: String
    var address: String?
    var phoneNumber: String?

    var id: String { instructorId }

    enum CodingKeys: String, CodingKey {
        case instructorId = "instructor_id"
        case address
        case phoneNumber = "phone_number"
    }
}

extension InstructorDetail {
    static let mock: InstructorDetail = InstructorDetail(
        instructorId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C4",
        address: "Seoul, Korea",
        phoneNumber: "010-5678-1234"
    )
}
