//
//  LoadingCell.swift
//  SlowStarter
//
//  Created by 멘태 on 5/23/25.
//

import UIKit
import Lottie

final class LoadingCell: UICollectionViewCell {
    // MARK: - Properties
    private lazy var animationView: LottieAnimationView = {
        let view: LottieAnimationView = LottieAnimationView(name: "typing")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - functions
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
    
    private func setupUI() {
        contentView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            animationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            animationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            animationView.widthAnchor.constraint(equalToConstant: 70),
            animationView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 8
    }
    
    func configure() {
        animationView.play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animationView.stop()
    }
}
