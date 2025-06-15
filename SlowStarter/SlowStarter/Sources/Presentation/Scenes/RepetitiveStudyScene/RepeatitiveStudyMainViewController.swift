import UIKit
import SnapKit

class RepetitiveLearningViewController: UIViewController {
    weak var coordinator: RepeatitiveStudyMainCoordinator?
    
    // MARK: - Properties
    private var repeatLearnDataSet: [RepeatLearnData] = []
    private var attendanceData: [UserAttendance] = []
    
    // MARK: - UI Elements (선언부)
    // ✅ 모든 UI 컴포넌트 선언을 간결하게 변경
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // --- Section 2 ---
    private let stampSectionContainerView = UIView()
    private let dailyStampTitleLabel = UILabel()
    private let daysStackView = UIStackView()
    private let circlesStackView = UIStackView()
    private let attendanceCompleteButton = UIButton(type: .custom)
    
    // --- Section 3 ---
    private let mainImageViewBaseView = UIView()
    private let mainImageView = UIImageView()
    private let imageOverlayView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let lessonTitleLabel = UILabel()
    private let lessonSubtitleLabel = UILabel()
    
    // `likeButton`은 다른 UILabel을 포함하므로 팩토리 메서드 패턴을 유지하는 것이 좋습니다.
    private let likeCountLabel = UILabel()
    private lazy var likeButton: UIButton = createLikeButton()
    
    // --- Section 4 ---
    private let vodReviewTitleLabel = UILabel()
    private let assignmentButtonsStackView = UIStackView()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 뷰가 나타날 때마다 데이터를 로드합니다.
        loadRepeatLearnData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUIComponents()
        setupUI()
        setupLayout()
        populateStampSection()
        populateAssignmentButtons()
        // activityIndicator를 뷰에 추가
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        // ✅ viewDidLoad에서 데이터 로딩을 시작합니다.
        loadInitialData()
        
        print(repeatLearnDataSet)
    }
    private func configureUIComponents() {
        activityIndicator.hidesWhenStopped = true
        
        scrollView.showsVerticalScrollIndicator = false
        
        // --- Section 2 ---
        stampSectionContainerView.backgroundColor = .white
        stampSectionContainerView.clipsToBounds = true
        
        dailyStampTitleLabel.text = "매일매일 성장 스탬프"
        dailyStampTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dailyStampTitleLabel.textAlignment = .center
        
        daysStackView.axis = .horizontal
        daysStackView.distribution = .fillEqually
        daysStackView.alignment = .center
        
        circlesStackView.axis = .horizontal
        circlesStackView.distribution = .fillEqually
        circlesStackView.alignment = .center
        circlesStackView.spacing = 8
        
        attendanceCompleteButton.setTitle("출석체크 완료", for: .normal)
        attendanceCompleteButton.setTitleColor(.black, for: .normal)
        attendanceCompleteButton.backgroundColor = UIColor(named: "PrimaryPeach")
        attendanceCompleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        attendanceCompleteButton.layer.cornerRadius = 3
        attendanceCompleteButton.clipsToBounds = true
        
        // --- Section 3 ---
        mainImageViewBaseView.layer.cornerRadius = 20
        mainImageViewBaseView.clipsToBounds = true
        
        mainImageView.image = UIImage(named: "sample_img")
        mainImageView.contentMode = .scaleAspectFill
        
        imageOverlayView.layer.cornerRadius = 20
        imageOverlayView.clipsToBounds = true
        
        lessonTitleLabel.text = "강의를 불러오는 중..." // 기본 텍스트
        lessonTitleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        lessonTitleLabel.textColor = .black
        
        lessonSubtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        lessonSubtitleLabel.textColor = .black
        
        likeCountLabel.font = .systemFont(ofSize: 13, weight: .medium)
        likeCountLabel.textColor = .black
        
        // --- Section 4 ---
        vodReviewTitleLabel.text = "오늘의 VOD 복습 과제"
        vodReviewTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        vodReviewTitleLabel.textAlignment = .center
        
        assignmentButtonsStackView.axis = .vertical
        assignmentButtonsStackView.spacing = 10
        assignmentButtonsStackView.distribution = .fillEqually
    }
    private func createLikeButton() -> UIButton {
        // 1. 기본 버튼 생성
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        
        // 2. 버튼 내부에 들어갈 아이콘 이미지 뷰 생성
        let iconImageView = UIImageView(image: UIImage(systemName: "hand.thumbsup.fill"))
        iconImageView.tintColor = .black
        
        // 3. 버튼 내부에 들어갈 카운트 레이블 생성
        //    이 레이블은 클래스의 프로퍼티로 선언된 'likeCountLabel'을 사용합니다.
        //    이렇게 하면 나중에 'likeCountLabel.text'를 쉽게 변경할 수 있습니다.
        
        // 4. 아이콘과 레이블을 가로로 정렬할 스택 뷰 생성
        let stackView = UIStackView(arrangedSubviews: [iconImageView, likeCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false // 스택 뷰 자체가 탭 이벤트를 가로채지 않도록 설정
        
        // 5. 생성된 스택 뷰를 버튼의 자식 뷰로 추가
        button.addSubview(stackView)
        
        // 6. 스택 뷰의 레이아웃 설정 (버튼 중앙에 위치)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        // 7. 완성된 버튼 반환
        return button
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Section 2
        contentView.addSubview(stampSectionContainerView)
        stampSectionContainerView.addSubview(dailyStampTitleLabel)
        stampSectionContainerView.addSubview(daysStackView)
        stampSectionContainerView.addSubview(circlesStackView)
        stampSectionContainerView.addSubview(attendanceCompleteButton)
        
        // Section 3
        contentView.addSubview(mainImageViewBaseView)
        mainImageViewBaseView.addSubview(mainImageView)
        mainImageViewBaseView.addSubview(imageOverlayView) // 오버레이를 BaseView에 추가 (이미지 위에)
        
        // UIVisualEffectView의 contentView에 자식 뷰 추가
        imageOverlayView.contentView.addSubview(lessonTitleLabel)
        imageOverlayView.contentView.addSubview(lessonSubtitleLabel)
        imageOverlayView.contentView.addSubview(likeButton)
        
        // mainImageViewBaseView.addSubview(heartButton) // 하트 버튼은 BaseView에 추가
        
        // Section 4
        contentView.addSubview(vodReviewTitleLabel)
        contentView.addSubview(assignmentButtonsStackView)
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
        
        // ScrollView Layout
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            // contentView의 높이는 내부 요소에 따라 결정
        }
        
        // Section 2
        stampSectionContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        dailyStampTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        daysStackView.snp.makeConstraints { make in
            make.top.equalTo(dailyStampTitleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        circlesStackView.snp.makeConstraints { make in
            make.top.equalTo(daysStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        attendanceCompleteButton.snp.makeConstraints { make in
            make.top.equalTo(circlesStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-20) // stampSectionContainerView의 바닥
        }
        
        // Section 3
        mainImageViewBaseView.snp.makeConstraints { make in
            make.top.equalTo(stampSectionContainerView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(mainImageViewBaseView.snp.width).multipliedBy(0.8)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageOverlayView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(mainImageViewBaseView).inset(10) // BaseView의 하단에 맞춤
            // 높이는 내부 컨텐츠(lessonSubtitleLabel의 bottom)에 의해 결정
        }
        
        lessonTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualTo(likeButton.snp.leading).offset(-10)
        }
        
        lessonSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(lessonTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(lessonTitleLabel)
            make.trailing.equalTo(lessonTitleLabel)
            make.bottom.equalToSuperview().offset(-20) // imageOverlayView.contentView의 바닥
        }
        
        likeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(lessonSubtitleLabel.snp.top) // 타이틀과 서브타이틀 사이에 위치하도록 조정 (디자인 참고)
            // 또는 바닥에 맞추려면: make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        
        //        heartButton.snp.makeConstraints { make in
        //            make.top.equalToSuperview().offset(15)
        //            make.trailing.equalToSuperview().offset(-15)
        //            make.width.height.equalTo(36)
        //        }
        
        // Section 4
        vodReviewTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImageViewBaseView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        assignmentButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(vodReviewTitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30) // contentView의 마지막 요소
        }
    }
    
    // MARK: - Helper Methods
    private func populateStampSection() {
        let dayNames = ["월", "화", "수", "목", "금", "토", "일"]
        daysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // 기존 뷰 제거 (재호출 대비)
        circlesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for dayName in dayNames {
            let label = UILabel()
            label.text = dayName
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            label.textColor = .darkGray
            daysStackView.addArrangedSubview(label)
        }
        
        for i in 0..<7 {
            let circleContainer = createDayCircleView(isCompleted: i == 0)
            circlesStackView.addArrangedSubview(circleContainer)
            // circleContainer의 높이는 circlesStackView의 정렬 및 내부 circleView 크기에 따름
            // 명시적으로 너비/높이 제약을 주고 싶다면 아래처럼
            circleContainer.snp.makeConstraints { make in
                make.height.equalTo(circleContainer.snp.width) // 정사각형 유지
            }
        }
    }
    // ✅ (수정) 동적 출석 데이터를 받아 UI를 채우는 함수
    private func populateStampSection(with attendances: [UserAttendance]) {
        circlesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        daysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // 요일 레이블도 다시 그림
        
        let dayNames = ["월", "화", "수", "목", "금", "토", "일"]
        for dayName in dayNames {
            let label = UILabel()
            label.text = dayName
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .darkGray
            label.textAlignment = .center
            daysStackView.addArrangedSubview(label)
        }
        
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let attendedDates = Set(attendances.map { $0.attendedDate })
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
            let dateString = dateFormatter.string(from: date)
            let isCompleted = attendedDates.contains(dateString)
            let circleView = createDayCircleView(isCompleted: isCompleted)
            circlesStackView.addArrangedSubview(circleView)
        }
    }
    
    private func createDayCircleView(isCompleted: Bool) -> UIView {
        let circleView = UIView() // 컨테이너 대신 직접 원 뷰 사용
        circleView.layer.borderWidth = 1.5
        circleView.layer.borderColor = UIColor.systemGray3.cgColor
        
        // layoutIfNeeded() 이후에 cornerRadius를 설정하거나,
        // viewDidLayoutSubviews에서 설정하는 것이 더 정확할 수 있습니다.
        // 여기서는 circlesStackView의 높이가 고정되어 있으므로, 예상 크기로 설정합니다.
        // 또는, 이 뷰의 layoutSubviews에서 bounds를 사용해 설정합니다.
        // 이 예제에서는 populateStampSection 호출 시점에 크기가 아직 미정이므로,
        // Dispatch.main.async를 사용하거나, 고정 크기를 가정합니다.
        // 가장 좋은 방법은 UIView 서브클래스를 만들어 layoutSubviews에서 cornerRadius를 업데이트하는 것입니다.
        // 여기서는 일단 Dispatch.main.async를 유지합니다.
        DispatchQueue.main.async {
            circleView.layer.cornerRadius = circleView.bounds.width / 2
            circleView.clipsToBounds = true
        }
        
        if isCompleted {
            circleView.backgroundColor = UIColor(named: "PrimaryPeach")
            circleView.layer.borderColor = UIColor.black.cgColor
            
            let completedLabel = UILabel()
            completedLabel.text = "완료"
            completedLabel.font = .systemFont(ofSize: 10, weight: .bold)
            completedLabel.textColor = .black
            completedLabel.textAlignment = .center
            
            circleView.addSubview(completedLabel)
            completedLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        return circleView
    }
    
    private func populateAssignmentButtons() {
        assignmentButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // 기존 뷰 제거
        
        let assignments = [
            ("돈초크 라멘 육수 우려내기 - 첫 복습", true),
            ("반숙란 만들기 - 심화 과정", true),
            ("꼬들꼬들한 라멘 면 만들기 - 중급 과정", true)
        ]
        
        for (title, isPrimary) in assignments {
            let button = createAssignmentButton(title: title, isPrimary: isPrimary)
            assignmentButtonsStackView.addArrangedSubview(button)
            // StackView의 distribution이 .fillEqually이므로 높이는 자동으로 같아집니다.
            // 만약 각 버튼의 높이를 다르게 하고 싶다면 distribution을 .fill 등으로 변경하고
            // 각 버튼에 높이 제약을 주어야 합니다.
            // 여기서는 fillEqually를 사용하므로 개별 높이 제약은 불필요합니다.
            // 다만, 전체 StackView의 높이가 충분해야 합니다.
        }
    }
    
    private func createAssignmentButton(title: String, isPrimary: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.contentHorizontalAlignment = .center
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        
        if isPrimary {
            button.backgroundColor = UIColor(named: "PrimaryPeach")
            button.setTitleColor(.black, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        return button
    }
    
    // MARK: - Data Loading
    private func loadRepeatLearnData() {
        // 로딩 시작: 인디케이터를 보여주고, 기존 컨텐츠를 숨길 수 있습니다.
        activityIndicator.startAnimating()
        // contentView.isHidden = true // 또는 alpha 값을 조절
        
        Task {
            do {
                // RepeatLearnService를 통해 데이터를 비동기적으로 가져옵니다.
                let loadedData = try await RepeatLearnService.shared.fetchAndGenerateRepeatLearnData()
                
                // 메인 스레드에서 UI 업데이트를 수행합니다.
                await MainActor.run {
                    // 가져온 데이터로 프로퍼티를 업데이트합니다.
                    self.repeatLearnDataSet = loadedData
                    
                    // 데이터 로딩이 완료되었으므로 UI를 업데이트합니다.
                    self.updateUIWithLoadedData()
                    
                    // 로딩 종료: 인디케이터를 숨기고, 컨텐츠를 다시 보여줍니다.
                    self.activityIndicator.stopAnimating()
                    // self.contentView.isHidden = false
                }
            } catch {
                // 에러 처리
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    print("Failed to load repeat learn data: \(error)")
                    // 사용자에게 에러를 알리는 Alert 등을 표시할 수 있습니다.
                    showErrorAlert(message: "데이터를 불러오는 데 실패했습니다.")
                }
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        activityIndicator.startAnimating()
        contentView.alpha = 0.3 // 로딩 중 UI를 흐리게 표시
        print("[Log] 🔄 반복 학습 데이터 로딩을 시작합니다...")
        Task {
            do {
                // 여러 데이터를 병렬로 가져옴
                async let learnData = RepeatLearnService.shared.fetchAndGenerateRepeatLearnData()
                
                // 이번 주의 시작과 끝 날짜 계산
                let calendar = Calendar.current
                let today = Date()
                guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
                      let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
                    throw NSError(domain: "DateError", code: 0)
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                // 현재 로그인한 사용자의 이번 주 출석 기록을 가져옴
                guard let userId = SupabaseDataManager.shared.getCurrentAuthenticatedUser()?.userId else {
                    throw LoginManagerError.userNotFound
                }
                async let attendance = SupabaseDataManager.shared.fetchUserAttendances(
                    userId: userId,
                    from: dateFormatter.string(from: startOfWeek),
                    to: dateFormatter.string(from: endOfWeek)
                )
                
                // 모든 데이터가 로드될 때까지 기다림
                let (loadedLearnData, loadedAttendance) = try await (learnData, attendance)
                
                
                print("[Log] ✅ 데이터 로딩 성공. \(loadedLearnData.count)개의 학습 데이터, \(loadedAttendance.count)개의 출석 기록을 가져왔습니다.")
                print("[Log] - 학습 데이터: \(loadedLearnData.map { $0.lectureTitle })")
                print("[Log] - 출석 날짜: \(loadedAttendance.map { $0.attendedDate })")
                
                await MainActor.run {
                    self.repeatLearnDataSet = loadedLearnData
                    self.attendanceData = loadedAttendance
                    self.updateUIWithLoadedData()
                }
            } catch {
                await MainActor.run {
                    showErrorAlert(message: "데이터를 불러오는 데 실패했습니다: \(error.localizedDescription)")
                }
            }
            // 성공/실패 여부와 관계없이 로딩 UI 해제
            await MainActor.run {
                self.activityIndicator.stopAnimating()
                self.contentView.alpha = 1.0
            }
        }
    }
    private func updateUIWithLoadedData() {
        // 1. 가장 첫 번째 강의를 대표 강의로 선정 (데이터가 있을 경우)
        guard let primaryLecture = repeatLearnDataSet.first else {
            // 데이터가 없을 경우의 UI 처리 (예: "진행 중인 강의가 없습니다" 메시지 표시)
            lessonTitleLabel.text = "진행 중인 강의 없음"
            lessonSubtitleLabel.text = "새로운 강의를 시작해보세요!"
            mainImageView.image = UIImage(systemName: "photo.artframe") // 기본 이미지
            assignmentButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            return
        }
        
        // 2. 대표 강의 정보로 UI 업데이트 (Section 3)
        lessonTitleLabel.text = primaryLecture.lectureTitle
        lessonSubtitleLabel.text = primaryLecture.lectureDescription
        // mainImageView는 비동기로 이미지를 로드해야 할 수 있습니다. (URL -> UIImage)
        // Kingfisher나 SDWebImage 같은 라이브러리를 사용하거나, 직접 구현합니다.
        loadMainImage(from: primaryLecture.lectureURL) // 예시 함수
        
        // 3. 출석 정보 업데이트 (Section 2)
        // 이 부분은 별도의 출석 데이터 로직이 필요합니다. 여기서는 일단 기존 로직을 유지합니다.
        populateStampSection() // 실제로는 UserAttendance 데이터를 기반으로 업데이트해야 함
        
        // 4. 복습 과제 버튼 목록 업데이트 (Section 4)
        populateAssignmentButtonsWithData()
    }
    
    // URL에서 이미지를 비동기적으로 로드하는 헬퍼 함수 (간단한 예시)
    private func loadMainImage(from url: URL) {
        Task {
            // URLSession을 사용한 간단한 비동기 이미지 로딩
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.mainImageView.image = image
                }
            }
        }
    }
    
    // ✅ "VOD 복습 과제" 버튼(트리거 버튼)을 생성하는 함수
        private func populateAssignmentButtonsWithData() {
            assignmentButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            let firstThreeLectures = repeatLearnDataSet.prefix(3)
            
            for (index, data) in firstThreeLectures.enumerated() {
                let isPrimary = (index == 0)
                let button = createAssignmentButton(title: data.lectureTitle, isPrimary: isPrimary)
                
                button.tag = index
                button.addTarget(self, action: #selector(assignmentButtonTapped(_:)), for: .touchUpInside)
                
                assignmentButtonsStackView.addArrangedSubview(button)
            }
        }
    
    // 과제 버튼 클릭 시 호출될 메서드
    @objc private func assignmentButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < repeatLearnDataSet.count else { return }
        
        let selectedData = repeatLearnDataSet[index]
        // ✅ (수정) 코디네이터에게 현재 선택된 데이터와 "전체 목록"을 함께 전달합니다.
        coordinator?.showDetail(
            currentPlayingData: selectedData,
            allData: self.repeatLearnDataSet
        )
    }
    
    // 에러 알림 헬퍼 함수
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

//
//#Preview {
//    RepetitiveLearningViewController()
//}
