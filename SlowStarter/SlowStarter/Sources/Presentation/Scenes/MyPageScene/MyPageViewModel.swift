import Combine

class MyPageViewModel {
    @Published private(set) var profileName: String = "Guest"
    @Published private(set) var profilePoint: Int = 0
    @Published private(set) var isLoggedIn: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    private let dataManager = SupabaseDataManager.shared
    
    init() {
        fetchProfile()
        
        coreDataManager.userInfoDidChangePublisher
            .sink { [weak self] _ in
                self?.fetchProfile()
            }
            .store(in: &cancellables)
    }
    
    private func fetchProfile() {
        let users = coreDataManager.fetchUserInfo()
        if let user = users.first {
            profileName = user.userName ?? "Guest"
            profilePoint = 0
            isLoggedIn = true
        } else {
            profileName = "Guest"
            profilePoint = 0
            isLoggedIn = false
        }
    }
    
    func logout() {
        let users = coreDataManager.fetchUserInfo()
        guard let user = users.first,
              let userId = user.userId else {
            return
        }
        coreDataManager.deleteUserInfo(userId: userId)
        Task {
            try await dataManager.logout()
        }
    }
}
