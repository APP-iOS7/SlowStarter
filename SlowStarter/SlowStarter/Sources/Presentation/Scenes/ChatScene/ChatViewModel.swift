//
//  SlowChatViewModel.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation
import Combine

enum MessageUpdate {
    case initialLoad([AIChatMessage]) // 초기화
    case append(AIChatMessage) // 최신 메시지 추가
    case prepend([AIChatMessage]) // 이전 메시지 추가
    case summarize(UUID) // 요약 메시지
}

final class ChatViewModel: ObservableObject {
    // MARK: - Properties
    private(set) var messages: [AIChatMessage] = []
    @Published private(set) var isLoading: Bool = false
    
    private let messageUpdateSubject: PassthroughSubject<MessageUpdate, Never> = PassthroughSubject()
    var messageUpdatePublisher: AnyPublisher<MessageUpdate, Never> {
        return messageUpdateSubject.eraseToAnyPublisher()
    }
    
    private let chatUseCase: DefaultChatUseCase
    private let summaryUseCase: DefaultSummaryUseCase
    private let coreDataManager: CoreDataManager
    
    private var recentMessages: [AIChatMessage] {
        let size: Int = min(10, messages.count) // 10개, 그보다 적다면 있는 만큼
        return Array(messages[(messages.count - size)...]) // 뒤에서부터 size 만큼 꺼냄
    }
    
    init(chat: DefaultChatUseCase, summary: DefaultSummaryUseCase, coreDataManager: CoreDataManager
         ) {
        self.chatUseCase = chat
        self.summaryUseCase = summary
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Functions
    func message(with id: UUID) -> AIChatMessage? {
        return messages.first { $0.id == id }
    }
    
    func message(at index: Int) -> AIChatMessage? {
        guard messages.indices.contains(index) else { return nil }
        return messages[index]
    }
    
    func initialFetchMessages() {
        Task { @MainActor in
            do {
                let newMessages: [AIChatMessage] = try await coreDataManager.fetchMessages().reversed()
                guard !newMessages.isEmpty else { return } // 코어데이터가 비어있으면 종료
                messages = newMessages // 뷰모델에 배열 저장
                messageUpdateSubject.send(.initialLoad(messages)) // 컨트롤러에 초기 배열 발행
            } catch {
                addErrorMessageToChat("메시지를 불러오지 못했습니다.")
            }
        }
    }
    
    func fetchPreviousMessages() {
        Task { @MainActor in
            do {
                let prependMessages: [AIChatMessage] = try await coreDataManager.fetchMessages(before: messages.first).reversed()
                guard !prependMessages.isEmpty else { return } // 더이상 불러올 데이터가 없으면 종료
                
                messages.insert(contentsOf: prependMessages, at: 0) // 배열 앞에 저장
                messageUpdateSubject.send(.prepend(prependMessages)) // 컨트롤러에 이전 메시지 발행
            } catch {
                addErrorMessageToChat("메시지를 불러오지 못했습니다.")
            }
        }
    }
    
    func didTapSendButton(text: String) {
        Task { @MainActor in
            do {
                let myMessage: AIChatMessage = AIChatMessage(text: text, isSended: true, timestamp: Date())
                messages.append(myMessage) // 내 메시지 저장
                messageUpdateSubject.send(.append(myMessage)) // 컨트롤러에 내 메시지 발행
                
                isLoading = true // 로딩 시작
                try await coreDataManager.saveMessage(myMessage) // 코어데이터에 내 메시지 저장
                
                // 대화의 맥락을 유지하기 위해 최근 메시지를 함께 보냄
                let sendMessages: [AIChatMessage] = recentMessages
                let newMessage = try await chatUseCase.execute(messages: sendMessages) // 답장 받아오기
                messages.append(newMessage) // 뷰모델에 답장 저장
                messageUpdateSubject.send(.append(newMessage)) // 컨트롤러에 답장 발행
                
                try await coreDataManager.saveMessage(newMessage) // 코어데이터에 답장 저장
            } catch let apiError as ChatAPIError {
                addErrorMessageToChat(apiError.localizedDescription)
            } catch {
                addErrorMessageToChat("알 수 없는 오류가 발생했습니다. 다시 시도해주세요.")
            }
            
            isLoading = false // 로딩 종료
        }
    }
    
    func didTapSummaryButton(message: AIChatMessage) {
        Task { @MainActor in
            do {
                guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
                let summaryMessage: AIChatMessage = try await summaryUseCase.execute(message: message) // 요약 요청
                messages[index] = summaryMessage // 요약 메시지 저장
                messageUpdateSubject.send(.summarize(summaryMessage.id)) // 컨트롤러에 요약메시지 발행
                
                try await coreDataManager.updateMessage(summaryMessage) // 코어데이터에 요약메시지 저장
            } catch let apiError as ChatAPIError {
                addErrorMessageToChat(apiError.localizedDescription)
            } catch {
                addErrorMessageToChat("알 수 없는 오류가 발생했습니다. 다시 시도해주세요.")
            }
        }
    }
    
    private func addErrorMessageToChat(_ description: String) {
        let errorMessage: AIChatMessage = AIChatMessage(text: description, isSended: false, timestamp: Date())
        messages.append(errorMessage)
        messageUpdateSubject.send(.append(errorMessage))
    }
}
