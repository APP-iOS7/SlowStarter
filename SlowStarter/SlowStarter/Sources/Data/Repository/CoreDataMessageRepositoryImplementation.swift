//
//  MessageCoreDataRepositoryImpl.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//
import CoreData

final class CoreDataMessageRepositoryImplementation: CoreDataMessageRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveMessage(_ message: Messages) async throws {
        _ = message.toManagedObject(in: context)
        try context.save()
    }
    
    func fetchMessages() async throws -> [Messages] {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        let result = try context.fetch(request).compactMap { Messages.from($0) }
        return result
    }
    
    func deleteMessage(_ message: Messages) async throws {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", message.id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
    
    func updateMessage(_ message: Messages) async throws {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", message.id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            entity.text = message.text
            try context.save()
        }
    }
}
