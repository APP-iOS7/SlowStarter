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
 
 */

class RepeatLearnDetailViewController: UIViewController {
    
    let supabaseManager = SupabaseDataManager.shared
    
    // ✅ (추가) 서버와 동기화를 위해 원본 과제 목록을 저장해둡니다.
       private var originalAssignments: [UserAssignment] = []
    

    // MARK: LectureData
    private var currentRepeatLearn: RepeatLearnData
    private var repeatLearnListCellDataset: [RepeatLearnData] // 강의리스트 생성용,
    // MARK: - 비디오 컨트롤러
    private var videoPlayerViewController: VideoPlayerViewController = VideoPlayerViewController()
    
   
    
    // MARK: test 용
    //    var currentPlayingData: RepeatLearnData?
    
    
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
    
    // submitAssignmentButton을 lazy var로 변경
    private lazy var submitAssignmentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("과제 제출하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0) // 녹색
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        // 'self' (현재 인스턴스)를 target으로 설정
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    

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
    
    // MARK: - Initializer
       init(currentPlayingData: RepeatLearnData, allData: [RepeatLearnData]) {
           self.currentRepeatLearn = currentPlayingData
           self.repeatLearnListCellDataset = allData
           super.init(nibName: nil, bundle: nil)
       }
    required init?(coder: NSCoder? = nil) {
        fatalError("init(coder:) has not been implemented")
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
        
        self.updateUI(with: self.currentRepeatLearn)
        
    }
    
    // MARK: - Data
//    private func fetchRepeatLearnDataList() {
//        SupabaseDataManager.shared.fetchuser
//    }
    
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
    // ✅ (구현) 서버에 변경사항을 저장하는 로직
       private func saveChangesToServer() {
           Task {
               do {
                   // 1. 과제 변경사항 동기화
                   // 현재 UI에 표시된 과제 목록(currentRepeatLearn.assignments)을 서버와 동기화합니다.
                   try await RepeatLearnService.shared.syncAssignments(
                       for: currentRepeatLearn.vodId,
                       with: currentRepeatLearn.assignments
                   )
                   
                   // 2. 학습 진도(Progress) 동기화
                   // 전체 강의 목록의 진행도 정보를 서버에 업데이트합니다.
                   try await RepeatLearnService.shared.updateUserProgress(with: self.repeatLearnListCellDataset)
                   
                   print("모든 변경사항이 성공적으로 저장되었습니다.")
                   
               } catch {
                   // 에러 처리 (예: 사용자에게 알림 표시)
                   print("서버에 변경사항을 저장하는 중 오류 발생: \(error)")
               }
           }
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
    // MARK: - Data & UI Update
       private func updateUI(with data: RepeatLearnData) {
           self.currentRepeatLearn = data
           self.lectureTitleLabel.text = data.lectureTitle
           self.lectureDescriptionLabel.text = data.lectureDescription
           self.videoPlayerViewController.updateVideo(with: data.lectureURL)
           // 테이블 뷰도 리로드하여 현재 선택된 강의에 대한 시각적 피드백(예: 배경색 변경)을 줄 수 있습니다.
           // self.repeatLearnTableView.reloadData()
       }
       
       // [요청사항 2] 과제 업데이트를 처리하는 메서드
       private func handleAssignmentsUpdate(_ updatedAssignments: [Assignment]) {
           // 1. 현재 강의 데이터의 과제 목록 업데이트
           self.currentRepeatLearn.assignments = updatedAssignments
           
           // 2. 전체 강의 목록(데이터 소스)에서 동일한 강의를 찾아 과제 목록 업데이트
           if let index = repeatLearnListCellDataset.firstIndex(where: { $0.lectureTitle == self.currentRepeatLearn.lectureTitle }) {
               self.repeatLearnListCellDataset[index].assignments = updatedAssignments
               print("데이터 소스가 업데이트 되었습니다: \(self.repeatLearnListCellDataset[index].lectureTitle)")
           }
       }
    @objc private func submitButtonTapped() {
            let submittedVC = SubmittedAssignmentViewController()
            
            // SubmittedVC가 닫힐 때 호출될 콜백 함수 설정
            submittedVC.onDataUpdated = { [weak self] updatedAssignments in
                self?.handleAssignmentsUpdate(updatedAssignments)
            }
            
            // 현재 강의의 과제 데이터를 전달하여 SubmittedVC 초기화
            submittedVC.updateData(with: self.currentRepeatLearn.assignments)
            
            present(submittedVC, animated: true)
        }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RepeatLearnDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatLearnListCellDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepeatitiveTableViewCell.identifier, for: indexPath) as? RepeatitiveTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        let data = repeatLearnListCellDataset[indexPath.row]
        cell.configure(with: data)
        // 셀의 delegate를 self(ViewController)로 지정
        cell.delegate = self
        // cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextData = repeatLearnListCellDataset[indexPath.row]
        
        if nextData.lectureTitle != self.currentRepeatLearn.lectureTitle {
            updateUI(with: nextData)
        }
    }
}

// MARK: - RepeatitiveTableViewCellDelegate
extension RepeatLearnDetailViewController: RepeatitiveTableViewCellDelegate {
    // [요청사항 4, 5, 6] 셀의 포인트 버튼 탭 시 호출되는 메서드
    func repeatitiveCell(_ cell: RepeatitiveTableViewCell, didTapPointButtonAtIndex index: Int) {
        guard let indexPath = repeatLearnTableView.indexPath(for: cell) else { return }
        
        // 1. 데이터 소스(repeatLearnListCellDataset)를 직접 수정합니다.
        let newProgress = index + 1
        
        // 이미 더 높은 단계의 progress가 완료되었거나 같은 단계를 또 누르면 무시
        guard repeatLearnListCellDataset[indexPath.row].weeklyProgress < newProgress else {
            return
        }
        
        // 데이터 모델 업데이트
        repeatLearnListCellDataset[indexPath.row].weeklyProgress = newProgress
        
        // 만약 현재 재생중인 강의와 같은 셀의 버튼을 눌렀다면, currentRepeatLearn도 업데이트
        if repeatLearnListCellDataset[indexPath.row].lectureTitle == self.currentRepeatLearn.lectureTitle {
            self.currentRepeatLearn.weeklyProgress = newProgress
        }
        
        // 2. 변경된 데이터로 해당 셀의 UI만 새로고침합니다.
        repeatLearnTableView.reloadRows(at: [indexPath], with: .fade)
    }
}

//
//
//#Preview {
//    RepeatLearnDetailViewController(currentPlayingData: RepeatLearnData.sample)
//}
