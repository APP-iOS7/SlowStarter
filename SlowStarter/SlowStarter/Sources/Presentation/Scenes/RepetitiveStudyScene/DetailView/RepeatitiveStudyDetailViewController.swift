//
//  RepeatitiveStudyDetailViewController.swift
//  SlowStarter
//
//  Created by jdios on 5/20/25.
//

import UIKit
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
                                                                      lectureURL: bigbunny,
                                                                      assignments: Assignment.sampleAssignments) // 현재 재생되는 강의데이터
    private var repeatLearnListCellDataset: [RepeatLearnData] // 강의리스트 생성용,
    
    private func updateData(with cellData: RepeatLearnData) {
        self.currentRepeatLearn = cellData
    }
    
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
        // button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let weeklyUpdateAnnouncingLabel: UILabel = {
        let label = UILabel()
        label.text = "1주일마다 초기화 됩니다!"
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let repeatLearnTableView: UITableView = { // 변수명 일관성 있게 변경
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(RepeatitiveTableViewCell.self, forCellReuseIdentifier: RepeatitiveTableViewCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60 // 셀의 예상 높이
        return tableView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initializer
    
    init(currentPlayingData: RepeatLearnData) {
            // 1단계: 현재 클래스의 저장 프로퍼티 초기화
            self.currentRepeatLearn = currentPlayingData // 외부에서 주입받은 데이터로 초기화
            self.repeatLearnListCellDataset = []       // 빈 배열로 초기화 (또는 다른 기본값)
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
        
        setupVideoPlayer()
        setupUI()
        
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
    
    private func updateVideoURL(url: URL) {
        videoPlayerViewController.updateVideo(with: url)
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

extension RepeatLearnDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatLearnListCellDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepeatitiveTableViewCell.identifier, for: indexPath) as? RepeatitiveTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        return cell
    }
    
    
}
