
import Foundation

struct UserDetail: Identifiable, Codable {
    var userId: String
    var address: String?
    var phoneNumber: String?

    var id: String { userId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case address
        case phoneNumber = "phone_number"
    }
}

extension UserDetail {
    static let mock: UserDetail = UserDetail(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        address: "123 Main Street, NY",
        phoneNumber: "010-1234-5678"
    )
}
