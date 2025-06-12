import Foundation
import Combine

class MyAttendanceViewModel {
    @Published var monthlyAttendances: [UserAttendance] = []
    @Published var activitiesCache: [Date: [String]] = [:]
    
    private var attendanceCache: [String: [UserAttendance]] = [:]
    private let calendar = Calendar(identifier: .gregorian)
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
    
    func fetchAttendances(for date: Date) {
        let cacheKey = cacheKeyFormatter.string(from: date)
        
        if let cachedData = attendanceCache[cacheKey] {
            self.monthlyAttendances = cachedData
            let data = cachedData.compactMap { $0.attendedDateAsDate }
            self.rebuildActivityCache(for: data) 
            return
        }
        
        guard let currentUserID = SupabaseDataManager.shared.getCurrentAuthenticatedUser()?.userId else { return }
        
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
                
                let datas = fetchedData.compactMap { $0.attendedDateAsDate }
                
                self.rebuildActivityCache(for: datas)
                
            } catch {
                print("출석 데이터 로딩 실패 - \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func activitiesByDate(for currentMonthDates: [Date]) -> [Date: [String]] {
        var result: [Date: [String]] = [:]
        
        for date in currentMonthDates {
            let matching = monthlyAttendances.filter {
                guard let attended = $0.attendedDateAsDate else { return false }
                return calendar.isDate(attended, inSameDayAs: date)
            }
            
            result[date] = matching.map { $0.type.rawValue }
        }
        
        return result
    }
    
    func rebuildActivityCache(for dates: [Date]) {
        var result: [Date: [String]] = [:]
        
        for date in dates {
            let matching = monthlyAttendances.filter {
                guard let attended = $0.attendedDateAsDate else { return false }
                return calendar.isDate(attended, inSameDayAs: date)
            }
            
            let normalized = calendar.startOfDay(for: date)
            result[normalized] = matching.map { $0.type.rawValue }
        }
        
        activitiesCache = result
    }
}
