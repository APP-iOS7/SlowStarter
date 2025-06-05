//
//  NotificationManager.swift
//  SlowStarter
//
//  Created by sean on 5/30/25.
//

import Foundation
import UserNotifications

final class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]) { granted, _ in
                completion(granted)
            }
    }
    
    func scheduleNotification(title: String, body: String, after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "RepeatLearnNotificatoin"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyMissionNotification(title: String, body: String) {
//        var dateComponents = DateComponents()
//        dateComponents.hour = 19
//        dateComponents.minute = 0
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date().addingTimeInterval(60)) // 1분 뒤

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "MISSION_CATEGORY"
        content.userInfo = [
            "imageURL": "https://example.com/images/mission1.png"
        ]

        let request = UNNotificationRequest(
            identifier: "daily_mission",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "[테스트] 오늘의 미션이 도착했습니다"
        content.body = "지금 퀴즈를 풀고 복습해보세요!"
        content.categoryIdentifier = "MISSION_CATEGORY"
        content.userInfo = [
            "imageURL": "https://example.com/images/test.png"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test_mission",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func registerNotificationCategories() {
        let category = UNNotificationCategory(
            identifier: "RepeatLearnNotificatoin",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
