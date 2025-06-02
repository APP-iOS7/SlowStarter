import UIKit
import Combine

class MyPageViewController: UIViewController {
    weak var coordinator: MyPageCoordinator?
    private let viewModel = MyPageViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let nameLabel = UILabel()
    private let pointLabel = UILabel()
    private let settingButton = UIButton()
    private let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        let profileSection = setupProfileSection()
        profileSection.translatesAutoresizingMaskIntoConstraints = false
        
        let menuSection = setupMenuSection()
        menuSection.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.systemGray, for: .normal)
        logoutButton.titleLabel?.font = UIFont(name: "Pretendard-Thin", size: 8)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.isHidden = true
        
        logoutButton.addAction(UIAction {[weak self] _ in
            Task {
//                try await SupabaseDataManager.shared.deleteAccount()
                guard let self = self else { return }
                self.viewModel.logout()
                
            }
        }, for: .touchUpInside)
        
        view.addSubview(profileSection)
        view.addSubview(menuSection)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            profileSection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileSection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            profileSection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            profileSection.heightAnchor.constraint(equalToConstant: 100),
            
            menuSection.topAnchor.constraint(equalTo: profileSection.bottomAnchor, constant: 20),
            menuSection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            menuSection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 100),
            logoutButton.heightAnchor.constraint(equalToConstant: 20),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func bindViewModel() {
        viewModel.$profileName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameLabel.text = name
            }
            .store(in: &cancellables)
        
        viewModel.$profilePoint
            .receive(on: DispatchQueue.main)
            .sink { [weak self] point in
                self?.pointLabel.text = "\(point)P"
            }
            .store(in: &cancellables)
        
        viewModel.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                let title = isLoggedIn ? "편집하기" : "로그인하기"
                self.settingButton.setTitle(title, for: .normal)
                self.logoutButton.isHidden = !isLoggedIn
            }
            .store(in: &cancellables)
    }
    
    func setupProfileSection() -> UIView {
        let sectionView = UIView()
        sectionView.backgroundColor = UIColor(hex: "#F5F5F5")
        sectionView.layer.cornerRadius = 8
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = UIColor(hex: "#E5E5E5")
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pointLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        pointLabel.textColor = UIColor(hex: "#999999")
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        
        settingButton.setTitle("로그인하기", for: .normal)
        settingButton.setTitleColor(UIColor(hex: "#999999"), for: .normal)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        settingButton.addAction(UIAction { [weak self] _ in
            if self?.viewModel.isLoggedIn == true {
                // 편집하기 동작
                print("편집하기 화면 이동")
                // self?.coordinator?.showEditProfile()
            } else {
                self?.coordinator?.showLogin()
            }
        }, for: .touchUpInside)
        
        let verticalStack = UIStackView(arrangedSubviews: [nameLabel, pointLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, verticalStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.addSubview(horizontalStack)
        sectionView.addSubview(settingButton)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            horizontalStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 10),
            horizontalStack.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor),
            
            settingButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -10),
            settingButton.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor)
        ])
        
        return sectionView
    }
    
    func setupMenuSection() -> UIStackView {
        let menuItems: [String] = ["출석 확인", "수강 기록", "설정", "결제 내역"]
        let coordinatorFunctions: [() -> Void] = [
            { [weak self] in self?.coordinator?.showMyAttendance() },
            { [weak self] in self?.coordinator?.showCourseHistory() },
            { [weak self] in self?.coordinator?.showSetting() },
            { [weak self] in self?.coordinator?.showPaymentHistory() }
        ]
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 16
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        for index in menuItems.indices {
            var config = UIButton.Configuration.filled()
            config.title = menuItems[index]
            config.baseBackgroundColor = UIColor(hex: "#F0F0F0")
            config.baseForegroundColor = UIColor(hex: "#333333")
            config.cornerStyle = .medium
            
            let button = UIButton(configuration: config)
            button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            button.addAction(UIAction { _ in
                coordinatorFunctions[index]()
            }, for: .touchUpInside)
            
            verticalStack.addArrangedSubview(button)
        }
        
        return verticalStack
    }
}
