// MyAttendanceViewModel.swift

import Foundation
import Combine

class MyAttendanceViewModel {
    
    // MARK: - Properties
    
    // UI에 데이터를 전달하기 위한 Combine Publisher
    @Published var monthlyAttendances: [UserAttendance] = []
    
    // 월별 데이터를 저장하는 인-메모리 캐시
    // Key: "yyyy-MM" 형식의 문자열, Value: 해당 월의 출석 데이터 배열
    private var attendanceCache: [String: [UserAttendance]] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    // 날짜 포맷터
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 캐시 키를 위한 포맷터
    private lazy var cacheKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    // MARK: - Public Methods
    
    /// 특정 날짜가 포함된 월의 출석 데이터를 가져옵니다.
    func fetchAttendances(for date: Date) {
        let cacheKey = cacheKeyFormatter.string(from: date)
        
        // 1. 캐시에 데이터가 있는지 확인
        if let cachedData = attendanceCache[cacheKey] {
            print("✅ [Cache Hit] \(cacheKey) 데이터를 캐시에서 불러옵니다.")
            self.monthlyAttendances = cachedData
            return
        }
        
        // 2. 캐시에 데이터가 없으면 네트워크에서 가져오기
        print("🔍 [Cache Miss] \(cacheKey) 데이터를 네트워크에서 요청합니다.")
        
        // 현재 로그인된 사용자 ID를 가져옵니다. (실제 앱에서는 로그인 세션에서 가져와야 함)
        guard let currentUserID = SupabaseDataManager.shared.getCurrentAuthenticatedUser()?.userId else {
            print("🚨 Error: 현재 사용자 ID를 가져올 수 없습니다.")
            return
        }
        
        // 해당 월의 시작일과 종료일 계산
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: date) else { return }
        let startDateString = dateFormatter.string(from: monthInterval.start)
        let endDateString = dateFormatter.string(from: monthInterval.end)
        
        Task {
            do {
                // SupabaseDataManager에 새로 추가할 함수 호출
                let fetchedData = try await SupabaseDataManager.shared.fetchUserAttendances(
                    userId: currentUserID,
                    from: startDateString,
                    to: endDateString
                )
                
                DispatchQueue.main.async {
                    self.attendanceCache[cacheKey] = fetchedData
                    self.monthlyAttendances = fetchedData
                    print("✅ 데이터 로드 및 캐시 저장 완료. UI 업데이트를 트리거합니다.")
                }
            } catch {
                print("🚨 Error: 출석 데이터 로딩 실패 - \(error.localizedDescription)")
            }
        }
    }
}
