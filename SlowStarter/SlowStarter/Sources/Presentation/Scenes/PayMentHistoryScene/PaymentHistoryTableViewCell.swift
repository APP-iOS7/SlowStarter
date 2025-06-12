import UIKit

class PaymentHistoryTableViewCell: UITableViewCell {

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = UIColor(hex: "#FEEAE6")
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 16)
        titleLabel.textColor = UIColor(hex: "#442C2E")

        dateLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        dateLabel.textColor = .systemGray

        amountLabel.font = UIFont(name: "Pretendard-Bold", size: 14)
        amountLabel.textColor = UIColor(hex: "#442C2E")
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
        topRow.axis = .horizontal
        topRow.distribution = .equalSpacing

        let verticalStack = UIStackView(arrangedSubviews: [topRow, dateLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            verticalStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            verticalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            verticalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    func configure(title: String, date: String, amount: String) {
        titleLabel.text = title
        dateLabel.text = date
        amountLabel.text = amount
    }
}
