//
//  MessageCoreDataRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

protocol CoreDataMessageRepository {
    func saveMessage(_ message: Message) async throws
    func fetchMessages() async throws -> [Message]
    func deleteMessage(_ message: Message) async throws
    func updateMessage(_ message: Message) async throws
}
