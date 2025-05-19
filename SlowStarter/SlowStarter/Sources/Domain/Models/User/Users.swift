
import Foundation

struct Users: Identifiable, Codable {
    var userId: String
    var name: String?
    var age: Int?
    var nickname: String?
    var email: String?
    var profileImageURL: String?
    var createdAt: Date?
    
    var id: String { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case age
        case nickname
        case email
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
    }
}

extension Users {
    static let mock: Users = Users(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        name: "John Doe",
        age: 28,
        nickname: "johnny",
        email: "john@\(Date().description).com",
        profileImageURL: "https://example.com/profile.jpg",
        createdAt: Date()
    )
}
