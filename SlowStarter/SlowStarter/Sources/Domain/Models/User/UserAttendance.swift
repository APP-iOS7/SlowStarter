

import Foundation

struct UserAttendance: Identifiable, Codable {
    var userId: String
    var attendedDate: String  // yyyy-MM-dd 형태의 날짜
    var description: String?
    
    var id: String { userId + "_" + attendedDate }
    
    var attendedDateAsDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: attendedDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case attendedDate = "attended_date"
        case description
    }
}

extension UserAttendance {
    static let mock: UserAttendance = UserAttendance(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        attendedDate: "2025-05-15",
        description: "test"
    )
}
