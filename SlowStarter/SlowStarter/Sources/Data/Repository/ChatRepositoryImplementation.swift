//
//  ChatRepositoryImpl.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

final class ChatRepositoryImplementation: ChatRepository {
    private let apiService: ChatAPIService
    
    private let chatCommand: String = """
        대화의 맥락을 유지하기 위해서 이전 대화들을 함께 가져왔어요 (없을수도 있어요)
        이전 대화 내용을 바탕으로 사용자의 마지막 대화에 적절하게 응답해 주세요
        최대한 간결하고 이해하기 쉬운 내용으로 구성해주세요.
    """
    
    private let summaryCommand: String = "이 내용을 아주 쉽고 간단하게 핵심만 요약해줘"
    
    init(apiService: ChatAPIService) {
        self.apiService = apiService
    }
    
    func chat(texts: [String]) async throws -> Message {
        let reply: String = try await apiService.sendMessage(chatCommand, texts)
        let text: String = try parseChatMessage(from: reply)
        return Message(text: text, isSended: false, timestamp: Date())
    }
    
    func summary(texts: [String]) async throws -> String {
        let reply: String = try await apiService.sendMessage(summaryCommand, texts)
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
