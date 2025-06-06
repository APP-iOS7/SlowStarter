// MyAttendanceViewModel.swift

import Foundation
import Combine

class MyAttendanceViewModel {
    // MARK: - Properties
    @Published var monthlyAttendances: [UserAttendance] = []
    
    private var attendanceCache: [String: [UserAttendance]] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private lazy var cacheKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    // MARK: - Public Methods
    func fetchAttendances(for date: Date) {
        let cacheKey = cacheKeyFormatter.string(from: date)
        
        if let cachedData = attendanceCache[cacheKey] {
            self.monthlyAttendances = cachedData
            return
        }
        
        guard let currentUserID = SupabaseDataManager.shared.getCurrentAuthenticatedUser()?.userId else {
            return
        }
        
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: date) else { return }
        let startDateString = dateFormatter.string(from: monthInterval.start)
        let endDateString = dateFormatter.string(from: monthInterval.end)
        
        Task {
            do {
                let fetchedData = try await SupabaseDataManager.shared.fetchUserAttendances(
                    userId: currentUserID,
                    from: startDateString,
                    to: endDateString
                )
                
                self.attendanceCache[cacheKey] = fetchedData
                self.monthlyAttendances = fetchedData
            } catch {
                print("Error: 출석 데이터 로딩 실패 - \(error.localizedDescription)")
            }
        }
    }
}
