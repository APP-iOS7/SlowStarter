import UIKit

class CourseHistoryDetailViewController: UIViewController {
    let padding: CGFloat = 10
    
    let profileImageSize: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        let profileView = setupLecturerProfile()
        let detailView = setupLectureDetail() // 아래에 수정된 함수 참고
        
        view.addSubview(profileView)
        view.addSubview(detailView)

        profileView.translatesAutoresizingMaskIntoConstraints = false
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            profileView.heightAnchor.constraint(equalToConstant: 80),

            detailView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 24),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }

    
    func setupLecturerProfile() -> UIView {
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
        
        let categoryLabel = UILabel()
        categoryLabel.text = "종목"
        categoryLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
        categoryLabel.textColor = UIColor(hex: "#999999")
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.backgroundColor = UIColor(hex: "#F5F5F5")
        sectionView.layer.cornerRadius = 8
        
        let verticalStack = UIStackView(arrangedSubviews: [
            nameLabel, categoryLabel
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
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageSize),
            
            horizontalStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 10),
            horizontalStack.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor)
        ])
        
        return sectionView
    }
    
    func setupLectureDetail() -> UIView {
        let lectureNameLabel = UILabel()
        lectureNameLabel.font = UIFont(name: "Pretendard-Bold", size: 28)
        lectureNameLabel.text = "Introduction to Swift"

        let subscribeConstantLabel = UILabel()
        subscribeConstantLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        subscribeConstantLabel.text = "구독 시작일자"
        subscribeConstantLabel.setContentHuggingPriority(.required, for: .horizontal)

        let subscribeLabel = UILabel()
        subscribeLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        subscribeLabel.text = "0000년 00월 00일"

        let subscribeHorizontalStackView = UIStackView(arrangedSubviews: [subscribeConstantLabel, subscribeLabel])
        subscribeHorizontalStackView.axis = .horizontal
        subscribeHorizontalStackView.spacing = 8
        

        let scheduledPaymentConstantLabel = UILabel()
        scheduledPaymentConstantLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        scheduledPaymentConstantLabel.text = "결제 예정일자"
        scheduledPaymentConstantLabel.setContentHuggingPriority(.required, for: .horizontal)

        let scheduledPaymentLabel = UILabel()
        scheduledPaymentLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        scheduledPaymentLabel.text = "0000년 00월 00일"

        let scheduledPaymentHorizontalStackView = UIStackView(arrangedSubviews: [scheduledPaymentConstantLabel, scheduledPaymentLabel])
        scheduledPaymentHorizontalStackView.axis = .horizontal
        scheduledPaymentHorizontalStackView.spacing = 8

        let verticalStackView = UIStackView(arrangedSubviews: [
            lectureNameLabel,
            subscribeHorizontalStackView,
            scheduledPaymentHorizontalStackView
        ])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 16
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.addSubview(verticalStackView)
        containerView.layer.cornerRadius = 8
        containerView.backgroundColor = UIColor(hex: "#F5F5F5")
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            verticalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            verticalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            verticalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding)
        ])

        return containerView
    }

    
}


#Preview {
    CourseHistoryDetailViewController()
}
