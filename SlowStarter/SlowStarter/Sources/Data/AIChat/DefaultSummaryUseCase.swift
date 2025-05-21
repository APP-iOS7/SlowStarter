import Foundation

struct DefaultSummaryUseCase: SummaryUseCase {
    let repository: ChatRepository
    
    func execute(message: Message) async throws -> Message {
        let summaryText: String = try await repository.summary(text: message.text)
        let updatedMessage: Message = Message(
            id: message.id,
            text: summaryText,
            isSended: message.isSended,
            timestamp: message.timestamp
        )
        
        return updatedMessage
    }
}
