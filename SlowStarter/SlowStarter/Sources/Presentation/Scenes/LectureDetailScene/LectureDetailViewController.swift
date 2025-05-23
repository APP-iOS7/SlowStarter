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
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let introVideoView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var curriculumShow: UILabel = {
        let label = UILabel()
        label.text = viewModel.curriculumShow
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "profile_placeholder")
        imageView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return imageView
    }()
    
    lazy private var instructorNameLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.name
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var instructorJobLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.job
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
        button.titleLabel?.font = UIFont(name: "Pretendard-Black", size: 24)
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
        
        // 이미지 로드 호출
        loadImage(from: viewModel.profileImageURL, into: profileImageView)
        
        // 버튼 액션 추가
        selectDateButton.addTarget(self, action: #selector(selectDateButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(introVideoView)
        view.addSubview(curriculumShow)
        view.addSubview(profileImageView)
        view.addSubview(instructorNameLabel)
        view.addSubview(instructorJobLabel)
        view.addSubview(descriptionScrollView)
        descriptionScrollView.addSubview(descriptionLabel)
        view.addSubview(selectDateButton)
        view.addSubview(tabBar)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            introVideoView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            introVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            introVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            introVideoView.heightAnchor.constraint(equalToConstant: 100),
            
            curriculumShow.topAnchor.constraint(equalTo: introVideoView.bottomAnchor, constant: 30),
            curriculumShow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: introVideoView.bottomAnchor, constant: 15),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 200),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            instructorNameLabel.topAnchor.constraint(equalTo: introVideoView.bottomAnchor, constant: 20),
            instructorNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 280),
            
            instructorJobLabel.topAnchor.constraint(equalTo: instructorNameLabel.bottomAnchor, constant: 0),
            instructorJobLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 280),
            
            descriptionScrollView.topAnchor.constraint(equalTo: instructorJobLabel.bottomAnchor, constant: 20),
            descriptionScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionScrollView.heightAnchor.constraint(equalToConstant: 280),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            descriptionLabel.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -40),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            selectDateButton.topAnchor.constraint(equalTo: descriptionScrollView.bottomAnchor, constant: 10),
            selectDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            selectDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            selectDateButton.heightAnchor.constraint(equalToConstant: 60),
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 여기서 cornerRadius 설정을 해주면, 프레임이 완전히 설정된 후에 적용됩니다.
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    // LectureDetailViewController.swift 파일에 추가
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
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
