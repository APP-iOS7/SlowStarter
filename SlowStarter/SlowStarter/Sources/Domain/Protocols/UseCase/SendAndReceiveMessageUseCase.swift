//
//  SendChatMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

struct SendAndReceiveMessageUseCase {
    let repository: ChatRepository
    
    func execute(text: String) async throws -> Message {
        return try await repository.chat(text: text)
    }
}
