//
//  ChatAPIRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

protocol ChatRepository {
    func chat(messages: [Messages]) async throws -> Messages
    func summary(text: String) async throws -> String
}
