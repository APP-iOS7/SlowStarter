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
        button.backgroundColor = UIColor(named: "PrimaryPeach")
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
       
    // ✅ 과제 제출 완료 후 호출되는 콜백 처리 함수
    private func handleAssignmentsUpdate(_ updatedAssignments: [Assignment]) {
        // 1. 현재 강의 데이터의 과제 목록을 업데이트합니다.
        self.currentRepeatLearn.assignments = updatedAssignments
        
        // 2. 전체 데이터 소스에서 현재 강의를 찾아 과제 목록과 '인증 상태'를 업데이트합니다.
        guard let index = repeatLearnListCellDataset.firstIndex(where: { $0.vodId == self.currentRepeatLearn.vodId }) else {
            // 데이터 소스에서 해당 강의를 찾지 못하면 아무것도 하지 않음
            return
        }
        
        // 데이터 모델 업데이트
        repeatLearnListCellDataset[index].assignments = updatedAssignments
        repeatLearnListCellDataset[index].dailyAssignmentChecked = true
        
        // 현재 재생 중인 데이터도 동기화
        if currentRepeatLearn.vodId == repeatLearnListCellDataset[index].vodId {
            self.currentRepeatLearn.dailyAssignmentChecked = true
        }
        
        print("과제 업데이트 완료. '\(self.currentRepeatLearn.lectureTitle)' 강의가 인증 가능한 상태로 변경되었습니다.")
        
        // --- ✅ UI 업데이트 로직 수정 ---
        
        // 3. 업데이트가 필요한 셀의 IndexPath를 생성합니다.
        let indexPathToUpdate = IndexPath(row: index, section: 0)
        
        // 4. 해당 IndexPath에 해당하는 셀이 현재 화면에 '보이는' 경우에만 직접 업데이트합니다.
        //    만약 셀이 화면 밖에 있어 보이지 않는다면, cellForRow(at:)은 nil을 반환합니다.
        //    하지만 괜찮습니다. 그런 셀은 나중에 스크롤되어 화면에 나타날 때,
        //    tableView(_:cellForRowAt:) 메서드가 호출되면서 업데이트된 데이터로 그려지기 때문입니다.
        if let cell = repeatLearnTableView.cellForRow(at: indexPathToUpdate) as? RepeatitiveTableViewCell {
            
            // ✅ [핵심] 해당 셀의 configure 메서드를 직접 호출하여 UI를 새로고침합니다.
            print("화면에 보이는 셀(\(indexPathToUpdate.row))을 직접 업데이트합니다.")
            let updatedData = repeatLearnListCellDataset[index]
            cell.configure(with: updatedData)
            
        } else {
            // ✅ 화면에 보이지 않는 셀은 나중에 자동으로 그려지므로, 여기서는 아무것도 할 필요가 없습니다.
            print("업데이트할 셀(\(indexPathToUpdate.row))이 현재 화면에 보이지 않습니다. 스크롤 시 업데이트됩니다.")
        }
    }

    @objc private func submitButtonTapped() {
        let submittedVC = SubmittedAssignmentViewController()
            
            // 1. 현재 강의의 과제 데이터를 전달하여 초기화
            submittedVC.updateData(with: self.currentRepeatLearn.assignments)
            
            // 2. 콜백 함수 설정
            submittedVC.onDataUpdated = { [weak self] updatedAssignments in
                self?.handleAssignmentsUpdate(updatedAssignments)
            }
                
            // 3. ✅ UINavigationController로 감싸서 present
            let navigationController = UINavigationController(rootViewController: submittedVC)
            // iOS 13 이상에서는 기본값이 .automatic이라 카드 형태로 뜰 수 있으므로 .fullScreen으로 설정
            navigationController.modalPresentationStyle = .fullScreen
            
            present(navigationController, animated: true)
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
    
    // ✅ 포인트 버튼이 눌렸을 때의 상태 변화 로직
    func repeatitiveCell(_ cell: RepeatitiveTableViewCell, didTapPointButtonAtIndex index: Int) {
        guard let indexPath = repeatLearnTableView.indexPath(for: cell) else { return }
        
        let targetIndex = indexPath.row
        
        // --- 1. 데이터 모델 업데이트 ---
        
        // weeklyProgress를 1 증가시킵니다. (예: 0 -> 1)
        repeatLearnListCellDataset[targetIndex].weeklyProgress += 1
        
        // '인증 가능' 상태였던 것을 다시 '인증 대기' 상태로 되돌립니다.
        // (다음 날의 과제를 기다리는 상태)
        repeatLearnListCellDataset[targetIndex].dailyAssignmentChecked = false
        
        print("'\(repeatLearnListCellDataset[targetIndex].lectureTitle)' 강의의 진행도가 \(repeatLearnListCellDataset[targetIndex].weeklyProgress)로 업데이트되었습니다.")
        
        // --- 2. 현재 재생 중인 데이터도 동기화 ---
        if repeatLearnListCellDataset[targetIndex].vodId == self.currentRepeatLearn.vodId {
            self.currentRepeatLearn = repeatLearnListCellDataset[targetIndex]
        }
        
        // --- 3. UI 새로고침 ---
        // 전체 테이블 뷰를 리로드하여 모든 셀의 버튼 상태
        // (방금 완료된 셀은 '상태 1'로, 다음 셀은 '상태 2'로)를 업데이트합니다.
        repeatLearnTableView.reloadData()
        
        // (서버 저장 로직은 viewWillDisappear에서 일괄 처리되므로 여기서는 호출하지 않습니다)
    }
}
//
//
//#Preview {
//    RepeatLearnDetailViewController(currentPlayingData: RepeatLearnData.sample)
//}
