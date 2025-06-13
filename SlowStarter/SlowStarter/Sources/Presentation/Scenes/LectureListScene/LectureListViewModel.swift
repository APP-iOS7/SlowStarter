import UIKit

final class LectureListViewModel {
    private let locationManager: LocationManager = LocationManager()
    
    let title: String = "강의 리스트"
    let subtitle: String = "다양한 강의를 직접 경험하세요!"
    var locationText: String = "강남구"
    let searchBarText: String = "사는곳 또는 직무를 입력해 강의를 검색하세요."
    
    private(set) var lectures: [LectureDetail] = []
    
    // MARK: - Methods
    // 모든 강의 목록을 불러옴
    func fetchLectures(completion: @escaping () -> Void) {
        Task {
            do {
                let lectures: [Lecture] = try await SupabaseDataManager.shared.fetchLectureList()
                let images: [LectureIntroImage] = try await SupabaseDataManager.shared.fetchLectureimages()
                let videos: [LectureIntroVideo] = try await SupabaseDataManager.shared.fetchLectureVideos()
                
                // 강의 ID 별로 이미지, 비디오 grouping
                let imagesByLectureID = Dictionary(grouping: images) { $0.lectureId }
                let videosByLectureID = Dictionary(grouping: videos) { $0.lectureId }
                
                for lecture in lectures {
                    // 강의와 일치하는 이미지, 비디오 추가
                    let detail: LectureDetail = LectureDetail(
                        lecture: lecture,
                        lecture_intro_images: imagesByLectureID[lecture.lectureId],
                        lecture_intro_video: videosByLectureID[lecture.lectureId]?.first
                    )
                    
                    self.lectures.append(detail) // 배열에 추가
                    completion()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // 검색 기능, 키워드를 포함하는 강의 제목을 가진 강의들을 불러옴
    func searchLectures(for keyword: String, completion: @escaping ([LectureDetail]) -> Void) {
        Task {
            do {
                var details: [LectureDetail] = []
                let lectures: [Lecture] = try await SupabaseDataManager.shared.searchLectureList(for: keyword)
                
                for lecture in lectures {
                    let images: [LectureIntroImage] =
                        try await SupabaseDataManager.shared.searchLectureImage(with: lecture.lectureId)
                    let video: LectureIntroVideo =
                        try await SupabaseDataManager.shared.searchLectureVideo(with: lecture.lectureId)
                    
                    let detail: LectureDetail = LectureDetail(
                        lecture: lecture,
                        lecture_intro_images: images,
                        lecture_intro_video: video
                    )
                    
                    details.append(detail)
                }
                
                completion(details)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // 위치 정보를 받아서 동 정보를 불러옴
    func fetchLocationInfo(completion: @escaping () -> Void) {
        Task {
            do {
                try await locationManager.requestAuthorizationIfNeeded()
                locationText = try await locationManager.getDong()
                completion()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
