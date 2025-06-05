//
//  ReceivedChatCell.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import UIKit

final class ReceivedMessageCell: UICollectionViewCell {
    // MARK: - Properties
    var message: AIChatMessage? {
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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false 
        return indicator
    }()
    
    private let minimumRightMargin: CGFloat = 100.0
    
    // MARK: - Initializer
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
    
    private func setupUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(summaryButtom)
        contentView.addSubview(activityIndicator)
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
            timeLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -5),
            
            activityIndicator.topAnchor.constraint(equalTo: summaryButtom.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: summaryButtom.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: summaryButtom.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: summaryButtom.bottomAnchor)
        ])
        
        messageView.layer.cornerRadius = 8
        summaryButtom.layer.cornerRadius = 8
    }
    
    func setPreferredMaxLayoutWidth(forCellWidth cellWidth: CGFloat) {
        // 전체크기 - messageView 좌측여백 - messageLabel 좌측여백 - messageLabel 우측여백 - 우측최소여백
        messageLabel.preferredMaxLayoutWidth = cellWidth - 12 - 12 - 12 - minimumRightMargin
    }
    
    func showSummaryLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            summaryButtom.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            summaryButtom.isHidden = false
        }
    }
    
    // 재사용을 위해 내용물 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
        messageLabel.text = nil
        timeLabel.text = nil
        summaryButtom.removeTarget(nil, action: nil, for: .allEvents)
    }
}
