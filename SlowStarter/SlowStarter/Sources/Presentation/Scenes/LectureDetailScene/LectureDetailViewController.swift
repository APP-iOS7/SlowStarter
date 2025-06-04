//
//  LectureDetailViewController.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import UIKit

class LectureDetailViewController: UIViewController {
    
    weak var coordinator: LectureFlowCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let viewModel = LectureDetailViewModel()
    
    private let imageDescriptions = [
        "신선한 재료로 만드는 쿠키 반죽",
        "크랜베리를 올린 데니쉬 페이스트리",
        "갓 구운 부드러운 모닝빵",
        "초코칩이 가득한 쿠키",
        "바삭한 크로와상"
    ]
    
    private var slideImages: [UIImageView] = []
    
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
    
    private let slideImageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true // 스와이프 효과를 위한 페이징 활성화
        scrollView.showsHorizontalScrollIndicator = false // 가로 스크롤 인디케이터 숨기기
        return scrollView
    }()
    
    private let slideImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually // 이미지를 동일하게 분배
        return stackView
    }()
    
    private let slideImageView_1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bread01")
        return imageView
    }()
    
    private let slideImageView_2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bread02")
        return imageView
    }()
    
    private let slideImageView_3: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bread03")
        return imageView
    }()
    
    private let slideImageView_4: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bread01")
        return imageView
    }()
    
    private let slideImageView_5: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bread02")
        return imageView
    }()
    
    private var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "강의 설명"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
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
        button.setTitle("상담날짜 예약하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 20)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        //        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupSlideImages() {
        let images = ["bread01", "bread02", "bread03", "bread01", "bread02"]
        
        for (index, imageName) in images.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: imageName)
            imageView.isUserInteractionEnabled = true
            imageView.backgroundColor = .systemGray6  // 이미지가 로드되지 않았을 때 보여줄 배경색
            
            // 탭 제스처 추가
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            imageView.tag = index // 이미지 인덱스 저장
            
            slideImageScrollView.addSubview(imageView)
            slideImages.append(imageView)
            
            // 이미지 제약조건 설정
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: slideImageScrollView.topAnchor),
                imageView.heightAnchor.constraint(equalTo: slideImageScrollView.heightAnchor),
                imageView.widthAnchor.constraint(equalTo: slideImageScrollView.widthAnchor, multiplier: 0.8),
                imageView.bottomAnchor.constraint(equalTo: slideImageScrollView.bottomAnchor)
            ])
            
            // 첫 번째 이미지
            if index == 0 {
                imageView.leadingAnchor.constraint(equalTo: slideImageScrollView.leadingAnchor).isActive = true
            }
            // 중간 이미지들
            else {
                imageView.leadingAnchor.constraint(equalTo: slideImages[index - 1].trailingAnchor, constant: 10).isActive = true
            }
            // 마지막 이미지
            if index == images.count - 1 {
                imageView.trailingAnchor.constraint(equalTo: slideImageScrollView.trailingAnchor).isActive = true
            }
        }
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        let index = imageView.tag
        let description = imageDescriptions[index]
        
        let detailVC = ImageDetailViewController(image: imageView.image, description: description)
        present(detailVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
        setupSlideImages()
        
        // 버튼 액션 추가
        selectDateButton.addTarget(self, action: #selector(selectDateButtonTapped), for: .touchUpInside)
        
        // 내비게이션 바 표시 및 뒤로가기 버튼 활성화 (기본값)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        view.addSubview(descriptionScrollView)
        descriptionScrollView.addSubview(introVideoView)
        descriptionScrollView.addSubview(titleLabel)
        descriptionScrollView.addSubview(priceLabel)
        
        descriptionScrollView.addSubview(slideImageScrollView)
        slideImageScrollView.addSubview(slideImageStackView)
        slideImageStackView.addArrangedSubview(slideImageView_1)
        slideImageStackView.addArrangedSubview(slideImageView_2)
        slideImageStackView.addArrangedSubview(slideImageView_3)
        slideImageStackView.addArrangedSubview(slideImageView_4)
        slideImageStackView.addArrangedSubview(slideImageView_5)
        
        descriptionScrollView.addSubview(descriptionTitleLabel)
        descriptionScrollView.addSubview(descriptionLabel)
        
        view.addSubview(selectDateButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            descriptionScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            descriptionScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionScrollView.bottomAnchor.constraint(equalTo: selectDateButton.topAnchor),
            descriptionScrollView.widthAnchor.constraint(equalTo: view.widthAnchor), // contentLayoutGuide를 위해 필수
            
            introVideoView.topAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.topAnchor),
            introVideoView.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor),
            introVideoView.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor),
            introVideoView.heightAnchor.constraint(equalToConstant: 400),
            
            titleLabel.topAnchor.constraint(equalTo: introVideoView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            
            slideImageScrollView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            slideImageScrollView.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor),
            slideImageScrollView.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor),
            slideImageScrollView.heightAnchor.constraint(equalToConstant: 200),
            slideImageScrollView.widthAnchor.constraint(equalTo: descriptionScrollView.widthAnchor),

            // 슬라이드 이미지 스크롤 뷰 내부의 스택 뷰를 위한 제약 조건
            slideImageStackView.topAnchor.constraint(equalTo: slideImageScrollView.contentLayoutGuide.topAnchor),
            slideImageStackView.leadingAnchor.constraint(equalTo: slideImageScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            slideImageStackView.trailingAnchor.constraint(equalTo: slideImageScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            slideImageStackView.heightAnchor.constraint(equalTo: slideImageScrollView.heightAnchor), // 스크롤 뷰의 높이와 일치
            
            // 스택 뷰 내부의 각 이미지에 대한 제약 조건
            // 페이징을 위해 각 이미지의 너비를 메인 뷰의 너비에서 패딩을 뺀 값으로 설정
            slideImageView_1.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -260), // 20pt leading/trailing 패딩을 위해 -40
            slideImageView_2.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -260),
            slideImageView_3.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -260),
            slideImageView_4.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -260),
            slideImageView_5.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -260),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: slideImageStackView.bottomAnchor, constant: 30),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            descriptionLabel.widthAnchor.constraint(equalTo: descriptionScrollView.frameLayoutGuide.widthAnchor, constant: -40),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            selectDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            selectDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            selectDateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            selectDateButton.heightAnchor.constraint(equalToConstant: 50)
                    ])
    }
    
    // 코디네이터에게 화면 전환 요청
    @objc private func selectDateButtonTapped() {
        coordinator?.showLectureDateSelection()
    }
}

#Preview {
    LectureDetailViewController()
}
