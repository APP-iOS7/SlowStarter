import UIKit

class PaymentHistoryViewController: UIViewController {
    weak var coordinator: PaymentHistoryCoordinator?

    private let tableView = UITableView()
    private var paymentList: [UserPayment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()

        Task {
            await fetchPaymentsIfNeeded()
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PaymentHistoryTableViewCell.self, forCellReuseIdentifier: "PaymentHistoryCell")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func fetchPaymentsIfNeeded() async {
        let userId = SupabaseDataManager.shared.getCurrentAuthenticatedUser()?.userId
        let localPayments = CoreDataManager.shared.fetchPayments(forUserId: userId)

        if !localPayments.isEmpty {
            self.paymentList = localPayments.map { $0.toUserPayment() }
            self.tableView.reloadData()
            return
        }

        do {
            let remotePayments = try await SupabaseDataManager.shared.fetchUserPayments()
            
            Task {
                CoreDataManager.shared.savePaymentsToCoreData(remotePayments)
                self.paymentList = remotePayments
                self.tableView.reloadData()
            }
        } catch {
            print("SUPABASE FETCH ERROR: \(error)")
        }
    }
}

extension PaymentHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell", for: indexPath) as? PaymentHistoryTableViewCell else {
            return UITableViewCell()
        }

        let item = paymentList[indexPath.row]
        let title = item.description ?? "결제 내역 없음"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = item.createdAt != nil ? formatter.string(from: item.createdAt!) : "알 수 없음"

        let amount = "\(item.amount)원 결제"

        cell.configure(title: title, date: date, amount: amount)
        return cell
    }
}

extension PaymentHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

#Preview {
    PaymentHistoryViewController()
}
