//
//  ChatAPIService.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

enum ChatAPIError: Error {
    case missingAPIKey
    case invalidURL
    case encodingFailed
    case invalidResponse
    case parsingFailed
    case noInternet
    case timedOut
    case networkError(URLError)
    case unknown
}

extension ChatAPIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API 키가 누락되었습니다."
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .encodingFailed:
            return "데이터 인코딩에 실패했습니다."
        case .invalidResponse:
            return "유효하지 않은 서버 응답입니다."
        case .parsingFailed:
            return "데이터 파싱에 실패했습니다."
        case .noInternet:
            return "인터넷 연결을 확인하세요."
        case .timedOut:
            return "요청이 시간 초과되었습니다."
        case .networkError(let error):
            return "네트워크 오류가 발생했습니다: \(error.localizedDescription)"
        case .unknown:
            return "알 수 없는 오류"
        }
    }
}

final class ChatAPIService {
    func sendMessage(_ systemPrompt: String, _ messages: [Messages]) async throws -> String {
        guard let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String else {
            throw ChatAPIError.missingAPIKey
        }
        
        let urlString: String = "\(APIConstants.geminiApiUrl + apiKey)"
        guard let url: URL = URL(string: urlString) else {
            throw ChatAPIError.invalidURL
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application", forHTTPHeaderField: "Content-Type")
        
        var contents: [Content] = [Content(role: "user", parts: [Part(text: systemPrompt)])]
        for message in messages {
            let role: String = message.isSended ? "user" : "model" // 내가 보낸 메시지인지, AI 답변인지 구분
            contents.append(Content(role: role, parts: [Part(text: message.text)]))
        }
        
        do {
            let body = MessageRequest(contents: contents)
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("JSON 인코딩 에러: \(error.localizedDescription)")
            throw ChatAPIError.encodingFailed
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ChatAPIError.invalidResponse
            }
            
            return String(data: data, encoding: .utf8) ?? ""
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                throw ChatAPIError.noInternet
            case .timedOut:
                throw ChatAPIError.timedOut
            default:
                throw ChatAPIError.networkError(urlError)
            }
        } catch {
            throw ChatAPIError.unknown
        }
    }
}
