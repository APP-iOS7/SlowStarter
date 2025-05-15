//
//  ChatRepositoryImpl.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

final class ChatRepositoryImpl: ChatRepository {
    private let apiService: ChatAPIService
    
    init(apiService: ChatAPIService) {
        self.apiService = apiService
    }
    
    func send(message: String) async throws -> ChatMessage {
        let text: String = try await apiService.sendMessage(message)
        return ChatMessage(text: text, isSended: false, timestamp: Date())
    }
}
