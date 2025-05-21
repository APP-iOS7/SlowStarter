//
//  MessageCoreDataRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

protocol CoreDataMessageRepository {
    func saveMessage(_ message: Messages) async throws
    func fetchMessages() async throws -> [Messages]
    func deleteMessage(_ message: Messages) async throws
    func updateMessage(_ message: Messages) async throws
}
