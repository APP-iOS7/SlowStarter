import Foundation

struct DefaultSummaryUseCase: SummaryUseCase {
    let repository: ChatRepository
    
    func execute(message: Messages) async throws -> Messages {
        let summaryText: String = try await repository.summary(text: message.text)
        let updatedMessage: Messages = Messages(
            id: message.id,
            text: summaryText,
            isSended: message.isSended,
            timestamp: message.timestamp
        )
        
        return updatedMessage
    }
}
