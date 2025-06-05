//
//  SendedChatCell.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import UIKit

final class SendedMessageCell: UICollectionViewCell {
    // MARK: - Properties
    var message: AIChatMessage? {
        didSet {
            configure()
        }
    }
    
    private let messageView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .yellow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.clipsToBounds = true
        
        // 세로 압축 저항 최대로 설정 (텍스트 잘림 방지)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minimumLeftMargin: CGFloat = 100.0
    
    // MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    private func configure() {
        messageLabel.text = message?.text
        timeLabel.text = message?.timeText
    }
    
    // Self-Sizing 셀의 최종 크기를 반환
    private func setupUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(timeLabel)
        messageView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            messageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 12),
            messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            messageLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -8),
            
            timeLabel.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -5),
            timeLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -5)
        ])
        
        messageView.layer.cornerRadius = 8
    }
    
    func setPreferredMaxLayoutWidth(forCellWidth cellWidth: CGFloat) {
        // 전체크기 - messageView 우측여백 - messageLabel 우측여백 - messageLabel 좌측여백 - 좌측최소여백
        messageLabel.preferredMaxLayoutWidth = cellWidth - 12 - 12 - 12 - minimumLeftMargin
    }
    
    // 재사용을 위해 내용물 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
        timeLabel.text = nil
    }
}
