//
//  ChatAPIRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

protocol ChatRepository {
    func send(message: String) async throws -> ChatMessage
}
