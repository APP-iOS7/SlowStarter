import UIKit

class CourseHistoryViewController: UIViewController {
    weak var coordinator: CourseHistoryCoordinator?
    private let tableView = UITableView()
    private var data: [UserCourseHistory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FEEAE6")
        setupTableView()
        fetchData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(hex: "#FEEAE6")
        tableView.register(CourseHistoryTableViewCell.self, forCellReuseIdentifier: "CourseHistoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    private func fetchData() {
        Task {
            do {
                data = try await SupabaseDataManager.shared.fetchCourseHistories()
                self.tableView.reloadData()
            } catch {
                print("Fetch error:", error)
            }
        }
    }
}


// MARK: - Data Source
extension CourseHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CourseHistoryCell",
            for: indexPath
        ) as? CourseHistoryTableViewCell else {
            return UITableViewCell()
        }

        let course = data[indexPath.row]
        cell.configure(
            title: course.courseTitle,
            isActive: course.isActive
        )

        cell.backgroundColor = .clear
        let bgView = UIView()
        bgView.backgroundColor = UIColor(hex: "#FEEAE6")
        cell.selectedBackgroundView = bgView

        return cell
    }
}

// MARK: - Delegate
extension CourseHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCourse = data[indexPath.row]
        coordinator?.showDetail(selectedCourse)
    }
}


#Preview {
    CourseHistoryViewController()
}
