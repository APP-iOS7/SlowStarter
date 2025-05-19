//
//  SlowChatViewModel.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    // MARK: - Properties
    private var messages: [Message] = []
    
    private let sendAndReceivedUsecase: SendAndReceiveMessageUseCase
    private let summaryUsecase: SummaryMessageUseCase
    
    private let saveMessageUseCase: SaveMessageUseCase
    private let fetchMessagesUseCase: FetchMessageUseCase
    private let deleteMessageUseCase: DeleteMessageUseCase
    private let updateMessageUseCase: UpdateMessageUseCase
    
    var allMessages: [Message] {
        return messages
    }
    
    private var recentMessages: [String] {
        let size: Int = min(10, messages.count) // 10개, 그보다 적다면 있는 만큼
        return Array(messages[(messages.count - size)...]).map { $0.text } // 뒤에서부터 size 만큼 꺼냄
    }
    
    private var addMessageSubject: PassthroughSubject<Message.ID, ChatAPIError> = PassthroughSubject()
    var addMessagePublisher: AnyPublisher<Message.ID, ChatAPIError> {
        return addMessageSubject.eraseToAnyPublisher()
    }
    
    private var summaryMessageSubject: PassthroughSubject<Message.ID, ChatAPIError> = PassthroughSubject()
    var summaryMessagePublisher: AnyPublisher<Message.ID, ChatAPIError> {
        return summaryMessageSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initializer
    init(sendAndReceive: SendAndReceiveMessageUseCase, summary: SummaryMessageUseCase,
         save: SaveMessageUseCase, fetch: FetchMessageUseCase,
         delete: DeleteMessageUseCase, update: UpdateMessageUseCase) {
        self.sendAndReceivedUsecase = sendAndReceive
        self.summaryUsecase = summary
        self.saveMessageUseCase = save
        self.fetchMessagesUseCase = fetch
        self.deleteMessageUseCase = delete
        self.updateMessageUseCase = update
    }
    
    // MARK: - Functions
    func message(with id: UUID) -> Message? {
        return messages.first { $0.id == id }
    }
    
    func fetchMessages() {
        Task {
            do {
                messages = try await fetchMessagesUseCase.execute()
                messages.forEach {
                    addMessageSubject.send($0.id)
                }
            } catch {
                
            }
        }
    }
    
    func didTapSendButton(text: String) {
        Task {
            do {
                let myMessage: Message = Message(text: text, isSended: true, timestamp: Date())
                messages.append(myMessage)
                addMessageSubject.send(myMessage.id) // Controller에 보낸 메시지 발행
                try await saveMessageUseCase.execute(myMessage) // CoreData에 보낸 메시지 저장
                
                // 대화의 맥락을 유지하기 위해 최근 메시지를 함께 보냄
                let sendMessages: [String] = recentMessages
                let newMessage = try await sendAndReceivedUsecase.execute(texts: sendMessages) // 답장 받아오기
                messages.append(newMessage)
                addMessageSubject.send(newMessage.id) // Controller에 답장 발행
                try await saveMessageUseCase.execute(newMessage) // CoreData에 답장 저장
            } catch {
                if let apiError = error as? ChatAPIError {
                    addMessageSubject.send(completion: .failure(apiError))
                } else {
                    addMessageSubject.send(completion: .failure(.unknown))
                }
            }
        }
    }
    
    func didTapSummaryButton(index: Int, message: Message) {
        Task {
            do {
                let summaryMessage: Message = try await summaryUsecase.execute(message: message)
                messages[index] = summaryMessage
                summaryMessageSubject.send(summaryMessage.id) // Controller에 요약된 메시지 발행
                try await updateMessageUseCase.execute(summaryMessage)
            } catch {
                if let apiError = error as? ChatAPIError {
                    summaryMessageSubject.send(completion: .failure(apiError))
                } else {
                    summaryMessageSubject.send(completion: .failure(.unknown))
                }
            }
        }
    }
}
