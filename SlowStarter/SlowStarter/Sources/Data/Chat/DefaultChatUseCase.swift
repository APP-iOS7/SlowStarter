import Foundation

struct DefaultChatUseCase: ChatUseCase {
    let repository: ChatRepository
    
    func execute(messages: [Message]) async throws -> Message {
        return try await repository.chat(messages: messages)
    }
}
