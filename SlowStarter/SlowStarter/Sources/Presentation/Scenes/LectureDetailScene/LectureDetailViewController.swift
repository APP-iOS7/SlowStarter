//
//  LectureDetailViewController.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import UIKit

class LectureDetailViewController: UIViewController {
    
    weak var coordinator: LectureCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let viewModel = LectureDetailViewModel()
    
    // MARK: - UI Components
    private let descriptionScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let introVideoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cookingClassWomanChef")
        return imageView
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    lazy private var priceLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.price
        label.font = UIFont(name: "Pretendard-Regular", size: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var slideImageView_1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bread01")
        imageView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return imageView
    }()
    
    private var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "강의 설명"
        label.font = UIFont(name: "Pretendard-Regular", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.description
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수강날짜 선택하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 20)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        //        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        tabBar.delegate = self
        setupTabBarItems()
        
        // 버튼 액션 추가
        selectDateButton.addTarget(self, action: #selector(selectDateButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(descriptionScrollView)
        descriptionScrollView.addSubview(introVideoView)
        descriptionScrollView.addSubview(titleLabel)
        descriptionScrollView.addSubview(priceLabel)
        descriptionScrollView.addSubview(slideImageView_1)
        descriptionScrollView.addSubview(descriptionTitleLabel)
        descriptionScrollView.addSubview(descriptionLabel)
        view.addSubview(selectDateButton)
        view.addSubview(tabBar)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            descriptionScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            descriptionScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionScrollView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            introVideoView.topAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.topAnchor),
            introVideoView.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor),
            introVideoView.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor),
            introVideoView.heightAnchor.constraint(equalToConstant: 400),
            
            titleLabel.topAnchor.constraint(equalTo: introVideoView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
                        
            slideImageView_1.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 30),
            slideImageView_1.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            slideImageView_1.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: slideImageView_1.bottomAnchor, constant: 20),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            descriptionLabel.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -40),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            selectDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            selectDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            selectDateButton.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -5),
            selectDateButton.heightAnchor.constraint(equalToConstant: 50),
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupTabBarItems() {
        var items: [UITabBarItem] = []
        for (index, tabData) in viewModel.tabTitles.enumerated() {
            let image = UIImage(systemName: tabData.tabIcon)
            let item = UITabBarItem(title: tabData.title, image: image, tag: index)
            items.append(item)
        }
        tabBar.setItems(items, animated: false)
    }
    
    // 코디네이터에게 화면 전환 요청
    @objc private func selectDateButtonTapped() {
        coordinator?.showLectureDateSelection()
    }
}

// MARK: - UITabBarDelegate
extension LectureDetailViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let title = item.title else {
            return print("Selected tab: No title")
        }
        print("Selected tab: \(title)")
    }
}

#Preview {
    LectureDetailViewController()
}
