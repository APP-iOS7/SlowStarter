//
//  MessageCoreDataRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

protocol CoreDataMessageRepository {
    func saveMessage(_ message: AIChatMessage) async throws
    func fetchMessages() async throws -> [AIChatMessage]
    func deleteMessage(_ message: AIChatMessage) async throws
    func updateMessage(_ message: AIChatMessage) async throws
}
