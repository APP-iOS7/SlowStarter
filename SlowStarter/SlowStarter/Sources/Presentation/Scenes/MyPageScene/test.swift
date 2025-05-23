import UIKit

extension Date {
    func startOfMonth(calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
}

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let diaryLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let monthLabel = UILabel()
    private var collectionView: UICollectionView!
    
    private let calendar = Calendar(identifier: .gregorian)
    private let today = Date()
    private var selectedDate: Date?
    private var currentDate = Date()
    private var currentMonthDates: [Date] = []

    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHeader()
        setupWeekdayLabels()
        setupCollectionView()
        setupDiaryView()
        updateCalendar()
    }
    
    private func setupHeader() {
        previousButton.setTitle("<", for: .normal)
        previousButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        previousButton.addTarget(self, action: #selector(didTapPrevious), for: .touchUpInside)

        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)

        monthLabel.textAlignment = .center
        monthLabel.font = UIFont.boldSystemFont(ofSize: 18)
        monthLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMonthLabel))
            monthLabel.addGestureRecognizer(tapGesture)

        let stackView = UIStackView(arrangedSubviews: [previousButton, monthLabel, nextButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            monthLabel.widthAnchor.constraint(equalToConstant: 140)
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
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            label.textColor = (day == "일") ? .systemRed : (day == "토") ? .systemBlue : .black
            stackView.addArrangedSubview(label)
        }

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: monthLabel.superview!.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let width = UIScreen.main.bounds.width / 7
        layout.itemSize = CGSize(width: width, height: width)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(MyAttendanceCollectionViewCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: monthLabel.superview!.bottomAnchor, constant: 36),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: width * 6)
        ])
    }

    private func setupDiaryView() {
        diaryLabel.font = .systemFont(ofSize: 16)
        diaryLabel.textAlignment = .center
        diaryLabel.numberOfLines = 0
        diaryLabel.textColor = .darkGray
        diaryLabel.text = "날짜를 선택하세요"
        diaryLabel.isHidden = true
        diaryLabel.alpha = 0
        diaryLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(diaryLabel)
        NSLayoutConstraint.activate([
            diaryLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            diaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            diaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func updateCalendar() {
        monthLabel.text = formattedMonth(from: currentDate)
        generateDates(for: currentDate)
        collectionView.reloadData()
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
                if let day = calendar.date(byAdding: .day, value: totalDays - daysToShow + i, to: previousMonth.startOfMonth(calendar: calendar)) {
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

    @objc private func didTapPrevious() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateCalendar()
        }
    }

    @objc private func didTapNext() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateCalendar()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentMonthDates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = currentMonthDates[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! MyAttendanceCollectionViewCell
        
        cell.dayLabel.text = dateFormatter.string(from: date)
        cell.configure(date: date,
                       currentMonth: currentDate,
                       selectedDate: selectedDate,
                       calendar: calendar,
                       today: today,
                       markedDates: dummyMarkedDates)
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
            UIView.animate(withDuration: 0.2, animations: {
                self.diaryLabel.transform = CGAffineTransform(translationX: 0, y: 20)
                self.diaryLabel.alpha = 0
            }) { _ in
                self.diaryLabel.isHidden = true
            }
        }
    }

    private let dummyMarkedDates: [Date] = {
        let calendar = Calendar.current
        return (5...10).compactMap {
            calendar.date(from: DateComponents(year: 2025, month: 5, day: $0))
        }
    }()
    
    @objc private func didTapMonthLabel() {
        let alertController = UIAlertController(title: "월 선택", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // 현재 날짜 설정
        datePicker.date = currentDate
        
        alertController.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20)
        ])
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "선택", style: .default, handler: { _ in
            self.currentDate = datePicker.date
            self.updateCalendar()
        }))
        
        present(alertController, animated: true)
    }

}

class MyAttendanceCollectionViewCells: UICollectionViewCell {
    let label = UILabel()
    private let donutView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(label)

        donutView.translatesAutoresizingMaskIntoConstraints = false
        donutView.backgroundColor = .clear
        donutView.layer.borderColor = UIColor.systemRed.cgColor
        donutView.layer.borderWidth = 2
        donutView.layer.cornerRadius = 12
        donutView.isHidden = true
        contentView.addSubview(donutView)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 32),
            label.heightAnchor.constraint(equalToConstant: 32),
            
            donutView.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            donutView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            donutView.widthAnchor.constraint(equalToConstant: 24),
            donutView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(date: Date, currentMonth: Date, selectedDate: Date?, calendar: Calendar, today: Date, markedDates: [Date]) {
        let day = calendar.component(.day, from: date)
        label.text = "\(day)"
        
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        label.textColor = isCurrentMonth ? .black : .lightGray
        label.backgroundColor = .clear
        label.layer.borderWidth = 0

        if calendar.isDate(date, inSameDayAs: today) {
            label.layer.borderColor = UIColor.systemRed.cgColor
            label.layer.borderWidth = 2
        }

        if let selected = selectedDate, calendar.isDate(date, inSameDayAs: selected) {
            label.backgroundColor = .systemBlue
            label.textColor = .white
            UIView.animate(withDuration: 0.2, animations: {
                self.label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.label.transform = .identity
                }
            }
        }

        donutView.isHidden = !markedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}


#Preview {
    CalendarViewController()
}
