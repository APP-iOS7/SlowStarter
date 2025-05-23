//
//  ReceivedChatCell.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import UIKit

final class ReceivedMessageCell: UICollectionViewCell {
    // MARK: - Properties
    var chat: AIChatMessage? {
        didSet {
            configure()
        }
    }
    
    private let messageView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
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
    
    lazy var summaryButtom: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("요약", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cellMargin: CGFloat = 8.0
    private let minimumLeftMargin: CGFloat = 100.0
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    // 모든 frame이 결정된 이후에 필요한 동작 정의
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.preferredMaxLayoutWidth = bounds.width - cellMargin - minimumLeftMargin // label 최대 너비
    }
    
    // MARK: - Functions
    // Self-Sizing 셀의 최종 크기를 반환
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width, // width: 최대 크기
            height: UIView.layoutFittingCompressedSize.height // height: auto
        )
        
        // AutoLayout을 기반으로 실제 사이즈를 계산
        let autoLayoutSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required, // Priority = 1000, 제약이 반드시 지켜짐
            verticalFittingPriority: .fittingSizeLevel // Priority = 50, 유연한 제약, 컨텐츠에 맞는 최소 높이를 계산
        )
        
        attributes.frame.size = autoLayoutSize
        return attributes
    }
    
    private func configure() {
        messageLabel.text = chat?.text
        timeLabel.text = chat?.timeText
    }
    
    private func setupUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(summaryButtom)
        messageView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            messageView.bottomAnchor.constraint(equalTo: summaryButtom.topAnchor, constant: -4),
            
            messageLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -8),
            
            summaryButtom.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -4),
            summaryButtom.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            summaryButtom.widthAnchor.constraint(equalToConstant: 30),
            summaryButtom.heightAnchor.constraint(equalTo: summaryButtom.widthAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: 5),
            timeLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -5)
        ])
        
        messageView.layer.cornerRadius = 8
        summaryButtom.layer.cornerRadius = 8
    }
    
    func getMessageLableHeight() -> CGFloat {
        return messageLabel.frame.height
    }
    
    // 재사용을 위해 내용물 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        chat = nil
        messageLabel.text = nil
        timeLabel.text = nil
        summaryButtom.removeTarget(nil, action: nil, for: .allEvents)
    }
}
