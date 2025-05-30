import UIKit
import SnapKit

class RepetitiveLearningViewController: UIViewController {
    weak var coordinator: RepeatitiveStudyMainCoordinator?
    
    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()


    // --- Section 2: 매일매일 성장 스탬프 ---
    private let stampSectionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let dailyStampTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "매일매일 성장 스탬프"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()

    private let circlesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private let attendanceCompleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("출석체크 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()

    // --- Section 3: 이미지 및 정보 ---
    private let mainImageViewBaseView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        // "ramen_image"라는 이름의 이미지를 Assets.xcassets에 추가해야 합니다.
        imageView.image = UIImage(named: "sample_img")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let imageOverlayView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 20
        // 아래쪽 모서리만 둥글게 하기 위해 BaseView에서 clipsToBounds를 사용하고
        // OverlayView는 BaseView의 하단에 맞춰서 해당 모양을 따르게 합니다.
        // OverlayView 자체의 maskedCorners는 BaseView의 clipsToBounds와 함께 사용될 때
        // 의도치 않은 결과를 낼 수 있으므로, 여기서는 BaseView의 모양을 따르도록 단순화합니다.
        // 만약 OverlayView가 BaseView를 벗어나 독립적인 모양을 가져야 한다면 maskedCorners가 필요합니다.
        // 현재 구조에서는 BaseView에 맞춰지므로 maskedCorners는 생략 가능합니다.
        // view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true // 내부 컨텐츠가 넘치지 않도록
        return view
    }()

    private let lessonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "시미켄 선생님의 라멘 수업"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let lessonSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "집에서 만들어 보는 텐가라멘"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true

        let iconImageView = UIImageView(image: UIImage(systemName: "hand.thumbsup.fill"))
        iconImageView.tintColor = .black
        let countLabel = UILabel()
        countLabel.text = "6,974"
        countLabel.font = .systemFont(ofSize: 13, weight: .medium)
        countLabel.textColor = .black

        let stackView = UIStackView(arrangedSubviews: [iconImageView, countLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false

        button.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        return button
    }()

    private let heartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .red
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    // --- Section 4: 오늘의 VOD 복습 과제 ---
    private let vodReviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 VOD 복습 과제"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let assignmentButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually // 버튼 높이가 동일해짐
        return stackView
    }()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        setupUI()
        setupLayout()
        populateStampSection()
        populateAssignmentButtons()
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
        
        mainImageViewBaseView.addSubview(heartButton) // 하트 버튼은 BaseView에 추가

        // Section 4
        contentView.addSubview(vodReviewTitleLabel)
        contentView.addSubview(assignmentButtonsStackView)
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
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
            make.top.equalTo(dailyStampTitleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        circlesStackView.snp.makeConstraints { make in
            make.top.equalTo(daysStackView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }

        attendanceCompleteButton.snp.makeConstraints { make in
            make.top.equalTo(circlesStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20) // stampSectionContainerView의 바닥
        }

        // Section 3
        mainImageViewBaseView.snp.makeConstraints { make in
            make.top.equalTo(stampSectionContainerView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(mainImageViewBaseView.snp.width).multipliedBy(0.8)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageOverlayView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview() // BaseView의 하단에 맞춤
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
        
        heartButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(36)
        }

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
            circleView.backgroundColor = .black
            circleView.layer.borderColor = UIColor.black.cgColor

            let completedLabel = UILabel()
            completedLabel.text = "완료"
            completedLabel.font = .systemFont(ofSize: 10, weight: .bold)
            completedLabel.textColor = .white
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
            ("돈초크 라멘 육수 우려내기 시청하기 - 첫 복습", true),
            ("반숙란 만들기, 완숙 만들면 심익현씨한테 혼남 - 심화 과정", false),
            ("라멘 면 만들기 야들야들 꼬들꼬들 - 중급 과정", false)
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
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // 텍스트 패딩

        if isPrimary {
            button.backgroundColor = .black
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray4.cgColor
        }
        // 버튼 높이 제약 (StackView에서 fillEqually를 사용하지 않을 경우 필요)
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return button
    }
}

#Preview {
    RepetitiveLearningViewController()
}
