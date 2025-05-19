//
//  BasicVideoPlayerViewController.swift
//  SlowStarter
//
//  Created by 이재용 on 5/14/25.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit

class BasicVideoPlayerViewController: UIViewController {
    
    // Optional로 선언하여 nil 가능성을 명시하고 안전하게 처리합니다.
    private var inlinePlayPauseButton: UIButton! // 이름 변경 제안
    private var fullScreenButton: UIButton!
    
    private var playerBaseView: UIView = UIView()
    
    // Optional로 선언
    private var embeddedPlayerViewController: AVPlayerViewController?
    private var player: AVPlayer? // Optional로 선언
    
    private var videoURL: URL? // Optional로 선언, 이름 변경 제안
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Basic Video Player"
        
        // MARK: - 무음모드 소리재생
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Error in Config Audio Session: \(error.localizedDescription)")
        }
        
        
        // UI 설정 전에 playerBaseView를 추가
        view.addSubview(playerBaseView)
        
        // UI 설정
        setupUI()
        
        // 플레이어 URL 설정 및 플레이어 인스턴스 생성
        setVideoURLAndPlayer()
        
        // 임베드된 플레이어 뷰 컨트롤러 설정 (플레이어 인스턴스 생성 후에 호출)
        setupEmbeddedPlayerViewController()
        
        // 플레이어 준비 상태에 따라 UI 업데이트 (예: 버튼 활성화/비활성화)
        updateUIForPlayerState()
    }
    
    private func configNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold)
        ]
    }
    
    // 비디오 URL 설정 및 AVPlayer 인스턴스 생성
    private func setVideoURLAndPlayer() {
        let urlString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        videoURL = URL(string: urlString)
        
        guard let url = videoURL else {
            print("Error: Invalid video URL string: \(urlString)")
            // 유효하지 않은 URL일 경우 플레이어 생성 및 버튼 활성화 불가능
            player = nil
            return
        }
        
        // 유효한 URL이면 AVPlayer 인스턴스 생성
        player = AVPlayer(url: url)
        
        // 플레이어 준비 상태를 감지하여 UI 업데이트 등을 할 수 있습니다. (선택 사항)
        // 예: player?.currentItem?.addObserver(...)
    }
    
    // UI 설정 (버튼 및 playerBaseView 제약 설정)
    private func setupUI() {
        // playerBaseView 제약
        playerBaseView.backgroundColor = .lightGray // 확인을 위해 색상 변경
        
        playerBaseView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // safeArea 기준으로 변경
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        // FullScreen Button 제약
        fullScreenButton = UIButton(type: .system)
        fullScreenButton.setTitle("Play Fullscreen", for: .normal) // 제목 변경 제안
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false // SnapKit 사용 시 필수
        view.addSubview(fullScreenButton)
        
        fullScreenButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(playerBaseView.snp.bottom).offset(40) // playerBaseView 아래에 배치
        }
        fullScreenButton.addTarget(self, action: #selector(fullScreenPlayButtonTapped), for: .touchUpInside)
        
        // Inline Play/Pause Button 제약
        inlinePlayPauseButton = UIButton(type: .system)
        inlinePlayPauseButton.setTitle("Play", for: .normal) // 초기 제목
        inlinePlayPauseButton.translatesAutoresizingMaskIntoConstraints = false // SnapKit 사용 시 필수
        view.addSubview(inlinePlayPauseButton)
        
        inlinePlayPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(fullScreenButton.snp.bottom).offset(20) // FullScreenButton 아래에 배치
        }
        inlinePlayPauseButton.addTarget(self, action: #selector(tapInlinePlayPauseButton), for: .touchUpInside) // 메서드 이름 변경
    }
    
    // 임베드된 AVPlayerViewController 설정 및 playerBaseView에 추가
    private func setupEmbeddedPlayerViewController() {
        // 플레이어 인스턴스가 있어야만 임베드된 플레이어 설정 가능
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot setup embedded player.")
            return
        }
        
        embeddedPlayerViewController = AVPlayerViewController()
        embeddedPlayerViewController?.player = player // ★ 생성된 player 인스턴스를 할당 ★
        
        // View Controller Containment 절차
        if let embeddedVC = embeddedPlayerViewController {
            addChild(embeddedVC) // 1. 부모-자식 관계 시작
            
            embeddedVC.view.translatesAutoresizingMaskIntoConstraints = false // SnapKit 사용 시 필수
            playerBaseView.addSubview(embeddedVC.view) // 2. 자식 뷰를 컨테이너 뷰에 추가
            
            // 3. SnapKit으로 자식 뷰 제약 설정 (컨테이너 뷰에 꽉 채우기)
            embeddedVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview() // inset 없이 컨테이너 뷰에 딱 맞춤
            }
            
            embeddedVC.didMove(toParent: self) // 4. 부모-자식 관계 완료 알림
            
            // 임베드된 플레이어의 기본 컨트롤러 숨기기 (선택 사항)
            // embeddedVC.showsPlaybackControls = false
        }
    }
    
    // 플레이어 준비 상태에 따라 UI (주로 버튼) 상태 업데이트
    private func updateUIForPlayerState() {
        // player 인스턴스가 유효할 때만 버튼 활성화
        let isPlayerReady = (player != nil)
        fullScreenButton.isEnabled = isPlayerReady
        inlinePlayPauseButton.isEnabled = isPlayerReady
        
        // 초기 상태에서는 인라인 플레이어 숨기기 (선택 사항)
        // playerBaseView.isHidden = !isPlayerReady // 플레이어가 준비되면 보이게
    }
    
    // 전체 화면 재생 버튼 탭 액션
    @objc private func fullScreenPlayButtonTapped() {
        print("Full screen play button tapped!")
        
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot play full screen.")
            return
        }
        
        // 새로운 AVPlayerViewController 인스턴스 생성 및 현재 player 할당
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = player
        
        // 모달로 전체 화면 플레이어 뷰 컨트롤러 표시
        present(fullScreenPlayerVC, animated: true) {
            // 재생 시작 (present 완료 후)
            fullScreenPlayerVC.player?.play()
        }
    }
    
    // 인라인 재생/일시정지 버튼 탭 액션
    @objc private func tapInlinePlayPauseButton() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot play/pause inline.")
            return
        }
        
        // 재생/일시정지 토글 로직
        if player.rate == 0 { // 현재 멈춰있거나 일시정지 상태 (rate가 0이면)
            player.play()
            inlinePlayPauseButton.setTitle("Pause", for: .normal) // 버튼 제목 변경
        } else { // 현재 재생 중인 상태 (rate가 0이 아니면)
            player.pause()
            inlinePlayPauseButton.setTitle("Play", for: .normal) // 버튼 제목 변경
        }
    }
    
    // 뷰 컨트롤러가 메모리에서 해제될 때 플레이어 정지 (선택 사항)
    deinit {
        player?.pause()
        player = nil
        embeddedPlayerViewController?.player = nil
    }
}


#Preview {
    UINavigationController(rootViewController: BasicVideoPlayerViewController())
    
}
