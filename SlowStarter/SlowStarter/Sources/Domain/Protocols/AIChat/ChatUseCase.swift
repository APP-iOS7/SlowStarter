//
//  SendChatMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

protocol ChatUseCase {
    func execute(messages: [Message]) async throws -> Message
}

