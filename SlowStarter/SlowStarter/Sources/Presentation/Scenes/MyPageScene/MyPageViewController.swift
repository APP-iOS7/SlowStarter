import UIKit

class MyPageViewController: UIViewController {
    weak var coordinator: MyPageCoordinator?
    let profileImageSize: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI() {
        let profileSection = setupProfileSection()
        profileSection.translatesAutoresizingMaskIntoConstraints = false
        
        let menuSection = setupMenuSection()
        menuSection.translatesAutoresizingMaskIntoConstraints = false
        
        let logoutButton = UIButton()
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.systemGray, for: .normal)
        logoutButton.titleLabel?.font = UIFont(name: "Pretendard-Thin", size: 8)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    func setupProfileSection() -> UIView {
        let sectionView = UIView()
        sectionView.backgroundColor = UIColor(hex: "#F5F5F5")
        sectionView.layer.cornerRadius = 8
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = UIColor(hex: "#E5E5E5")
        profileImageView.layer.cornerRadius = profileImageSize/2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = "이름란"
        nameLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let pointLabel = UILabel()
        pointLabel.text = "0P"
        pointLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        pointLabel.textColor = UIColor(hex: "#999999")
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let settingButton = UIButton()
//        settingButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingButton.setTitle("편집하기", for: .normal)
        settingButton.setTitleColor(UIColor(hex: "#999999"), for: .normal)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.backgroundColor = UIColor(hex: "#F5F5F5")
        sectionView.layer.cornerRadius = 8
        
        let verticalStack = UIStackView(arrangedSubviews: [
            nameLabel, pointLabel
        ])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        //        verticalStack.distribution = .fillProportionally
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStack = UIStackView(arrangedSubviews: [
            profileImageView, verticalStack
        ])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        //        horizontalStack.distribution = .fill
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.addSubview(horizontalStack)
        sectionView.addSubview(settingButton)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageSize),
            
            horizontalStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 10),
            horizontalStack.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor),
            
            settingButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -10),
            settingButton.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor)
        ])
        
        return sectionView
        
    }
    
    func setupMenuSection() -> UIStackView {
        let menuItems: [String] = [
            "출석 확인",
            "수강 기록",
            "설정",
            "결제 내역"
        ]
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 16
        
//        verticalStack.backgroundColor = UIColor(hex: "#E0E0E0")
//        verticalStack.layoutMargins = UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)
//        verticalStack.isLayoutMarginsRelativeArrangement = true
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        for item in menuItems {
            var config = UIButton.Configuration.filled()
            config.title = item
            config.baseBackgroundColor = UIColor(hex: "#F0F0F0")
            config.baseForegroundColor = UIColor(hex: "#333333")
            config.cornerStyle = .medium
            
            let button = UIButton(configuration: config)
            button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            verticalStack.addArrangedSubview(button)
        }
        
        return verticalStack
        
    }
}


#Preview {
    MyPageViewController()
}
