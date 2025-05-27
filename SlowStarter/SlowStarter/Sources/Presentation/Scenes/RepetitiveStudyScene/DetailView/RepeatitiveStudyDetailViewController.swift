//
//  RepeatitiveStudyDetailViewController.swift
//  SlowStarter
//
//  Created by jdios on 5/20/25.
//

import UIKit

class RepeatitiveStudyDetailViewController: UIViewController {
    
    // MARK: ViewModel
    private var viewModel: RepeatitiveStudyDetailViewModel!
    
    private let lectureTitleLabel: UILabel = UILabel()
    private let lectureDescriptionLabel: UILabel = UILabel()
    private let submitButton: UIButton = UIButton()
    private let infomationLabel: UILabel = UILabel()
    private var videoPlayerViewController = VideoPlayerViewController()
    private let repeatitiveStudyTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        repeatitiveStudyTableView.delegate = self
        repeatitiveStudyTableView.dataSource = self
        
        setupVideoPlayer()
        setupUI()
        
    }
    // MARK: Video
    private func setupVideoPlayer() {
        addChild(videoPlayerViewController)
        
        videoPlayerViewController.view.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(150)
        }
    }
    private func updateVideoURL(url: URL) {
        // 비디오 url 업데이트
        // 비디오 로딩
        // 비디오 재생대기
        // 비디오 썸네일 업데이트
        //
      
    }
    private func setupUI() {
        lectureTitleLabel.text = viewModel.playingLectureData?.lectureTitle
        lectureTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(lectureTitleLabel)

        lectureTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(videoPlayerViewController.view.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        lectureDescriptionLabel.text = viewModel.playingLectureData?.description
        lectureDescriptionLabel.numberOfLines = 0
        lectureDescriptionLabel.font = .systemFont(ofSize: 14)
        view.addSubview(lectureDescriptionLabel)
        
        lectureDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(lectureTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        
        
        let weeklyUpdateAnnouncingLabel: UILabel = {
            let label = UILabel()
            label.text = "1주일마다 초기화 됩니다!"
            label.tintColor = .systemGray
            label.font = .systemFont(ofSize: 12)
            return label
        }()
        view.addSubview(weeklyUpdateAnnouncingLabel)
        
        view.addSubview(repeatitiveStudyTableView)
        
    }
    
}

extension RepeatitiveStudyDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repeatitiveStudyListCellDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepeatitiveTableViewCell.identifier, for: indexPath) as? RepeatitiveTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        return cell
    }
    
    
}
