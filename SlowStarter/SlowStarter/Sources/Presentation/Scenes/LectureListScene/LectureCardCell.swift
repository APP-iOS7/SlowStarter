//
//  LectureCardCellTableViewCell.swift
//  SlowStarter
//
//  Created by sean on 5/26/25.
//

import UIKit

protocol LectureCardCellDelegate: AnyObject {
    func didTapThumb(in cell: LectureCardCell)
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
        label.font = .systemFont(ofSize: 18)
        //        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        //        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor(red: 1.0, green: 0.86, blue: 0.82, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let thumbIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hand.thumbsup")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let thumbCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailShowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("강의 상세보기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 1.0, green: 0.86, blue: 0.82, alpha: 1.0)
        button.layer.cornerRadius = 10
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
        contentView.addSubview(detailShowButton)
        thumbContainer.addSubview(thumbIcon)
        thumbContainer.addSubview(thumbCountLabel)
        
        // Add tap gesture to thumbContainer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbTapped))
        thumbContainer.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lectureImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            lectureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lectureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lectureImageView.heightAnchor.constraint(equalToConstant: 340),
            
            titleLabel.topAnchor.constraint(equalTo: lectureImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: thumbContainer.leadingAnchor, constant: -20),
            
            thumbContainer.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            thumbContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            thumbIcon.topAnchor.constraint(equalTo: thumbContainer.topAnchor, constant: 7),
            thumbIcon.leadingAnchor.constraint(equalTo: thumbContainer.leadingAnchor, constant: 10),
            thumbIcon.bottomAnchor.constraint(equalTo: thumbContainer.bottomAnchor, constant: -7),
            thumbIcon.widthAnchor.constraint(equalToConstant: 20),
            thumbIcon.heightAnchor.constraint(equalTo: thumbIcon.widthAnchor),
            
            thumbCountLabel.centerYAnchor.constraint(equalTo: thumbContainer.centerYAnchor),
            thumbCountLabel.leadingAnchor.constraint(equalTo: thumbIcon.trailingAnchor, constant: 5),
            thumbCountLabel.trailingAnchor.constraint(equalTo: thumbContainer.trailingAnchor, constant: -10),
            
            detailShowButton.topAnchor.constraint(equalTo: thumbContainer.bottomAnchor, constant: 10),
            detailShowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailShowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailShowButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            detailShowButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupActions() {
        // 이미지뷰 탭 제스처 추가
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showDetailTapped))
        lectureImageView.addGestureRecognizer(imageTapGesture)
        
        // 버튼 액션 추가
        detailShowButton.addTarget(self, action: #selector(showDetailTapped), for: .touchUpInside)
    }
    
    func configure(with lecture: Lecture, isExpanded: Bool) {
        self.lecture = lecture
        titleLabel.text = lecture.title
        priceLabel.text = "KRW 99,000"
    }
    
    @objc private func showDetailTapped() {
        delegate?.didTapShowDetail(in: self)
    }
    
    @objc private func thumbTapped() {
        delegate?.didTapThumb(in: self)
    }
}
