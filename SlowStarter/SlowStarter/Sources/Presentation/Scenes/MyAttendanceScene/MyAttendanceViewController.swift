import UIKit
import Combine

class MyAttendanceViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    weak var coordinator: MyAttendanceCoordinator?
    private var viewModel = MyAttendanceViewModel()
    
    private let padding: CGFloat = 10
    
    private let calendarContainerView = UIView()
    private let recordContainerView = UIView()
    private let datePickerButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private var diaryCollectionView: UICollectionView!
    private let diaryLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let calendar = Calendar(identifier: .gregorian)
    private let today = Date()
    private var selectedDate: Date?
    private var currentDate = Date()
    private var currentMonthDates: [Date] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupCalendarContainer()
        setupHeader()
        setupWeekdayLabels()
        setupDiaryCollectionView()
        setupRecordView()
        updateCalendar()
        bindViewModel()
    }
    
    private func setupCalendarContainer() {
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.backgroundColor = .white
        calendarContainerView.layer.borderColor = UIColor(hex: "#FEDBD0")?.cgColor
        calendarContainerView.layer.borderWidth = 1
        calendarContainerView.layer.cornerRadius = 12
        view.addSubview(calendarContainerView)
        
        NSLayoutConstraint.activate([
            calendarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupHeader() {
        previousButton.setTitle("<", for: .normal)
        previousButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        previousButton.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        previousButton.addAction(UIAction { _ in self.didTapPrevious() }, for: .touchUpInside)
        
        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        nextButton.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        nextButton.addAction(UIAction { _ in self.didTapNext() }, for: .touchUpInside)
        
        datePickerButton.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        datePickerButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        datePickerButton.addAction(UIAction { _ in self.didTapYearButton() }, for: .touchUpInside)
        
        let leftStack = UIStackView(arrangedSubviews: [datePickerButton])
        let buttonsStack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        buttonsStack.spacing = 12
        buttonsStack.alignment = .center
        buttonsStack.setContentHuggingPriority(.required, for: .horizontal)
        
        let headerStack = UIStackView(arrangedSubviews: [leftStack, buttonsStack])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerStack)
        calendarContainerView.addSubview(containerView)
        
        let width = (UIScreen.main.bounds.width - 2 * padding) / 7
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10),
            headerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: width / 2),
            headerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -width / 2),
            
            containerView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor)
        ])
    }
    
    private func setupWeekdayLabels() {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        weekdays.forEach { day in
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            
            if day == "일" {
                label.textColor = UIColor(hex: "#FF3B30")
            } else {
                label.textColor = UIColor(hex: "#442C2E")
            }
            
            stackView.addArrangedSubview(label)
        }
        
        calendarContainerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -padding),
            stackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupDiaryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = (UIScreen.main.bounds.width - (2 * padding + 32)) / 7
        layout.itemSize = CGSize(width: width, height: width)
        
        diaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        diaryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        diaryCollectionView.backgroundColor = .white
        diaryCollectionView.register(MyAttendanceCollectionViewCell.self, forCellWithReuseIdentifier: "DateCell")
        diaryCollectionView.dataSource = self
        diaryCollectionView.delegate = self
        
        calendarContainerView.addSubview(diaryCollectionView)
        NSLayoutConstraint.activate([
            diaryCollectionView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor, constant: 100),
            diaryCollectionView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: padding),
            diaryCollectionView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -padding),
            diaryCollectionView.heightAnchor.constraint(equalToConstant: width * 6),
            diaryCollectionView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: -16)
        ])
    }

    private func setupRecordView() {
        recordContainerView.translatesAutoresizingMaskIntoConstraints = false
        recordContainerView.backgroundColor = UIColor(hex: "#FEDBD0")
        recordContainerView.layer.cornerRadius = 12
        recordContainerView.isHidden = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true

        contentView.translatesAutoresizingMaskIntoConstraints = false

        diaryLabel.font = .systemFont(ofSize: 16)
        diaryLabel.numberOfLines = 0
        diaryLabel.textColor = UIColor(hex: "#442C2E")
        diaryLabel.textAlignment = .left
        diaryLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(recordContainerView)
        recordContainerView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(diaryLabel)

        NSLayoutConstraint.activate([
            recordContainerView.topAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: 16),
            recordContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            scrollView.topAnchor.constraint(equalTo: recordContainerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: recordContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: recordContainerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: recordContainerView.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            diaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            diaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            diaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            diaryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }


    
    // MARK: Util 함수
    private func didTapYearButton() {
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        let pickerViewController = CustomDatePicker(year: currentYear, month: currentMonth)
        pickerViewController.modalPresentationStyle = .pageSheet
        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        pickerViewController.onYearMonthSelected = { [weak self] year, month in
            guard let self = self else { return }
            if let newDate = calendar.date(from: DateComponents(year: year, month: month)) {
                self.currentDate = newDate
                self.updateCalendar()
            }
        }
        
        present(pickerViewController, animated: true)
    }
    
    func updateCalendar() {
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)

        datePickerButton.setTitle("\(year)년 \(month)월", for: .normal)

        generateDates(for: currentDate)
        viewModel.fetchAttendances(for: currentDate)
        
        viewModel.rebuildActivityCache(for: currentMonthDates)

        Task { [weak self] in
            self?.diaryCollectionView.reloadData()
        }
    }
    
    private func formattedMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func generateDates(for date: Date) {
        currentMonthDates.removeAll()
        
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return }
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth),
           let prevRange = calendar.range(of: .day, in: .month, for: previousMonth) {
            let daysToShow = firstWeekday - 1
            let totalDays = prevRange.count
            
            for i in 0..<daysToShow {
                let components = calendar.dateComponents([.year, .month], from: previousMonth)
                let startOfMonths = calendar.date(from: components) ?? Date()
                if let day = calendar.date(byAdding: .day, value: totalDays - daysToShow + i, to: startOfMonths) {
                    currentMonthDates.append(day)
                }
            }
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                currentMonthDates.append(date)
            }
        }
        
        
        while currentMonthDates.count < 42 {
            if let lastDate = currentMonthDates.last,
               let nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate) {
                currentMonthDates.append(nextDate)
            }
        }
    }
    
    private func didTapPrevious() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateCalendar()
        }
    }
    
    private func didTapNext() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateCalendar()
        }
    }
    
    // MARK: ViewModel
    private func bindViewModel() {
        viewModel.$monthlyAttendances
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.diaryCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$activitiesCache
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.diaryCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}



extension MyAttendanceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentMonthDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? MyAttendanceCollectionViewCell else {
            return UICollectionViewCell()
        }

        let date = calendar.startOfDay(for: currentMonthDates[indexPath.item])
        let types = viewModel.activitiesCache[date] ?? []
        
        
        cell.configure(
            date: date,
            currentMonth: currentDate,
            selectedDate: selectedDate,
            calendar: calendar,
            today: today,
            activityTypes: types
        )

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tappedDate = currentMonthDates[indexPath.item]
        
        if let selected = selectedDate, calendar.isDate(tappedDate, inSameDayAs: selected) {
            selectedDate = nil
            animateDiaryLabel(show: false)
            collectionView.reloadData()
            return
        }
        
        selectedDate = tappedDate
        
        showDiary(for: tappedDate)
        
        animateDiaryLabel(show: true)
        
        if calendar.isDate(tappedDate, equalTo: currentDate, toGranularity: .month) {
            collectionView.reloadData()
        } else {
            currentDate = tappedDate
            updateCalendar()
        }
    }
    
    private func showDiary(for date: Date) {
        let diaryEntries = viewModel.monthlyAttendances.filter { attendance in
            guard let attendedDate = attendance.attendedDateAsDate else { return false }
            return calendar.isDate(attendedDate, inSameDayAs: date)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        let dateString = formatter.string(from: date)
        
        let title = "\(dateString)\n"
        let attributedText = NSMutableAttributedString(string: title + "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor(hex: "#442C2E") ?? .black
        ])
        
        let typeColor: [AttendanceType: UIColor] = [
            .assignment: UIColor(hex: "#D19985") ?? .black,
            .video: UIColor(hex: "#B18D82") ?? .black,
            .attendance: UIColor(hex: "#442C2E") ?? .black
        ]
        
        for entry in diaryEntries {
            let type = entry.type
            let bullet = "● "
            let coloredBullet = NSAttributedString(
                string: bullet,
                attributes: [.foregroundColor: typeColor[type] ?? .black]
            )
            
            let typeScript: String
            
            switch type {
            case .assignment: typeScript = "과제 제출"
            case .video: typeScript = "동영상 시청"
            case .attendance: typeScript = "출석"
            case .unknown: typeScript = "기타"
            }
            
            let boldType = NSAttributedString(
                string: "[\(typeScript)] ",
                attributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
            )
            
            let description = NSAttributedString(
                string: (entry.description ?? "") + "\n",
                attributes: [.font: UIFont.systemFont(ofSize: 16)]
            )
            
            attributedText.append(coloredBullet)
            attributedText.append(boldType)
            attributedText.append(description)
        }
        
        diaryLabel.attributedText = attributedText
        
        updateScrollEnabledIfNeeded()
    }
    
    private func updateScrollEnabledIfNeeded() {
        scrollView.layoutIfNeeded()

        let contentHeight = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let visibleHeight = scrollView.frame.height

        scrollView.isScrollEnabled = contentHeight > visibleHeight
    }
    
    private func animateDiaryLabel(show: Bool) {
        if show {
            recordContainerView.isHidden = false
            diaryLabel.isHidden = false
            diaryLabel.alpha = 0
            diaryLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(withDuration: 0.3) {
                self.diaryLabel.alpha = 1
                self.diaryLabel.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.diaryLabel.alpha = 0
                self.diaryLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            } completion: { _ in
                self.recordContainerView.isHidden = true
            }
        }
    }
}



#Preview {
    MyAttendanceViewController()
}
