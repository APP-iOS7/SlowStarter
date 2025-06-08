import UIKit

class CourseHistoryTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        titleLabel.textColor = UIColor(hex: "#442C2E")

        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 12
        statusLabel.clipsToBounds = true

        [titleLabel, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    func configure(title: String, isActive: Bool) {
        titleLabel.text = title
        statusLabel.text = isActive ? "수강중" : "수강완료"

        if isActive {
            statusLabel.backgroundColor = UIColor(hex: "#FEDBD0")
            statusLabel.textColor = UIColor(hex: "#442C2E")
        } else {
            statusLabel.backgroundColor = UIColor(hex: "#FEEAE6")
            statusLabel.textColor = .gray
        }
    }
}
