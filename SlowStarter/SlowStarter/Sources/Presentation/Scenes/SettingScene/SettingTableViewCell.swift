import UIKit

class SettingTableViewCell: UITableViewCell {

    var isOn: (() -> Void)?
    var isOff: (() -> Void)?

    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = UIColor(hex: "#FEDBD0")
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 16)
        titleLabel.textColor = UIColor(hex: "#442C2E")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        toggleSwitch.onTintColor = UIColor(hex: "#D19985")
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addAction(UIAction { _ in
            if self.toggleSwitch.isOn {
                (self.isOn ?? self.testFunc)()
            } else {
                (self.isOff ?? self.testFunc)()
            }
        }, for: .valueChanged)

        containerView.addSubview(titleLabel)
        containerView.addSubview(toggleSwitch)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    private func testFunc() {
        print("did not inserted function")
    }

    func config(text: String) {
        titleLabel.text = text
    }
}
