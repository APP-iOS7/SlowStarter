import UIKit

class PaymentViewController: UIViewController {

    weak var coordinator: LectureCoordinator?

    // MARK: - 전달받는 값
    var selectedDate: Date?
    var selectedTime: String?

    // MARK: - UI Components

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "상담 예약이 완료되었어요!\n원하는 다음 단계로 이동해 주세요."
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
        label.textColor = UIColor(hex: "#442C2E")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textColor = UIColor(hex: "#442C2E")
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let repeatLearningButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("반복 학습 시작하기", for: .normal)
        button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Black", size: 18)
        button.backgroundColor = UIColor(hex: "#FEDBD0")
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("홈으로 돌아가기", for: .normal)
        button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        button.backgroundColor = UIColor(hex: "#FEEAE6")
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupConstraints()
        updateDateTimeLabel()

        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        repeatLearningButton.addTarget(self, action: #selector(repeatLearningButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(messageLabel)
        view.addSubview(dateTimeLabel)
        view.addSubview(repeatLearningButton) // 🔁 위로 이동
        view.addSubview(homeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateTimeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            dateTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            repeatLearningButton.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 40),
            repeatLearningButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            repeatLearningButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            repeatLearningButton.heightAnchor.constraint(equalToConstant: 60),

            homeButton.topAnchor.constraint(equalTo: repeatLearningButton.bottomAnchor, constant: 20),
            homeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            homeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            homeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Update Date & Time Label

    private func updateDateTimeLabel() {
        guard let date = selectedDate, let time = selectedTime else {
            dateTimeLabel.text = "선택된 날짜와 시간이 없습니다."
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)" // 예: 2025년 6월 12일 (목)
        let dateString = formatter.string(from: date)

        dateTimeLabel.text = "예약 시간: \(dateString) \(time)"
    }

    // MARK: - Actions

    @objc private func homeButtonTapped() {
        coordinator?.goHome()
    }

    @objc private func repeatLearningButtonTapped() {
        coordinator?.goRepeatLecture()
    }
}
