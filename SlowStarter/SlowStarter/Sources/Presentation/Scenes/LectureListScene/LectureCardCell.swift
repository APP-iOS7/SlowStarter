//
//  LectureCardCellTableViewCell.swift
//  SlowStarter
//
//  Created by sean on 5/26/25.
//

import UIKit

protocol LectureCardCellDelegate: AnyObject {
    func didTapThumb(in cell: LectureCardCell)
    func didTapReadMoreButton(in cell: LectureCardCell)
    func didTapShowDetail(in cell: LectureCardCell)
}

class LectureCardCell: UITableViewCell {
    
    static let identifier = "LectureCardCell"
    
    weak var delegate: LectureCardCellDelegate?
    
    private var lecture: Lecture?
    
    private let lectureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cookingClassWomanChef")
        imageView.isUserInteractionEnabled = true  // 이미지뷰 터치 활성화
        return imageView
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
        label.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        //        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let thumbIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hand.thumbsup")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let thumbCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 18)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .systemGray
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자세히보기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.tintColor = .systemGray
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let detailShowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("강의 상세보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 20)
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
        setupActions()
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(lectureImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(thumbContainer)
        contentView.addSubview(thumbIcon)
        contentView.addSubview(thumbCountLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(readMoreButton)
        contentView.addSubview(detailShowButton)
        
        // Add tap gesture to thumbContainer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbTapped))
        thumbContainer.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lectureImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            lectureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            lectureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            lectureImageView.heightAnchor.constraint(equalToConstant: 340),
            
            titleLabel.topAnchor.constraint(equalTo: lectureImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: thumbContainer.leadingAnchor, constant: -10),
            
            thumbContainer.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            thumbContainer.trailingAnchor.constraint(equalTo: thumbCountLabel.leadingAnchor),
            thumbContainer.widthAnchor.constraint(equalToConstant: 30),
            thumbContainer.heightAnchor.constraint(equalToConstant: 30),
            
            thumbIcon.centerXAnchor.constraint(equalTo: thumbContainer.centerXAnchor),
            thumbIcon.centerYAnchor.constraint(equalTo: thumbContainer.centerYAnchor),
            thumbIcon.widthAnchor.constraint(equalToConstant: 20),
            thumbIcon.heightAnchor.constraint(equalToConstant: 20),
            
            thumbCountLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            thumbCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            thumbCountLabel.widthAnchor.constraint(equalToConstant: 60),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            readMoreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            readMoreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            readMoreButton.heightAnchor.constraint(equalToConstant: 20),
            
            detailShowButton.topAnchor.constraint(equalTo: readMoreButton.bottomAnchor, constant: 16),
            detailShowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            detailShowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            detailShowButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            detailShowButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupActions() {
        // 이미지뷰 탭 제스처 추가
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showDetailTapped))
        lectureImageView.addGestureRecognizer(imageTapGesture)
        
        // 버튼 액션 추가
        readMoreButton.addTarget(self, action: #selector(readMoreButtonTapped), for: .touchUpInside)
        detailShowButton.addTarget(self, action: #selector(showDetailTapped), for: .touchUpInside)
    }
    
    func configure(with lecture: Lecture, isExpanded: Bool) {
        self.lecture = lecture
        titleLabel.text = lecture.title
        priceLabel.text = "KRW 99,000"
        thumbCountLabel.text = String(format: "\(lecture.thumbCount)")
        descriptionLabel.text = lecture.description
        
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
        let buttonTitle = isExpanded ? "간략히보기" : "자세히보기"
        readMoreButton.setTitle(buttonTitle, for: .normal)
        
        contentView.layoutIfNeeded()
    }
    
    @objc private func readMoreButtonTapped() {
        delegate?.didTapReadMoreButton(in: self)
    }
    
    @objc private func showDetailTapped() {
        delegate?.didTapShowDetail(in: self)
    }
    
    @objc private func thumbTapped() {
        delegate?.didTapThumb(in: self)
    }
}
