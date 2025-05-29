//
//  DateHeaderView.swift
//  SlowStarter
//
//  Created by 멘태 on 5/29/25.
//

import UIKit

final class DateHeaderView: UICollectionReusableView {
    private let dateLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rightLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(leftLineView)
        containerView.addSubview(rightLineView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            leftLineView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftLineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            leftLineView.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            leftLineView.heightAnchor.constraint(equalToConstant: 1),
            
            rightLineView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightLineView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            rightLineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            rightLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(_ date: Date) {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        dateLabel.text = formatter.string(from: date)
    }
}
