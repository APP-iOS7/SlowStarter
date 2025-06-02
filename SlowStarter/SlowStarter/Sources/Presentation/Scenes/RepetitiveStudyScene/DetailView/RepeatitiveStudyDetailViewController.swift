//
//  RepeatitiveStudyDetailViewController.swift
//  SlowStarter
//
//  Created by jdios on 5/20/25.
//

import UIKit
import SnapKit
/*
 역할
 1. 강의의 모든 영상 리스트업 해줘야함
 모든 강의정보를 가지고 있어야함
 그 정보는 셀 데이터에 있어야 하고
 선택시 업데이트 되어야함
 2. 최상단에는 비디오 컨트롤러가 존재하고 이 컨트롤러는 특정 함수를 통해 url을 전달받아 영상을 준비시킴
 이 영상데이터는 셀을 선택할 때 업데이트 됨
 
 3. 타이틀, 설명이 바뀌어야함
 
 4. 현재 선택된 데이터 업데이트
 
 5. 초기데이터 전달 방식 -> 주입
 
 6.
 
 */

class RepeatLearnDetailViewController: UIViewController {
    
    // MARK: LectureData
    private var currentRepeatLearn: RepeatLearnData = RepeatLearnData(lectureTitle: "감자 썰기",
                                                                      lectureDescription: "기타 정보/기타 정보/기타 정보/ 영상길이",
                                                                      lectureURL: bigbunny, weeklyProgress: 0,
                                                                      assignments: Assignment.sampleAssignments) // 현재 재생되는 강의데이터
    private var repeatLearnListCellDataset: [RepeatLearnData] // 강의리스트 생성용,
    // MARK: - 비디오 컨트롤러
    private var videoPlayerViewController: VideoPlayerViewController = VideoPlayerViewController()
   
    
    
    // MARK: - UI Properties
    private let lectureTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let lectureDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    private let submitAssignmentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("과제 제출하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0) // 녹색
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addAction(UIAction(handler: { _ in
            print("dfs")
        }), for: .touchUpInside)
        return button
    }()
    
    private func submitButtonTapped() {
        present(SubmittedAssignmentViewController(), animated: true)
    }
    
    private let weeklyUpdateAnnouncingLabel: UILabel = {
        let label = UILabel()
        label.text = "1주일마다 초기화 됩니다!"
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let repeatLearnTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(RepeatitiveTableViewCell.self, forCellReuseIdentifier: RepeatitiveTableViewCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70 // 셀의 예상 높이
        return tableView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initializer
    
    init(currentPlayingData: RepeatLearnData) {
            // 1단계: 현재 클래스의 저장 프로퍼티 초기화
            self.currentRepeatLearn = currentPlayingData // 외부에서 주입받은 데이터로 초기화
        self.repeatLearnListCellDataset = RepeatLearnData.sampleDataset       // 빈 배열로 초기화 (또는 다른 기본값)
            // self.videoPlayerViewController 등 다른 let 프로퍼티는 선언 시점에 초기화됨
            
            // 2단계: 부모 클래스의 지정 초기화자 호출
            super.init(nibName: nil, bundle: nil)
        }
    
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        repeatLearnTableView.delegate = self
        repeatLearnTableView.dataSource = self
        
        // 초기 화면 세팅
    
        setupVideoPlayer()
        setupUI()
        setupLayOut()
        
        self.updateData(with: self.currentRepeatLearn)
        
    }
    
    
    
    // MARK: - Video
    private func setupVideoPlayer() {
        addChild(videoPlayerViewController)
        view.addSubview(videoPlayerViewController.view)
        videoPlayerViewController.didMove(toParent: self)
        
        videoPlayerViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0) // 16:9 비율
        }
    }
    
    private func updateData(with cellData: RepeatLearnData) {
        self.currentRepeatLearn = cellData
        self.lectureTitleLabel.text = cellData.lectureTitle
        self.lectureDescriptionLabel.text = cellData.lectureDescription
        self.videoPlayerViewController.updateVideo(with: cellData.lectureURL)
    }
    
    private func setupUI() {
        view.addSubview(lectureTitleLabel)
        view.addSubview(lectureDescriptionLabel)
        view.addSubview(submitAssignmentButton)
        view.addSubview(weeklyUpdateAnnouncingLabel)
        view.addSubview(repeatLearnTableView)
        
    }
    
    private func setupLayOut() {
        lectureTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(videoPlayerViewController.view.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        lectureDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(lectureTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(lectureTitleLabel)
        }
        
        submitAssignmentButton.snp.makeConstraints { make in
            make.top.equalTo(lectureDescriptionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        weeklyUpdateAnnouncingLabel.snp.makeConstraints { make in
            make.top.equalTo(submitAssignmentButton.snp.bottom).offset(20)
            make.trailing.equalToSuperview().inset(16)
        }
        
        repeatLearnTableView.snp.makeConstraints { make in
            make.top.equalTo(weeklyUpdateAnnouncingLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension RepeatLearnDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatLearnListCellDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepeatitiveTableViewCell.identifier, for: indexPath) as? RepeatitiveTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        let data = repeatLearnListCellDataset[indexPath.row]
        cell.configure(with: data)
        return cell
    }
}
extension RepeatLearnDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextData = repeatLearnListCellDataset[indexPath.row]
        
        self.currentRepeatLearn = nextData
        self.updateData(with: currentRepeatLearn)
    }
}


#Preview {
    // 실제 샘플 데이터를 사용하여 ViewController 인스턴스화
    // RepeatLearnData.sample은 이미 정의되어 있음 (제공해주신 코드 기준)
    // 전체 강의 목록도 샘플 데이터로 구성
    let allLecturesForPreview = [
        RepeatLearnData.sample, // "예시 강의명"
        RepeatLearnData(lectureTitle: "코끼리의 꿈 (Elephants Dream)",
                        lectureDescription: "단편 애니메이션 영화",
                        lectureURL: elephantsDream, weeklyProgress: 2, // VideoURLSamples.swift 에서 정의
                        assignments: []), // 이 강의에 대한 과제가 없다면 빈 배열
        RepeatLearnData(lectureTitle: "더 큰 불꽃을 위해 (For Bigger Blazes)",
                        lectureDescription: "단편 영화",
                        lectureURL: forBiggerBlazzes, weeklyProgress: 0, // VideoURLSamples.swift 에서 정의
                        assignments: Assignment.sampleAssignments.suffix(10).map { $0 }) // 마지막 2개 과제만 할당 (예시)
    ]

    // currentPlayingData는 목록의 첫 번째 항목 또는 특정 항목으로 설정
    let currentPlayingForPreview = RepeatLearnData.sample

    // 수정된 초기화 메서드에 맞게 호출
    let viewController = RepeatLearnDetailViewController(
        currentPlayingData: currentPlayingForPreview
    )
    
    // 네비게이션 컨트롤러에 임베드하여 타이틀 바 등을 보고 싶다면:
    // return UINavigationController(rootViewController: viewController)
    
    viewController
}
