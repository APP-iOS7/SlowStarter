import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    private let dailyIdentifier = "daily_mission_notification"
    private let temporaryIdentifier = "tomorrow_once_notification"

    // MARK: - 권한 요청

    func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }

    // MARK: - 알림 카테고리 등록

    func registerCategories() {
        let category = UNNotificationCategory(
            identifier: "MISSION_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        center.setNotificationCategories([category])
    }

    // MARK: - 반복 알림 예약 (중복 방지)
    func scheduleDailyNotification(hour: Int, minute: Int, title: String, body: String) async throws {
        guard try await requestAuthorization() else { return }

        // 중복 예약 방지
        let isAlreadyScheduled = await isNotificationScheduled()
        if isAlreadyScheduled {
            print("⚠️ 알림이 이미 예약되어 있으므로 무시됩니다.")
            return
        }

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = makeNotificationContent(title: title, body: body)

        let request = UNNotificationRequest(identifier: dailyIdentifier, content: content, trigger: trigger)
        try await center.add(request)
    }

    // MARK: - 오늘만 건너뛰기 (중복 방지)
    func skipTodayAndScheduleTomorrow(hour: Int, minute: Int, title: String, body: String) async throws {
        // 중복 방지 (이미 내일 단일 예약이 되어 있는 경우)
        let isAlreadyScheduled = await isNotificationScheduled()
        if isAlreadyScheduled {
            print("⚠️ 이미 알림이 예약되어 있어 오늘 스킵 동작은 무시됩니다.")
            return
        }

        // 기존 알림 제거 후 내일만 예약
        cancelAllNotifications()

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = makeNotificationContent(title: title, body: body)

        let request = UNNotificationRequest(identifier: temporaryIdentifier, content: content, trigger: trigger)
        try await center.add(request)
    }

    // MARK: - 모든 알림 비활성화

    func cancelAllNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyIdentifier, temporaryIdentifier])
    }

    // MARK: - 알림 상태 확인

    func isNotificationScheduled() async -> Bool {
        let requests = await center.pendingNotificationRequests()
        return requests.contains { $0.identifier == dailyIdentifier || $0.identifier == temporaryIdentifier }
    }

    // MARK: - 알림 생성

    private func makeNotificationContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "MISSION_CATEGORY"
        content.sound = .default
        return content
    }
}
