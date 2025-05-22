import UIKit

class MyPagesViewController: UIViewController {
    weak var coordinator: MyPageCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        let profileSection = setupProfileSection()
        view.addSubview(profileSection)
        
        // Auto Layout 추가
        profileSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileSection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileSection.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupProfileSection() -> UIView {
        let sectionView = UIView()
        sectionView.backgroundColor = UIColor(hex: "#F5F5F5")
        sectionView.layer.cornerRadius = 8

        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .black
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = "닉네임(별칭)"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let pointLabel = UILabel()
        pointLabel.text = "XU: 0XP"
        pointLabel.font = UIFont.systemFont(ofSize: 14)
        pointLabel.textColor = .darkGray
        pointLabel.translatesAutoresizingMaskIntoConstraints = false

        let settingButton = UIButton()
        settingButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingButton.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView(arrangedSubviews: [nameLabel, pointLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        let horizontalStack = UIStackView(arrangedSubviews: [profileImageView, verticalStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        sectionView.addSubview(horizontalStack)
        sectionView.addSubview(settingButton)

        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            horizontalStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            horizontalStack.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor),
            
            settingButton.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),
            settingButton.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor)
        ])

        return sectionView
    }
}



#Preview {
    MyPagesViewController()
}
