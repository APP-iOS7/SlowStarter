import Foundation

struct DefaultChatUseCase: ChatUseCase {
    let repository: ChatRepository
    
    func execute(messages: [AIChatMessage]) async throws -> AIChatMessage {
        return try await repository.chat(messages: messages)
    }
}
