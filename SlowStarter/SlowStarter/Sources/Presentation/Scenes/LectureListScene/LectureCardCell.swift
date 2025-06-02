//
//  LectureCardCellTableViewCell.swift
//  SlowStarter
//
//  Created by sean on 5/26/25.
//

import UIKit

protocol LectureCardCellDelegate: AnyObject {
    func didTapReadMoreButton(in cell: LectureCardCell)
}

class LectureCardCell: UITableViewCell {
    
    static let identifier = "LectureCardCell"
    
    weak var delegate: LectureCardCellDelegate?
    private var isDescriptionExpanded: Bool = false
    
    private let lectureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cookingClassWomanChef")
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
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .systemGray
        label.numberOfLines = 3 // 라인수 제한
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let readMoreButton: UIButton = { // New: Read More Button
        let button = UIButton(type: .system)
        button.setTitle("자세히보기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.tintColor = .systemPink
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
        contentView.backgroundColor = .systemBackground // 셀 자체의 배경색
        
        readMoreButton.addTarget(self, action: #selector(readMoreButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(lectureImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(likesIcon)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(readMoreButton)
        contentView.addSubview(detailShowButton)
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
            priceLabel.trailingAnchor.constraint(equalTo: likesIcon.leadingAnchor, constant: -10),
            
            likesIcon.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            likesIcon.trailingAnchor.constraint(equalTo: likesCountLabel.leadingAnchor),
            likesIcon.widthAnchor.constraint(equalToConstant: 20),
            likesIcon.heightAnchor.constraint(equalToConstant: 20),
            
            likesCountLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            likesCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            likesCountLabel.widthAnchor.constraint(equalToConstant: 60),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            readMoreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            readMoreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            readMoreButton.heightAnchor.constraint(equalToConstant: 20),
            
            detailShowButton.topAnchor.constraint(equalTo: readMoreButton.bottomAnchor, constant: 10),
            detailShowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            detailShowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            detailShowButton.heightAnchor.constraint(equalToConstant: 40),
//            detailShowButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with lecture: Lecture, isExpanded: Bool) {
        self.isDescriptionExpanded = isExpanded
        
        titleLabel.text = "메시 선생님과 배우는 쿠킹클래스"
        priceLabel.text = "KRW 99,000"
        likesCountLabel.text = "5,602"
        descriptionLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt eget nullam non. Quis hendrerit dolor magna eget est lorem ipsum dolor sit. Volutpat odio facilisis mauris sit amet massa. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Mi eget mauris pharetra et. Non tellus orci ac auctor augue. Elit at imperdiet dui accumsan sit. Ornare arcu dui vivamus arcu felis. Egestas integer eget aliquet nibh praesent. In hac habitasse platea dictumst quisque sagittis purus. Pulvinar elementum integer enim neque volutpat ac. Senectus et netus et malesuada. Nunc pulvinar sapien et ligula ullamcorper malesuada proin. Neque convallis a cras semper auctor. Libero id faucibus nisl tincidunt eget. Leo a diam sollicitudin tempor id. A lacus vestibulum sed arcu non odio euismod lacinia. In tellus integer feugiat scelerisque."
        
        descriptionLabel.numberOfLines = isDescriptionExpanded ? 0 : 3
        readMoreButton.setTitle(isDescriptionExpanded ? "간략히보기" : "자세히보기", for: .normal)
        // lectureImageView.image = UIImage(named: lecture.imageName)
    }
    
    @objc private func readMoreButtonTapped() {
//        isDescriptionExpanded.toggle()
        delegate?.didTapReadMoreButton(in: self)
    }
}
