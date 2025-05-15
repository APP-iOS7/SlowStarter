//
//  SendChatMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

struct SendChatMessageUseCase {
    let repository: ChatRepository
    
    func execute(message: String) async throws -> ChatMessage {
        return try await repository.send(message: message)
    }
}
