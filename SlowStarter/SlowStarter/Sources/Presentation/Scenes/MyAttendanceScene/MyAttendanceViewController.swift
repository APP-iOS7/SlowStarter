import UIKit

class MyAttendanceViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    weak var coordinator: MyAttendanceCoordinator?
    
    let padding: CGFloat = 10
    
    private let datePickerButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private var diaryCollectionView: UICollectionView!
    
    // 기획에 따라 달라질 것
    private let diaryLabel = UILabel()
    
    private let calendar = Calendar(identifier: .gregorian)
    private let today = Date()
    private var selectedDate: Date?
    private var currentDate = Date()
    private var currentMonthDates: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupHeader()
        setupWeekdayLabels()
        setupDiaryCollectionView()
        setupDiaryView()
        updateCalendar()
    }
    
    // MARK: - Header
    private func setupHeader() {
        let previousAction = UIAction { _ in self.didTapPrevious() }
        previousButton.setTitle("<", for: .normal)
        previousButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        previousButton.addAction(previousAction, for: .touchUpInside)
        
        let nextAction = UIAction { _ in self.didTapNext() }
        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        nextButton.addAction(nextAction, for: .touchUpInside)
        
        datePickerButton.setTitleColor(.black, for: .normal)
        datePickerButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        datePickerButton.addAction(UIAction { _ in self.didTapYearButton() }, for: .touchUpInside)
        
        let leftStack = UIStackView(arrangedSubviews: [datePickerButton])
        leftStack.axis = .horizontal
        
        let buttonsStack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        buttonsStack.axis = .horizontal
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
        
        view.addSubview(containerView)
        
        let width = (UIScreen.main.bounds.width - 2 * padding) / 7

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10),
            headerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: width / 2),
            headerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -width / 2)
        ])
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    
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
    
    // MARK: - WeekLabel
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
            label.textColor = (day == "일") ? .systemRed : (day == "토") ? .systemBlue : .black
            stackView.addArrangedSubview(label)
        }
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            stackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Diary View
    private func setupDiaryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = (UIScreen.main.bounds.width - 2 * padding) / 7
        layout.itemSize = CGSize(width: width, height: width)
        
        diaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        diaryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        diaryCollectionView.backgroundColor = .white
        diaryCollectionView.register(MyAttendanceCollectionViewCell.self, forCellWithReuseIdentifier: "DateCell")
        diaryCollectionView.dataSource = self
        diaryCollectionView.delegate = self
        
        view.addSubview(diaryCollectionView)
        NSLayoutConstraint.activate([
            diaryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            diaryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            diaryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            diaryCollectionView.heightAnchor.constraint(equalToConstant: width * 6)
        ])
    }
    
    // TODO: - 기획에 따라 이 내용 바꾸기
    private func setupDiaryView() {
        diaryLabel.font = .systemFont(ofSize: 16)
        diaryLabel.textAlignment = .center
        diaryLabel.numberOfLines = 0
        diaryLabel.textColor = .darkGray
        diaryLabel.text = ""
        diaryLabel.isHidden = true
        diaryLabel.alpha = 0
        diaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(diaryLabel)
        NSLayoutConstraint.activate([
            diaryLabel.topAnchor.constraint(equalTo: diaryCollectionView.bottomAnchor, constant: 20),
            diaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            diaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: Util 함수
    private func updateCalendar() {
        let year = Calendar.current.component(.year, from: currentDate)
        let month = Calendar.current.component(.month, from: currentDate)
        
        datePickerButton.setTitle("\(year)년 \(month)월", for: .normal)
        
        generateDates(for: currentDate)
        diaryCollectionView.reloadData()
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
    
}



extension MyAttendanceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentMonthDates.count
    }
    
    // TODO: viewModel 추가시 markedDates부분에 적용해주기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = currentMonthDates[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? MyAttendanceCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "ko_KR")
        
        cell.dayLabel.text = formatter.string(from: date)
        cell.configure(date: date,
                       currentMonth: currentDate,
                       selectedDate: selectedDate,
                       calendar: calendar,
                       today: today,
                       markedDates: makeDummyMarkedDate())
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
        diaryLabel.isHidden = false
        animateDiaryLabel(show: true)
        showDiary(for: tappedDate)
        
        if calendar.isDate(tappedDate, equalTo: currentDate, toGranularity: .month) {
            collectionView.reloadData()
        } else {
            currentDate = tappedDate
            updateCalendar()
        }
    }
    
    private func showDiary(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        diaryLabel.text = "\(formatter.string(from: date))의 다이어리 내용을 여기에 표시합니다."
    }
    
    private func animateDiaryLabel(show: Bool) {
        if show {
            diaryLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            diaryLabel.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.diaryLabel.transform = .identity
                self.diaryLabel.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.2) {
                self.diaryLabel.transform = CGAffineTransform(translationX: 0, y: 20)
                self.diaryLabel.alpha = 0
            } completion: { _ in
                self.diaryLabel.isHidden = true
            }
        }
    }
    
    private func makeDummyMarkedDate() -> [Date] {
        let calendar = Calendar.current
        return (5...10).compactMap {
            calendar.date(from: DateComponents(year: 2025, month: 5, day: $0))
        }
    }
    
    
}



#Preview {
    MyAttendanceViewController()
}
