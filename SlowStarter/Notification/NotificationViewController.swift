//
//  NotificationViewController.swift
//  Notification
//
//  Created by sean on 5/30/25.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutUI()
        LayoutConstraint()
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        
        titleLabel.text = content.title
        messageLabel.text = content.body
        
        if let imageURLString = content.userInfo["imageURL"] as? String,
           let imageURL = URL(string: imageURLString),
           let data = try? Data(contentsOf: imageURL),
           let image = UIImage(data: data) {
            imageView.image = image
        }
    }
    
    private func layoutUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        imageView.contentMode = .scaleAspectFit
        
        [titleLabel, messageLabel, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func LayoutConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}
