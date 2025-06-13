import UIKit
import Kingfisher

class LectureDetailViewController: UIViewController {
    
    weak var coordinator: LectureCoordinator?
    private var videoPlayerVC: VideoPlayerViewController?
    private var slideImages: [UIImageView] = []
    private var isExpanded = false
    
    private var lectureDetail: LectureDetail
    
    init(_ lectureDetail: LectureDetail) {
        self.lectureDetail = lectureDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private let descriptionScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private let titleCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#FEEAE6")
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let classTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let classSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let slideImageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let slideImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "강의 설명"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14)
        button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let selectDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상담날짜 예약하기", for: .normal)
        button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 20)
        button.backgroundColor = UIColor(hex: "#FEDBD0")
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor(hex: "#442C2E")
        
        setupUI()
        setupConstraints()
        setupVideoPlayer()
        setupSlideImages()
        bindData()
        setupAction()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(descriptionScrollView)
        descriptionScrollView.addSubview(contentView)
        
        contentView.addSubview(videoContainerView)
        contentView.addSubview(titleCardView)
        titleCardView.addSubview(classTitleLabel)
        titleCardView.addSubview(classSubtitleLabel)
        
        contentView.addSubview(slideImageScrollView)
        slideImageScrollView.addSubview(slideImageStackView)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(selectDateButton)
    }
    
    private func setupVideoPlayer() {
        let videoViewController = VideoPlayerViewController()
        videoPlayerVC = videoViewController
        addChild(videoViewController)
        videoContainerView.addSubview(videoViewController.view)
        videoViewController.didMove(toParent: self)
        videoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            videoViewController.view.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            videoViewController.view.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            videoViewController.view.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            videoViewController.view.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        ])
        
    }
    
    private func setupSlideImages() {
        guard let images = lectureDetail.lecture_intro_images else { return }
        
        for (index, imageData) in images.enumerated() {
            guard let urlString = imageData.imageURL, let url = URL(string: urlString) else { continue }
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            slideImages.append(imageView)
            slideImageStackView.addArrangedSubview(imageView)
            
            imageView.kf.setImage(with: url)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    private func setupAction() {
        moreButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.isExpanded.toggle()
            self.descriptionLabel.numberOfLines = self.isExpanded ? 0 : 3
            self.moreButton.setTitle(self.isExpanded ? "간략히" : "더보기", for: .normal)
        }, for: .touchUpInside)
        
        selectDateButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
                Task {
                    if SupabaseDataManager.shared.getCurrentAuthenticatedUser() == nil {
                        await MainActor.run {
                            self.coordinator?.showLoginInLecture({
                                self.coordinator?.showLectureDateSelection()
                            })
                        }
                    } else {
                        self.coordinator?.showLectureDateSelection()
                    }
                }
        }, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            descriptionScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            descriptionScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: descriptionScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: descriptionScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: descriptionScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: descriptionScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: descriptionScrollView.widthAnchor),
            
            videoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            titleCardView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            titleCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleCardView.heightAnchor.constraint(equalToConstant: 80),
            
            classTitleLabel.topAnchor.constraint(equalTo: titleCardView.topAnchor, constant: 12),
            classTitleLabel.leadingAnchor.constraint(equalTo: titleCardView.leadingAnchor, constant: 16),
            classTitleLabel.trailingAnchor.constraint(equalTo: titleCardView.trailingAnchor, constant: -16),
            
            classSubtitleLabel.topAnchor.constraint(equalTo: classTitleLabel.bottomAnchor, constant: 4),
            classSubtitleLabel.leadingAnchor.constraint(equalTo: titleCardView.leadingAnchor, constant: 16),
            classSubtitleLabel.trailingAnchor.constraint(equalTo: titleCardView.trailingAnchor, constant: -16),
            
            slideImageScrollView.topAnchor.constraint(equalTo: titleCardView.bottomAnchor, constant: 16),
            slideImageScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            slideImageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            slideImageScrollView.heightAnchor.constraint(equalToConstant: 160),
            
            slideImageStackView.topAnchor.constraint(equalTo: slideImageScrollView.topAnchor),
            slideImageStackView.leadingAnchor.constraint(equalTo: slideImageScrollView.leadingAnchor, constant: 16),
            slideImageStackView.trailingAnchor.constraint(equalTo: slideImageScrollView.trailingAnchor, constant: -16),
            slideImageStackView.heightAnchor.constraint(equalTo: slideImageScrollView.heightAnchor),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: slideImageScrollView.bottomAnchor, constant: 30),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            moreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            selectDateButton.topAnchor.constraint(equalTo: moreButton.bottomAnchor, constant: 30),
            selectDateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            selectDateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectDateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            selectDateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindData() {
        classTitleLabel.text = lectureDetail.lecture.title
        classSubtitleLabel.text = lectureDetail.lecture.subtitle
        descriptionLabel.text = lectureDetail.lecture.description
        
        if let videoURLString = lectureDetail.lecture_intro_video?.videoURL,
           let url = URL(string: videoURLString) {
            videoPlayerVC?.updateVideo(with: url)
        }
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        let detailVC = ImageDetailViewController(image: imageView.image)
        present(detailVC, animated: true)
    }
}
