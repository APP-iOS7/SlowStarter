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
    
    func chat(texts: [String]) async throws -> Message {
        let reply: String = try await apiService.sendMessage(texts)
        return Message(text: reply, isSended: false, timestamp: Date())
    }
    
    func summary(texts: [String]) async throws -> String {
        let summaryText: String = try await apiService.sendMessage(texts)
        return summaryText
    }
}
