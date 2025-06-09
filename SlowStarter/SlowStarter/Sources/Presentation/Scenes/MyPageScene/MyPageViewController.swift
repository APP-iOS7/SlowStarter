import UIKit
import Combine

class MyPageViewController: UIViewController {
    weak var coordinator: MyPageCoordinator?
    private let viewModel = MyPageViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(hex: "#FFFFFF")
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = UIColor(hex: "#FEDBD0")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-SemiBold", size: 17)
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Guest"
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 15)
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0 P"
        return label
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인하기", for: .normal)
        button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        button.contentHorizontalAlignment = .trailing
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubviews()
        setupActions()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupSubviews() {
        let profileSection = setupProfileSectionView()
        let menuSectionStackView = setupMenuSectionStackView()
        
        view.addSubview(profileSection)
        view.addSubview(menuSectionStackView)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            profileSection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            menuSectionStackView.topAnchor.constraint(equalTo: profileSection.bottomAnchor, constant: 30),
            menuSectionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuSectionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutButton.topAnchor.constraint(greaterThanOrEqualTo: menuSectionStackView.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupActions() {
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileSectionTapped))
        profileImageView.addGestureRecognizer(profileTapGesture)
        
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
    
    private func bindViewModel() {
        viewModel.$profileName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nameValue in
                self?.nameLabel.text = nameValue
            }
            .store(in: &cancellables)
        
        viewModel.$profilePoint
            .receive(on: DispatchQueue.main)
            .map { point -> String in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return "\(formatter.string(from: NSNumber(value: point)) ?? "\(point)") P"
            }
            .assign(to: \.text, on: pointLabel)
            .store(in: &cancellables)
        
        viewModel.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                self.settingButton.setTitle(isLoggedIn ? "편집하기" : "로그인하기", for: .normal)
                self.logoutButton.isHidden = !isLoggedIn
                if !isLoggedIn {
                    self.profileImageView.image = UIImage(systemName: "person.circle.fill")
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
    
    private func setupProfileSectionView() -> UIView {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
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
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            horizontalStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            horizontalStack.topAnchor.constraint(equalTo: sectionView.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor),
            horizontalStack.trailingAnchor.constraint(lessThanOrEqualTo: settingButton.leadingAnchor, constant: -16),
            
            settingButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
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
        verticalStack.spacing = 10
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        menuItems.forEach { item in
            var config = UIButton.Configuration.plain()
            config.title = item.title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont(name: "Pretendard-Medium", size: 17)
                outgoing.foregroundColor = UIColor(hex: "#442C2E")
                return outgoing
            }
            
            if let iconName = item.iconName {
                config.image = UIImage(systemName: iconName)
                config.imagePadding = 10
                config.imagePlacement = .leading
            }
            config.baseForegroundColor = UIColor(hex: "#442C2E")
            config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 15)
            
            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .leading
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
            imageView.image = UIImage(systemName: "person.circle")
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
                    await MainActor.run { imageView.image = UIImage(systemName: "person.circle") }
                    return
                }
                if let image = UIImage(data: data) {
                    ImageCacheManager.shared.set(image, for: url.absoluteString)
                    await MainActor.run { imageView.image = image }
                } else {
                    await MainActor.run { imageView.image = UIImage(systemName: "person.circle") }
                }
            } catch {
                await MainActor.run { imageView.image = UIImage(systemName: "person.circle") }
            }
        }
    }
    
    @objc private func profileSectionTapped() {
        if viewModel.isLoggedIn {
            coordinator?.showEditProfile()
        } else {
            coordinator?.showLogin()
        }
    }
}

#Preview {
    MyPageViewController()
}
