//
//  Chat.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation
import CoreData

struct AIChatMessage: Hashable, Identifiable {
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

extension AIChatMessage {
    // Message -> MessageEntity
    func toManagedObject(in context: NSManagedObjectContext) -> MessageEntity {
        let entity: MessageEntity = MessageEntity(context: context)
        entity.id = id
        entity.text = text
        entity.isSended = isSended
        entity.timestamp = timestamp
        return entity
    }
    
    // MessageEntity -> Message
    static func from(_ entity: MessageEntity) -> AIChatMessage? {
        guard let id = entity.id,
              let text = entity.text,
              let timestamp = entity.timestamp else {
            return nil
        }
        
        let item: AIChatMessage = AIChatMessage(id: id, text: text, isSended: entity.isSended, timestamp: timestamp)
        return item
    }
}
