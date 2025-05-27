//
//  LectureCardCellTableViewCell.swift
//  SlowStarter
//
//  Created by sean on 5/26/25.
//

import UIKit

class LectureCardCell: UITableViewCell {
    
    static let identifier = "LectureCardCell"
    
    private let lectureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cookingClassWomanChef")
        return imageView
    }()
    
    private let heartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 18)
//        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
//        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likesIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "hand.thumbsup"))
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 18)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자세히 보기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.setTitleColor(.systemGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .systemGray
        label.numberOfLines = 3 // 라인수 제한
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let introVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("맛보기강의", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shoppingBasketButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("장바구니", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let reviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수강후기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        contentView.backgroundColor = .systemBackground // 셀 자체의 배경색
        self.selectionStyle = .none // 선택 하이라이트 없음
//        setupCardShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(lectureImageView)
        contentView.addSubview(heartButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(likesIcon)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(detailButton)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(introVideoButton)
        contentView.addSubview(shoppingBasketButton)
        contentView.addSubview(reviewButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 이미지 뷰
            lectureImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0), // 상단 패딩
            lectureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10), // 선행 패딩
            lectureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10), // 후행 패딩
            lectureImageView.heightAnchor.constraint(equalToConstant: 340), // 이미지 고정 높이
            
            // 하트 버튼
            heartButton.topAnchor.constraint(equalTo: lectureImageView.topAnchor, constant: 10),
            heartButton.trailingAnchor.constraint(equalTo: lectureImageView.trailingAnchor, constant: -10),
            heartButton.widthAnchor.constraint(equalToConstant: 30),
            heartButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: lectureImageView.topAnchor, constant: 360),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // 가격 레이블
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: likesIcon.leadingAnchor, constant: -10),
            
            // 좋아요 아이콘 및 레이블
            likesIcon.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            likesIcon.trailingAnchor.constraint(equalTo: likesCountLabel.leadingAnchor),
            likesIcon.widthAnchor.constraint(equalToConstant: 20),
            likesIcon.heightAnchor.constraint(equalToConstant: 20),
            
            likesCountLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            likesCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            likesCountLabel.widthAnchor.constraint(equalToConstant: 60),
            
            detailButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            detailButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            descriptionLabel.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: -5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 70),
            
            introVideoButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            introVideoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            introVideoButton.widthAnchor.constraint(equalToConstant: 120),
            introVideoButton.heightAnchor.constraint(equalToConstant: 30),
            
            shoppingBasketButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            shoppingBasketButton.centerYAnchor.constraint(equalTo: introVideoButton.centerYAnchor),
            shoppingBasketButton.widthAnchor.constraint(equalToConstant: 120),
            shoppingBasketButton.heightAnchor.constraint(equalToConstant: 30),
            
            reviewButton.centerYAnchor.constraint(equalTo: introVideoButton.centerYAnchor),
            reviewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            reviewButton.widthAnchor.constraint(equalToConstant: 120),
            reviewButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with lecture: Lecture) {
        titleLabel.text = "메시 선생님과 배우는 쿠킹클래스"
        priceLabel.text = "KRW 99,000"
        likesCountLabel.text = "5,602"
        descriptionLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore n. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt"
        // lectureImageView.image = UIImage(named: lecture.imageName)
    }
}
