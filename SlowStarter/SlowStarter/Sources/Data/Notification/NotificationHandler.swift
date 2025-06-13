import UserNotifications

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        if notification.request.identifier == "daily_mission_notification" ||
           notification.request.identifier == "tomorrow_once_notification" {
            completionHandler([])
        } else {
            completionHandler([.banner, .sound])
        }
    }
}
