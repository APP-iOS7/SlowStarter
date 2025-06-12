

import Foundation

enum AttendanceType: String, Codable {
    case assignment
    case video
    case attendance
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()

        self = AttendanceType(rawValue: rawValue) ?? .unknown
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

struct UserAttendance: Identifiable, Codable {
    var userId: String
    var attendedDate: String
    var description: String?
    var type: AttendanceType
    
    var id: String { userId + "_" + attendedDate }
    
    var attendedDateAsDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: attendedDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case attendedDate = "attended_date"
        case description
        case type
    }
}

extension UserAttendance {
    static let mock: UserAttendance = UserAttendance(
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        attendedDate: "2025-05-15",
        description: "test",
        type: .assignment
    )
}
