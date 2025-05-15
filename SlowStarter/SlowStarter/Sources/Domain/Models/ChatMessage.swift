//
//  Chat.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

struct ChatMessage: Hashable {
    let text: String
    let isSended: Bool
    let timestamp: Date
    
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        return formatter.string(from: timestamp)
    }
}
