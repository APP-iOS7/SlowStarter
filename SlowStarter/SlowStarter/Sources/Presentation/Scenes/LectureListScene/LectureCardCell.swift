//
//  LectureCardCellTableViewCell.swift
//  SlowStarter
//
//  Created by sean on 5/26/25.
//

import UIKit
import Kingfisher

protocol LectureCardCellDelegate: AnyObject {
    func didTapShowDetail(in cell: LectureCardCell)
}

class LectureCardCell: UITableViewCell {
    static let identifier = "LectureCardCell"
    weak var delegate: LectureCardCellDelegate?
    
    var detail: LectureDetail? {
        didSet {
            configure()
        }
    }
    
    private let lectureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true  // 이미지뷰 터치 활성화
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
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
        contentView.addSubview(detailShowButton)
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
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            detailShowButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
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
    
    func configure() {
        guard let detail = detail else { return }
        
        titleLabel.text = detail.lecture.title
        
        if let price = detail.lecture.price {
            priceLabel.text = price.description + "원"
        }
        
        if let image = detail.lecture_intro_images?.first,
           let imageURL = image.imageURL {
            lectureImageView.kf.setImage(with: URL(string: imageURL))
        }
    }
    
    @objc private func showDetailTapped() {
        delegate?.didTapShowDetail(in: self)
    }
}
