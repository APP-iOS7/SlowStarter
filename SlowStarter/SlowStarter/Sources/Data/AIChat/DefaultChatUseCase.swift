import Foundation

struct DefaultChatUseCase: ChatUseCase {
    let repository: ChatRepository
    
    func execute(messages: [Messages]) async throws -> Messages {
        return try await repository.chat(messages: messages)
    }
}
