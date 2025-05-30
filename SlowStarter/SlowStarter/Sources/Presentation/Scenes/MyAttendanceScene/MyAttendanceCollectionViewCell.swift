import UIKit

class MyAttendanceCollectionViewCell: UICollectionViewCell {
    let dayLabel = UILabel()
    private let attendanceView = UIView()
    
    private let dayLabelSize: CGFloat = 32
    private let attendanceViewSize: CGFloat = 32
    
    private let selectedBackgroundDayLabelColor: UIColor = .systemBlue

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        dayLabel.textAlignment = .center
        dayLabel.layer.cornerRadius = dayLabelSize/2
        dayLabel.layer.masksToBounds = true
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        attendanceView.backgroundColor = .clear
        attendanceView.layer.borderColor = UIColor.systemRed.cgColor
        attendanceView.layer.borderWidth = 2
        attendanceView.layer.cornerRadius = attendanceViewSize/2
        attendanceView.isHidden = true
        attendanceView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(attendanceView)

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: dayLabelSize),
            dayLabel.heightAnchor.constraint(equalToConstant: dayLabelSize),
            
            attendanceView.centerXAnchor.constraint(equalTo: dayLabel.centerXAnchor),
            attendanceView.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            attendanceView.widthAnchor.constraint(equalToConstant: attendanceViewSize),
            attendanceView.heightAnchor.constraint(equalToConstant: attendanceViewSize)
        ])
    }

    func configure(date: Date, currentMonth: Date, selectedDate: Date?, calendar: Calendar, today: Date, markedDates: [Date]) {
        let day = calendar.component(.day, from: date)
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        
        dayLabel.text = "\(day)"
        dayLabel.textAlignment = .center
        dayLabel.textColor = isCurrentMonth ? .black : .lightGray
        dayLabel.backgroundColor = .clear
//        dayLabel.layer.borderWidth = 1

        if calendar.isDate(date, inSameDayAs: today) {
            //켈린더에 오늘 날짜라면 표시할 것 정의 부
            dayLabel.backgroundColor = UIColor(hex: "#FFD700")
            
//            dayLabel.layer.borderColor = UIColor(hex: "#FFD700")?.cgColor
//            dayLabel.layer.borderWidth = 2
        }

        if let selected = selectedDate, calendar.isDate(date, inSameDayAs: selected) {
            dayLabel.backgroundColor = selectedBackgroundDayLabelColor
            dayLabel.textColor = .white
            
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.dayLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.dayLabel.transform = .identity
                })
            })
        }

        attendanceView.isHidden = !markedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}
