import UIKit

class PaymentHistoryViewController: UIViewController {
    weak var coordinator: PaymentHistoryCoordinator?
    
    
    private let tableView = UITableView()
    private var paymentList: [UserPayment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationUI()
        setupUI()
        
        Task {
            await fetchPaymentsIfNeeded()
        }
    }
    
    func configurationUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PaymentHistoryTableViewCell.self, forCellReuseIdentifier: "PaymentHistoryCell")
    }
    
    func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    private func fetchPaymentData() async {
        do {
            let payments = try await SupabaseDataManager.shared.fetchUserPayments()
            DispatchQueue.main.async {
                self.paymentList = payments.sorted { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
                self.tableView.reloadData()
            }
        } catch {
            print("결제 이력 조회 실패: \(error)")
        }
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
            DispatchQueue.main.async {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell") as? PaymentHistoryTableViewCell else {
            return UITableViewCell()
        }
        
        let item = paymentList[indexPath.row]
        let title = item.description ?? "결제 내역 없음"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = item.createdAt != nil ? formatter.string(from: item.createdAt!) : "알 수 없음"
        
        let amount = "\(item.amount)원 결제"
        
        cell.configur(title: title, date: date, amount: amount)
        return cell
    }
    
    
}

extension PaymentHistoryViewController: UITableViewDelegate {
    
}


#Preview {
    PaymentHistoryViewController()
}
