import UIKit

class CourseHistoryDetailViewController: UIViewController {
    var course: UserCourseHistory?

    private let titleLabel = UILabel()
    private let subscribedLabel = UILabel()
    private let nextPaymentLabel = UILabel()
    private var unsubscribeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FEEAE6")
        setupUI()
        bindData()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#FEEAE6")
        
        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 28)
        titleLabel.textColor = UIColor(hex: "#442C2E")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        subscribedLabel.font = UIFont.systemFont(ofSize: 14)
        subscribedLabel.textColor = UIColor(hex: "#442C2E")
        subscribedLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subscribedLabel)
        
        nextPaymentLabel.font = UIFont.systemFont(ofSize: 14)
        nextPaymentLabel.textColor = UIColor(hex: "#442C2E")
        nextPaymentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextPaymentLabel)
        
        var config = UIButton.Configuration.filled()
        config.title = "구독 해지하기"
        config.baseBackgroundColor = UIColor(hex: "#FEDBD0")
        config.baseForegroundColor = UIColor(hex: "#442C2E")
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        unsubscribeButton = UIButton(configuration: config, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            // TODO: 구독 해지 액션
        }))
        unsubscribeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsubscribeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            subscribedLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subscribedLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            nextPaymentLabel.topAnchor.constraint(equalTo: subscribedLabel.bottomAnchor, constant: 8),
            nextPaymentLabel.leadingAnchor.constraint(equalTo: subscribedLabel.leadingAnchor),
            
            unsubscribeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            unsubscribeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


    private func bindData() {
        guard let course = course else { return }

        titleLabel.text = course.courseTitle
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        let startDate = course.subscribedAt
        subscribedLabel.text = "구독 시작일: \(displayFormatter.string(from: startDate))"

        if course.isActive {
            if let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) {
                nextPaymentLabel.text = "다음 결제 예정일: \(displayFormatter.string(from: nextDate))"
            } else {
                nextPaymentLabel.text = "다음 결제 예정일: -"
            }
        } else {
            nextPaymentLabel.text = "" 
        }
    }


}
