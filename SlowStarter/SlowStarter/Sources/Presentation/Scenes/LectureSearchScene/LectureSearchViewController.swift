//
//  LectureListViewController.swift
//  SlowStarter
//
//  Created by 고요한 on 5/9/25.
//

import UIKit

// 앱의 첫번째 화면
// 강의 목록 뷰 (강의목록 탭의 첫번째 화면)
class LectureSearchViewController: UIViewController {
    
    // UI 요소들
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray4 // 스켈레톤 보일 때 배경색
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // SkeletonView 사용 시
        // imageView.isSkeletonable = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray4
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        // SkeletonView 사용 시
        // label.isSkeletonable = true
        // label.skeletonTextLineHeight = .fixed(20) // 스켈레톤 높이 조절
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray4
        label.numberOfLines = 3
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        // SkeletonView 사용 시
        // label.isSkeletonable = true
        // label.skeletonTextLineHeight = .fixed(16) // 스켈레톤 높이 조절
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        // 데이터를 로드하는 함수 호출 (실제로는 네트워크 요청 등)
//        loadDataWithSkeleton()
    }
    
    func setupUI() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameLabel.heightAnchor.constraint(equalToConstant: 20), // 높이 고정 또는 내용에 따라
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20) // 아래로 너무 길어지지 않게
        ])
    }
    
    // 데이터 로딩 시뮬레이션 함수 (공통)
    func simulateDataLoading(completion: @escaping () -> Void) {
        // 2-3초 후 완료된 것처럼 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completion()
        }
    }
    
    // 실제 데이터로 UI 업데이트 (공통)
    func populateData() {
        avatarImageView.backgroundColor = .clear // 스켈레톤 배경색 제거
        avatarImageView.image = UIImage(systemName: "person.circle.fill") // 실제 이미지
        
        nameLabel.backgroundColor = .clear
        nameLabel.text = "홍길동"
        
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.text = "안녕하세요!"
    }
}
