import UIKit
import Combine
// import Kingfisher // 또는 SDWebImage 등 이미지 로딩 라이브러리를 사용한다면 import

class MyPageViewController: UIViewController {
    weak var coordinator: MyPageCoordinator?
    private let viewModel = MyPageViewModel() // ViewModel 인스턴스 생성
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(hex: "#E5E5E5") // 이미지 로드 전 배경색
        imageView.layer.cornerRadius = 30 // 너비/높이의 절반 (크기 60x60 가정)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true // 탭 제스처를 위해
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle.fill") // 초기 아이콘 설정
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Guest" // 초기값
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 15)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0 P" // 초기값
        return label
    }()
    
    private let settingButton: UIButton = { // 클래스 프로퍼티로 변경
        let button = UIButton(type: .system) // .system 타입으로 하면 기본 스타일 활용 용이
        button.setTitle("로그인하기", for: .normal) // ViewModel 바인딩 전 초기 타이틀
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14) // 폰트 일관성
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // 초기에는 숨김
        // 버튼에 테두리나 배경을 추가하여 더 잘 보이게 할 수 있습니다.
        // button.layer.borderColor = UIColor.lightGray.cgColor
        // button.layer.borderWidth = 1
        // button.layer.cornerRadius = 5
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // 배경색 설정
        
        setupSubviews() // UI 요소들을 뷰에 추가하고 제약조건 설정
        setupActions()  // 버튼 액션 및 제스처 설정
        bindViewModel() // ViewModel 바인딩
        
        // ViewModel의 init에서 fetchProfile이 호출되지만,
        // viewDidLoad 시점에도 명시적으로 호출하여 초기 데이터 로드를 보장할 수 있습니다.
        // 또는 viewWillAppear에서 호출하는 것으로 충분할 수 있습니다.
        // viewModel.fetchProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        let profileSection = setupProfileSectionView() // UIView 반환
        let menuSectionStackView = setupMenuSectionStackView() // UIStackView 반환
        
        view.addSubview(profileSection)
        view.addSubview(menuSectionStackView)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            profileSection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // profileSection.heightAnchor.constraint(equalToConstant: 100), // 내부 콘텐츠에 따라 높이 자동 조절되도록 변경 가능
            
            menuSectionStackView.topAnchor.constraint(equalTo: profileSection.bottomAnchor, constant: 24),
            menuSectionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuSectionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutButton.topAnchor.constraint(greaterThanOrEqualTo: menuSectionStackView.bottomAnchor, constant: 20), // 메뉴와 간격
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupActions() {
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileSectionTapped))
        profileImageView.addGestureRecognizer(profileTapGesture) // 이미지 뷰에 직접 제스처 추가
        // 또는 profileSection 전체에 탭 제스처를 추가할 수도 있습니다.
        
        settingButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if self.viewModel.isLoggedIn {
                self.coordinator?.showEditProfile()
            } else {
                self.coordinator?.showLogin()
            }
        }, for: .touchUpInside)
        
        logoutButton.addAction(UIAction {[weak self] _ in
            self?.viewModel.logout()
        }, for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.$profileName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nameValue in // map을 사용하지 않고 직접 sink에서 처리
                self?.nameLabel.text = nameValue // String을 String?에 할당하는 것은 문제 없음
            }
            .store(in: &cancellables)
        
        viewModel.$profilePoint
            .receive(on: DispatchQueue.main)
            .map { point -> String in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return "\(formatter.string(from: NSNumber(value: point)) ?? "\(point)") P"
            }
            .assign(to: \.text, on: pointLabel) // 간결한 바인딩
            .store(in: &cancellables)
        
        viewModel.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                self.settingButton.setTitle(isLoggedIn ? "편집하기" : "로그인하기", for: .normal)
                self.logoutButton.isHidden = !isLoggedIn
                if !isLoggedIn { // 로그아웃 시 UI 초기화
                    self.profileImageView.image = UIImage(systemName: "person.circle.fill")
                    // nameLabel, pointLabel은 ViewModel의 초기값으로 자동 설정됨
                }
            }
            .store(in: &cancellables)
        
        viewModel.$profileImageURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self = self else { return }
                self.loadImage(for: self.profileImageView, with: url)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Helper Methods
    private func setupProfileSectionView() -> UIView {
        let sectionView = UIView()
        sectionView.backgroundColor = UIColor(hex: "#F7F7F7") // 약간 다른 회색
        sectionView.layer.cornerRadius = 16
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        // 그림자 효과 추가 (선택 사항)
        sectionView.layer.shadowColor = UIColor.black.cgColor
        sectionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        sectionView.layer.shadowRadius = 3
        sectionView.layer.shadowOpacity = 0.05
        sectionView.layer.masksToBounds = false
        
        let verticalStack = UIStackView(arrangedSubviews: [nameLabel, pointLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 6
        verticalStack.alignment = .leading
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, verticalStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.addSubview(horizontalStack)
        sectionView.addSubview(settingButton)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            horizontalStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 20),
            horizontalStack.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 20),
            horizontalStack.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -20),
            horizontalStack.trailingAnchor.constraint(lessThanOrEqualTo: settingButton.leadingAnchor, constant: -16),
            
            settingButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -20),
            settingButton.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor),
            settingButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        return sectionView
    }
    
    private func setupMenuSectionStackView() -> UIStackView {
        let menuItems: [(title: String, iconName: String?, action: () -> Void)] = [
            ("출석 확인", "calendar.badge.clock", { [weak self] in self?.coordinator?.showMyAttendance() }),
            ("수강 기록", "list.star", { [weak self] in self?.coordinator?.showCourseHistory() }),
            ("설정", "gearshape.fill", { [weak self] in self?.coordinator?.showSetting() }),
            ("결제 내역", "creditcard.fill", { [weak self] in self?.coordinator?.showPaymentHistory() })
        ]
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 12
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        menuItems.forEach { item in
            var config = UIButton.Configuration.plain() // .plain으로 변경하여 배경 제거
            config.title = item.title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont(name: "Pretendard-Medium", size: 17)
                return outgoing
            }
            
            if let iconName = item.iconName {
                config.image = UIImage(systemName: iconName)
                config.imagePadding = 10
                config.imagePlacement = .leading
            }
            config.baseForegroundColor = UIColor(hex: "#333333")
            config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15) // 내부 여백
            
            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .leading // 텍스트와 아이콘 왼쪽 정렬
            button.backgroundColor = UIColor(hex: "#FFFFFF")
            button.layer.cornerRadius = 12
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.08
            button.layer.masksToBounds = false
            
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.addAction(UIAction { _ in item.action() }, for: .touchUpInside)
            verticalStack.addArrangedSubview(button)
        }
        return verticalStack
    }
    
    private func loadImage(for imageView: UIImageView, with url: URL?) {
        guard let url = url else {
            imageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        
        if let cachedImage = ImageCacheManager.shared.get(for: url.absoluteString) {
            imageView.image = cachedImage
            return
        }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("MyPageVC: Image download failed (URL: \(url.absoluteString)) with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    await MainActor.run { imageView.image = UIImage(systemName: "person.circle.fill") }
                    return
                }
                if let image = UIImage(data: data) {
                    ImageCacheManager.shared.set(image, for: url.absoluteString)
                    await MainActor.run { imageView.image = image }
                } else {
                    print("MyPageVC: Downloaded data could not be converted to UIImage (URL: \(url.absoluteString))")
                    await MainActor.run { imageView.image = UIImage(systemName: "person.circle.fill") }
                }
            } catch {
                print("MyPageVC: Error loading image from URL (URL: \(url.absoluteString)): \(error.localizedDescription)")
                await MainActor.run { imageView.image = UIImage(systemName: "person.circle.fill") }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func profileSectionTapped() { // 함수 이름 변경 및 private 처리
        if viewModel.isLoggedIn {
            coordinator?.showEditProfile()
        } else {
            coordinator?.showLogin()
        }
    }
}

// UIColor(hex:) 확장은 프로젝트 내 다른 곳에 정의되어 있다고 가정합니다.
// extension UIColor { ... }
