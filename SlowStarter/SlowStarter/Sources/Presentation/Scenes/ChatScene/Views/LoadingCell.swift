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
        view.backgroundColor = .systemGray6
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
    private func setupUI() {
        contentView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            animationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            animationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            animationView.widthAnchor.constraint(equalToConstant: 70),
            animationView.heightAnchor.constraint(equalToConstant: 40)
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
