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
        let text: String = message.text + "이 내용을 아주 쉽고 간단하게 핵심만 요약해줘"
        let summaryText: String = try await repository.summary(texts: [text])
        let updatedMessage: Message = Message(
            id: message.id,
            text: summaryText,
            isSended: message.isSended,
            timestamp: message.timestamp
        )
        
        return updatedMessage
    }
}
