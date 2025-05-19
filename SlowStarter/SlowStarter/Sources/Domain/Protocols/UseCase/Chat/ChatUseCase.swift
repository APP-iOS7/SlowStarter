//
//  SendChatMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

protocol ChatUseCase {
    func execute(texts: [String]) async throws -> Message
}

struct DefaultChatUseCase: ChatUseCase {
    let repository: ChatRepository
    
    func execute(texts: [String]) async throws -> Message {
        return try await repository.chat(texts: texts)
    }
}
