import UIKit

class LectureDateViewController: UIViewController {

    weak var coordinator: LectureCoordinator?

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale(identifier: "ko_KR")
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.tintColor = UIColor(hex: "#442C2E")
        picker.minimumDate = Date()
        return picker
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상담 예약"
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상담 날짜와 시간을 선택해주세요."
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textColor = UIColor(hex: "#442C2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상담 예약 확정", for: .normal)
        button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 22)
        button.backgroundColor = UIColor(hex: "#FEDBD0")
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()

    private var selectedTime: String?

    private let availableTimes = ["08:00", "09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00"]

    private lazy var timeButtons: [UIButton] = {
        return availableTimes.map { time in
            let button = UIButton(type: .system)
            button.setTitle(time, for: .normal)
            button.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
            button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
            button.backgroundColor = .white
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(hex: "#FEDBD0")?.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(timeButtonTapped(_:)), for: .touchUpInside)
            return button
        }
    }()

    private let timeButtonStackView1 = UIStackView()
    private let timeButtonStackView2 = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupConstraints()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        updateTimeButtonsAvailability()
    }

    private func setupUI() {
        nextButton.addAction(UIAction {[weak self] _ in
            guard let self = self else { return }
            
            self.coordinator?.showPayment(date: self.datePicker.date, time: self.selectedTime)
        }, for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(datePicker)
        view.addSubview(nextButton)

        timeButtonStackView1.axis = .horizontal
        timeButtonStackView1.spacing = 10
        timeButtonStackView1.distribution = .fillEqually
        timeButtonStackView1.translatesAutoresizingMaskIntoConstraints = false

        timeButtonStackView2.axis = .horizontal
        timeButtonStackView2.spacing = 10
        timeButtonStackView2.distribution = .fillEqually
        timeButtonStackView2.translatesAutoresizingMaskIntoConstraints = false

        for (index, button) in timeButtons.enumerated() {
            if index < 4 {
                timeButtonStackView1.addArrangedSubview(button)
            } else {
                timeButtonStackView2.addArrangedSubview(button)
            }
        }

        view.addSubview(timeButtonStackView1)
        view.addSubview(timeButtonStackView2)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            datePicker.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            timeButtonStackView1.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 30),
            timeButtonStackView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeButtonStackView1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeButtonStackView1.heightAnchor.constraint(equalToConstant: 44),

            timeButtonStackView2.topAnchor.constraint(equalTo: timeButtonStackView1.bottomAnchor, constant: 10),
            timeButtonStackView2.leadingAnchor.constraint(equalTo: timeButtonStackView1.leadingAnchor),
            timeButtonStackView2.trailingAnchor.constraint(equalTo: timeButtonStackView1.trailingAnchor),
            timeButtonStackView2.heightAnchor.constraint(equalToConstant: 44),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedTime = nil
        updateTimeButtonsAvailability()
        updateNextButtonState()
    }

    @objc private func timeButtonTapped(_ sender: UIButton) {
        guard sender.isEnabled else { return }

        timeButtons.forEach {
            $0.backgroundColor = .white
            $0.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        }
        sender.backgroundColor = UIColor(hex: "#FEDBD0")
        selectedTime = sender.title(for: .normal)
        updateNextButtonState()
    }

    private func updateNextButtonState() {
        let isTimeSelected = selectedTime != nil
        nextButton.isEnabled = isTimeSelected
        nextButton.alpha = isTimeSelected ? 1.0 : 0.5
    }

    private func updateTimeButtonsAvailability() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: datePicker.date)
        let now = Date()
        let limitDate = calendar.date(byAdding: .hour, value: 2, to: now)!

        for (index, time) in availableTimes.enumerated() {
            let components = time.split(separator: ":").compactMap { Int($0) }
            guard components.count == 2 else { continue }

            var dateComponents = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
            dateComponents.hour = components[0]
            dateComponents.minute = components[1]

            guard let timeDate = calendar.date(from: dateComponents) else { continue }

            let button = timeButtons[index]
            if selectedDate == today && timeDate < limitDate {
                button.isEnabled = false
                button.alpha = 0.3
            } else {
                button.isEnabled = true
                button.alpha = 1.0
            }
        }
    }
}
