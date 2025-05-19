//
//  SummaryChatMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/16/25.
//

protocol SummaryUseCase {
    func execute(message: Message) async throws -> Message
}

struct DefaultSummaryUseCase: SummaryUseCase {
    let repository: ChatRepository
    
    func execute(message: Message) async throws -> Message {
        let summaryText: String = try await repository.summary(texts: [message.text])
        let updatedMessage: Message = Message(
            id: message.id,
            text: summaryText,
            isSended: message.isSended,
            timestamp: message.timestamp
        )
        
        return updatedMessage
    }
}
