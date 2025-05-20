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

    // MARK: - UI Properties
    private var playerBaseView: UIView = UIView()
    private var thumbnailImageView: UIImageView! // 썸네일 이미지 뷰
    private var inlinePlayPauseButton: UIButton!
    private var fullScreenButton: UIButton!

    // MARK: - Player Properties
    private var embeddedPlayerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    private var videoURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Basic Video Player"
        configNavigationBarAppearance() // 네비게이션 바 설정 호출

        // 무음모드 소리재생 설정
        configureAudioSession()

        // UI 레이아웃 설정 (playerBaseView 먼저 추가)
        view.addSubview(playerBaseView)
        setupPlayerBaseViewConstraints() // playerBaseView 제약조건 설정 분리

        // 나머지 UI 요소들 설정
        setupButtons()

        // 비디오 URL 및 AVPlayer 인스턴스 설정
        setVideoURLAndPlayer()

        // 임베드된 AVPlayerViewController 설정 (AVPlayer 인스턴스 생성 후)
        setupEmbeddedPlayerViewController()

        // 플레이어 상태에 따른 UI 업데이트
        updateUIForPlayerState()
    }

    deinit {
        player?.pause()
        player = nil
        embeddedPlayerViewController?.player = nil // AVPlayerViewController의 player도 nil로 설정
        // KVO 옵저버가 있다면 여기서 제거해야 합니다.
        print("BasicVideoPlayerViewController deinitialized")
    }

    // MARK: - Configuration
    private func configNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // 기본 불투명 배경
        appearance.backgroundColor = .systemGroupedBackground // 배경색 예시
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Error in Config Audio Session: \(error.localizedDescription)")
        }
    }

    private func setVideoURLAndPlayer() {
        let urlString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid video URL string: \(urlString)")
            // 유효하지 않은 URL에 대한 처리 (예: 사용자에게 알림)
            player = nil
            return
        }
        self.videoURL = url
        self.player = AVPlayer(url: url)
    }

    // MARK: - UI Setup
    private func setupPlayerBaseViewConstraints() {
        playerBaseView.backgroundColor = .lightGray // 개발 중 확인용 색상
        playerBaseView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // 상단 여백 추가
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(playerBaseView.snp.width).multipliedBy(9.0/16.0) // 16:9 비율
        }
    }

    private func setupButtons() {
        // FullScreen Button
        fullScreenButton = UIButton(type: .system)
        fullScreenButton.setTitle("Play Fullscreen", for: .normal)
        fullScreenButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(fullScreenButton)

        fullScreenButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(playerBaseView.snp.bottom).offset(30)
        }
        fullScreenButton.addTarget(self, action: #selector(fullScreenPlayButtonTapped), for: .touchUpInside)

        // Inline Play/Pause Button
        inlinePlayPauseButton = UIButton(type: .system)
        inlinePlayPauseButton.setTitle("Play", for: .normal)
        inlinePlayPauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(inlinePlayPauseButton)

        inlinePlayPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(fullScreenButton.snp.bottom).offset(20)
        }
        inlinePlayPauseButton.addTarget(self, action: #selector(tapInlinePlayPauseButton), for: .touchUpInside)
    }

    private func setupEmbeddedPlayerViewController() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot setup embedded player.")
            return
        }

        embeddedPlayerViewController = AVPlayerViewController()
        embeddedPlayerViewController?.player = player
        // 임베드된 플레이어의 기본 컨트롤 숨기기 (커스텀 컨트롤을 사용할 경우)
        // embeddedPlayerViewController?.showsPlaybackControls = false

        if let embeddedVC = embeddedPlayerViewController {
            addChild(embeddedVC) // 1. 부모-자식 관계 시작
            playerBaseView.addSubview(embeddedVC.view) // 2. 자식 뷰를 컨테이너 뷰에 추가
            embeddedVC.view.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용 명시

            // 3. SnapKit으로 자식 뷰 제약 설정 (컨테이너 뷰에 꽉 채우기)
            embeddedVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            // 플레이어 뷰가 썸네일 뷰 위에 오도록 설정 (썸네일이 이미 추가된 후)
            // 또는 재생 시 썸네일을 숨김으로써 처리
            // playerBaseView.bringSubviewToFront(embeddedVC.view) // 이 방법도 가능

            embeddedVC.didMove(toParent: self) // 4. 부모-자식 관계 완료 알림
        }
    }

    // MARK: - UI Update
    private func updateUIForPlayerState() {
        let isPlayerReady = (player != nil && player?.currentItem != nil) // 좀 더 정확한 조건
        fullScreenButton.isEnabled = isPlayerReady
        inlinePlayPauseButton.isEnabled = isPlayerReady

        // 초기 상태에서는 썸네일이 보이도록 함
        thumbnailImageView.isHidden = false
    }

    // MARK: - Thumbnail Generation
    

    // MARK: - Actions
    @objc private func fullScreenPlayButtonTapped() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot play full screen.")
            return
        }

        // 새로운 AVPlayerViewController 인스턴스 생성 및 현재 player 할당
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = player // 동일한 player 인스턴스 사용

        present(fullScreenPlayerVC, animated: true) {
            self.thumbnailImageView.isHidden = true // 전체 화면 재생 시 인라인 썸네일 숨김
            fullScreenPlayerVC.player?.play()
        }
    }

    @objc private func tapInlinePlayPauseButton() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot play/pause inline.")
            return
        }

        // 재생/일시정지 토글 로직
        if player.rate == 0 { // 현재 멈춰있거나 일시정지 상태
            player.play()
            inlinePlayPauseButton.setTitle("Pause", for: .normal)
            thumbnailImageView.isHidden = true // 재생 시작 시 썸네일 숨김
        } else { // 현재 재생 중인 상태
            player.pause()
            inlinePlayPauseButton.setTitle("Play", for: .normal)
            // 일시 정지 시 썸네일 다시 보이게 할 수도 있음 (선택 사항)
            // thumbnailImageView.isHidden = false
        }
    }
}

#Preview {
    UINavigationController(rootViewController: BasicVideoPlayerViewController())
}
