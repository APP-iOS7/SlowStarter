//
//  ChatRepositoryImpl.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

final class ChatRepositoryImplementation: ChatRepository {
    private let apiService: ChatAPIService
    
    init(apiService: ChatAPIService) {
        self.apiService = apiService
    }
    
    func chat(texts: [String]) async throws -> Message {
        let reply: String = try await apiService.sendMessage(texts)
        let text: String = try parseChatMessage(from: reply)
        return Message(text: text, isSended: false, timestamp: Date())
    }
    
    func summary(texts: [String]) async throws -> String {
        let reply: String = try await apiService.sendMessage(texts)
        let summaryText: String = try parseChatMessage(from: reply)
        return summaryText
    }
    
    private func parseChatMessage(from data: String) throws -> String {
        guard let jsonData = data.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw ChatAPIError.parsingFailed
        }
        
        return text
    }
}
