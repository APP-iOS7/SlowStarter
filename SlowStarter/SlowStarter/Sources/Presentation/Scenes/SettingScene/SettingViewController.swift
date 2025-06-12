import UIKit

class SettingViewController: UIViewController {
    weak var coordinator: SettingCoordinator?

    private let cellHeight: CGFloat = 54
    private let sectionName: [String] = ["알림 설정"]
    private let sectionItemName: [[String]] = [["반복학습 알림"]]
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupUI()
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }

    private func setupUI() {
        view.backgroundColor = .white

        let versionLabel = UILabel()
        versionLabel.text = "ver 0.0.1"
        versionLabel.font = UIFont(name: "Pretendard-Light", size: 12)
        versionLabel.textColor = UIColor(hex: "#442C2E")
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -10),

            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionName.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        header.textLabel?.textColor = UIColor(hex: "#442C2E")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItemName[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }

        if indexPath.row == 0 {
            cell.isOn = testFunc
        }
        cell.config(text: sectionItemName[indexPath.section][indexPath.row])
        return cell
    }

    func testFunc() {
        print("test for cell 1 function")
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
