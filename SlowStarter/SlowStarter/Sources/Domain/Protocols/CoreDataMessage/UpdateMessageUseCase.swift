//
//  UpdateMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

protocol UpdateMessageUseCase {
    func execute(_ message: Message) async throws
}

class DefaultUpdateMessageUseCase: UpdateMessageUseCase {
    private let repository: CoreDataMessageRepository
    
    init(repository: CoreDataMessageRepository) {
        self.repository = repository
    }
    
    func execute(_ message: Message) async throws {
        try await repository.updateMessage(message)
    }
}
