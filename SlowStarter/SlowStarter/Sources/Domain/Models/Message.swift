//
//  Chat.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

struct Message: Hashable, Identifiable {
    let id: UUID
    var text: String
    let isSended: Bool
    let timestamp: Date
    
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        return formatter.string(from: timestamp)
    }
    
    init(id: UUID = UUID(), text: String, isSended: Bool, timestamp: Date) {
        self.id = id
        self.text = text
        self.isSended = isSended
        self.timestamp = timestamp
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
