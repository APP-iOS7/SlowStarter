import UIKit

class MyAttendanceCollectionViewCell: UICollectionViewCell {
    let dayLabel = UILabel()
    private let dotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()

    private let dayLabelSize: CGFloat = 32

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = false
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        contentView.clipsToBounds = false
        dayLabel.textAlignment = .center
        dayLabel.layer.cornerRadius = dayLabelSize / 2
        dayLabel.layer.masksToBounds = true
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        
        contentView.addSubview(dayLabel)
        contentView.addSubview(dotView)

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dayLabel.widthAnchor.constraint(equalToConstant: dayLabelSize),
            dayLabel.heightAnchor.constraint(equalToConstant: dayLabelSize),

            dotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4), // ✅ 더 가까이 붙임
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    func configure(date: Date, currentMonth: Date, selectedDate: Date?, calendar: Calendar, today: Date, activityTypes: [String]) {
        dayLabel.backgroundColor = .clear
        dayLabel.textColor = UIColor(hex: "#442C2E")
        dotView.backgroundColor = .clear // 초기화

        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"

        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        if !isCurrentMonth {
            dayLabel.textColor = .lightGray
        }

        let weekday = calendar.component(.weekday, from: date)
        if isCurrentMonth && weekday == 1 {
            dayLabel.textColor = UIColor(hex: "#FF3B30")
        }

        let priority: [String: Int] = ["assignment": 0, "video": 1, "attendance": 2]
        let highestPriorityType = activityTypes.min { (priority[$0] ?? 99) < (priority[$1] ?? 99) }

        if let type = highestPriorityType {
            switch type {
            case "assignment":
                dotView.backgroundColor = UIColor(hex: "#D19985")
            case "video":
                dotView.backgroundColor = UIColor(hex: "#B18D82")
            case "attendance":
                dotView.backgroundColor = UIColor(hex: "#442C2E")
            default:
                dotView.backgroundColor = .clear
            }
        }

        if calendar.isDate(date, inSameDayAs: today) {
            dayLabel.backgroundColor = UIColor(hex: "#FEDBD0")
        }

        if let selected = selectedDate, calendar.isDate(date, inSameDayAs: selected) {
            dayLabel.backgroundColor = UIColor(hex: "#FEEAE6")
        }
    }
}
