import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {} // 외부에서 인스턴스 생성을 막음
    
    // MARK: - 알림 카테고리 정의
    // Notification Content Extension의 Info.plist에 설정한 categoryIdentifier와 동일해야 한다.
    let repeatTimeNotificationCategoryIdentifier = "REPEATTIMECATEGORY"
    let chatNotificationCategoryIdentifier = "CHATCATEGORY"
    
    // MARK: - 주기적 복습 알림 스케줄링
    /// 특정 시간 간격으로 반복되는 복습 알림을 스케줄링한다.
    /// - Parameters:
    ///   - title: 알림 제목
    ///   - body: 알림 본문
    ///   - timeInterval: 알림 반복 간격 (초 단위). 최소 60초 (1분).
    ///   - identifier: 알림을 식별할 고유 ID (같은 ID로 호출하면 기존 알림 업데이트)
    func scheduleReviewNotification(title: String, body: String, timeInterval: TimeInterval, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default // 기본 알림 소리
        content.categoryIdentifier = repeatTimeNotificationCategoryIdentifier // 복습 알림 카테고리 설정
        
        // TimeIntervalTrigger는 최소 60초 이상이어야 반복 가능
        // repeats: true로 설정하여 주기적으로 반복되도록 한다.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(60, timeInterval), repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("복습 알림 스케줄링 실패 (\(identifier)): \(error.localizedDescription)")
            } else {
                print("복습 알림 스케줄링 성공: \(identifier)")
            }
        }
    }
    
    /// 특정 요일의 특정 시간에 반복되는 복습 알림을 스케줄링합니다.
    /// - Parameters:
    ///   - title: 알림 제목
    ///   - body: 알림 본문
    ///   - hour: 알림이 발생할 시간 (24시간 형식)
    ///   - minute: 알림이 발생할 분
    ///   - weekday: 알림이 발생할 요일 (1=일요일, 2=월요일, ... 7=토요일)
    ///   - identifier: 알림을 식별할 고유 ID
    func scheduleDailyReviewNotification(title: String, body: String, hour: Int, minute: Int, weekday: Int? = nil, identifier: String) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        if let weekday = weekday {
            dateComponents.weekday = weekday // 특정 요일 설정 (예: 2=월요일)
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = repeatTimeNotificationCategoryIdentifier
        
        // CalendarNotificationTrigger는 특정 날짜/시간에 반복 가능
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("복습 알림 스케줄링 실패 (\(identifier)): \(error.localizedDescription)")
            } else {
                print("복습 알림 스케줄링 성공: \(identifier)")
            }
        }
    }
    
    // MARK: - 채팅 메시지 알림 발송
    /// 새로운 채팅 메시지 알림을 즉시 발송합니다.
    /// - Parameters:
    ///   - senderName: 메시지를 보낸 사람의 이름 (예: "강사", "인공지능 챗봇")
    ///   - messageBody: 메시지 내용
    ///   - conversationID: 특정 대화를 식별하는 ID (선택 사항, 알림 탭 시 해당 채팅방으로 이동 등에 활용)
    func sendChatMessageNotification(senderName: String, messageBody: String, conversationID: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "\(senderName)님이 메시지를 보냈습니다."
        content.body = messageBody
        content.sound = .default // 기본 알림 소리
        content.categoryIdentifier = chatNotificationCategoryIdentifier // 채팅 알림 카테고리 설정
        
        // userInfo에 추가 정보 포함 가능 (예: conversationID)
        if let convID = conversationID {
            content.userInfo = ["conversationID": convID]
        }
        
        // 즉시 알림을 보내기 위해 트리거를 nil로 설정하거나 UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) 사용
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // 고유 ID 사용
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("채팅 알림 발송 실패: \(error.localizedDescription)")
            } else {
                print("채팅 알림 발송 성공")
            }
        }
    }
    
    // MARK: - 알림 취소 (선택 사항)
    // 특정 식별자를 가진 알림을 취소합니다.
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("알림 취소됨: \(identifier)")
    }
    
    // 모든 대기 중인 알림을 취소합니다.
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("모든 대기 중인 알림 취소됨")
    }
}
