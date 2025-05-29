//
//  NotificationViewController.swift
//  SlowStarterNotification
//
//  Created by sean on 5/29/25.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    var customLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0 // 여러 줄 표시 가능
        label.textColor = .white
        return label
    }()
    
    // 채팅 알림용 보낸 사람 이름 레이블
    var senderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(customLabel)
        view.addSubview(senderLabel)
        
        NSLayoutConstraint.activate([
            senderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            senderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            senderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            customLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            customLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            customLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
    }
    
    func didReceive(_ notification: UNNotification) {
        let category = notification.request.content.categoryIdentifier
        
        if category == NotificationManager.shared.chatNotificationCategoryIdentifier {
            // 채팅 알림인 경우
            senderLabel.isHidden = false
            customLabel.text = notification.request.content.body
            
            // userInfo에서 보낸 사람 이름 가져오기 (메인 앱에서 보낼 때 userInfo에 포함시켰다면)
            if let senderName = notification.request.content.userInfo["senderName"] as? String {
                senderLabel.text = "\(senderName)"
            } else {
                senderLabel.text = "새로운 메시지"
            }
            
        } else if category == NotificationManager.shared.repeatTimeNotificationCategoryIdentifier {
            // 복습 알림인 경우
            senderLabel.isHidden = true // 보낸 사람 레이블 숨기기
            customLabel.text = notification.request.content.body
            customLabel.font = UIFont.boldSystemFont(ofSize: 18) // 폰트 크기 변경 예시
        } else {
            // 기타 알림
            senderLabel.isHidden = true
            customLabel.text = notification.request.content.body
        }
    }
}

//#Preview {
//    NotificationViewController()
//}
