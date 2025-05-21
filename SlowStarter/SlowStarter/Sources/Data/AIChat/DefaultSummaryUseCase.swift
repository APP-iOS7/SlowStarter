import Foundation

struct DefaultSummaryUseCase: SummaryUseCase {
    let repository: ChatRepository
    
    func execute(message: AIChatMessage) async throws -> AIChatMessage {
        let summaryText: String = try await repository.summary(text: message.text)
        let updatedMessage: AIChatMessage = AIChatMessage(
            id: message.id,
            text: summaryText,
            isSended: message.isSended,
            timestamp: message.timestamp
        )
        
        return updatedMessage
    }
}
