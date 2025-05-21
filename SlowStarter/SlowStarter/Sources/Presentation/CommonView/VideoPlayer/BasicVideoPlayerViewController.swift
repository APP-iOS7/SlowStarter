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
    private var thumbnailImageView: UIImageView!
    private var inlinePlayPauseButton: UIButton!
    private var fullScreenButton: UIButton!
    
    // MARK: - Player Properties
    private var embeddedPlayerViewController: AVPlayerViewController?
    private var player: AVPlayer? {
        // player가 설정되거나 변경될 때 KVO 옵저버를 관리
        willSet {
            removePlayerObservers() // 기존 옵저버 제거
        }
        didSet {
            addPlayerObservers() // 새 옵저버 등록
        }
    }
    private var videoURL: URL?
    
    // KVO Context (여러 옵저버를 사용할 경우 구분하기 위함, 여기서는 하나만 사용)
    private var playerRateObservationContext = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // ... (기존 viewDidLoad 내용) ...
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
        setVideoURLAndPlayer() // 이 내부에서 player가 할당되면서 KVO 옵저버가 등록됨
        
        // AVPlayerViewController 설정 및 썸네일 로직
        setupEmbeddedPlayerViewControllerAndThumbnail()
        
        // 플레이어 상태에 따른 UI 업데이트
        updateUIForPlayerState()
    }
    
    deinit {
        player?.pause()
        removePlayerObservers() // deinit 시 옵저버 반드시 제거
        // player = nil // player의 didSet에서 removePlayerObservers가 호출되므로 중복될 수 있으나, 명시적으로 nil 처리
        embeddedPlayerViewController?.player = nil
        print("BasicVideoPlayerViewController deinitialized")
    }
    
    // MARK: - KVO (Key-Value Observing)
    private func addPlayerObservers() {
        guard let player = player else { return }
        // "rate" 프로퍼티 관찰 시작
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.rate),
                           options: [.new, .old], // 변경된 새 값과 이전 값을 모두 받음
                           context: &playerRateObservationContext)
        print("Player KVO observer added for 'rate'")
    }
    
    private func removePlayerObservers() {
        guard let player = player else { return }
        // "rate" 프로퍼티 관찰 중지 시도 (등록되지 않았어도 에러 발생 안 함)
        // player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &playerRateObservationContext)
        // 위와 같이 context를 사용하거나, 아래처럼 context 없이 모든 해당 keyPath의 옵저버를 제거할 수 있음
        // 하지만 context를 사용하는 것이 더 안전함.
        // 또는 옵저버 등록 여부를 추적하는 플래그를 사용할 수도 있음.
        // 가장 간단한 방법은 try-catch로 감싸는 것 (더 이상 권장되지는 않음)
        // 여기서는 player가 nil이 될 때 remove하므로, 이전 player 인스턴스에 대한 옵저버만 제거됨.
        // player가 non-nil일 때만 removeObserver를 호출하도록 guard let 사용
        // 또는 player가 nil이 되기 전에 willSet에서 호출하므로, oldValue에 대해 remove
        // player의 didSet에서 addObserver를 하므로, player가 nil이 되는 경우는 deinit 밖에 없음.
        // 안전하게 하려면 옵저버 등록 상태를 관리하는 변수 필요.
        // 여기서는 가장 간단한 형태로, player가 nil이 될 때(deinit, 또는 새로운 player 할당 전) 호출됨을 가정.
        // player가 nil이 아닌 상태에서 removeObserver를 호출해야 하므로, player가 nil로 설정되기 전에 호출되어야 함.
        // -> `willSet`에서 `oldValue`에 대해 제거하거나, `didSet`에서 `oldValue`가 있었다면 제거하고 `newValue`에 추가.
        // 현재 player의 `willSet`에서 호출되므로, `player`는 아직 이전 값을 가지고 있음.
        // 따라서 현재 `player` (즉, `oldValue`에 해당)에 대한 옵저버를 제거.
        // (만약 player가 처음 nil에서 non-nil로 설정될 때는 remove할 대상이 없음)
        // 가장 확실한 방법은 옵저버 등록/해제 쌍을 명확히 관리하는 것.
        // player의 willSet에서 이전 player의 옵저버를 제거
        // player의 didSet에서 새 player의 옵저버를 등록
        
        // player가 nil이 아닌 경우에만 removeObserver 시도 (willSet에서 호출되므로 player는 이전 값)
        // 이 player는 이제 사라질 인스턴스이므로, 여기에 등록된 옵저버를 제거해야 함.
        if player.observationInfo != nil { // observationInfo는 내부 사용 API, 직접 사용 권장 안됨
             // 안전하게 하려면 옵저버 등록 시점을 추적하는 Bool 플래그 사용 권장
             // 여기서는 player가 nil이 아니면 이전 player의 옵저버를 제거한다고 가정
            player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &playerRateObservationContext)
            print("Player KVO observer removed for 'rate'")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // 우리가 등록한 옵저버인지, 그리고 player의 rate 변경인지 확인
        guard context == &playerRateObservationContext,
              let player = object as? AVPlayer,
              keyPath == #keyPath(AVPlayer.rate) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        // 변경된 새 rate 값을 가져옴
        if let newRate = change?[.newKey] as? Float {
            print("Player rate changed to: \(newRate)")
            if newRate > 0 { // 재생 시작 (rate가 0보다 크면 재생 중)
                DispatchQueue.main.async { [weak self] in // UI 업데이트는 메인 스레드에서
                    self?.thumbnailImageView?.isHidden = true
                    print("Thumbnail hidden due to player rate > 0 (KVO)")
                    // (선택) 커스텀 인라인 재생 버튼의 상태도 업데이트
                    self?.inlinePlayPauseButton?.setTitle("Pause", for: .normal)
                }
            } else { // 일시정지 또는 재생 완료 (rate가 0이면 멈춤)
                // (선택) 일시정지 시 썸네일을 다시 표시하고 싶다면 아래 주석 해제
                // DispatchQueue.main.async { [weak self] in
                //     self?.thumbnailImageView?.isHidden = false
                // }
                // (선택) 커스텀 인라인 재생 버튼의 상태도 업데이트
                DispatchQueue.main.async { [weak self] in
                    self?.inlinePlayPauseButton?.setTitle("Play", for: .normal)
                }
            }
        }
    }

    // ... (configNavigationBarAppearance, configureAudioSession, setVideoURLAndPlayer, generateThumbnail, UI Setup 함수들은 이전과 동일) ...
    private func configNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 36, weight: .bold)
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
            player = nil
            return
        }
        self.videoURL = url
        // player에 새 값이 할당될 때 didSet이 호출되어 addPlayerObservers() 실행
        self.player = AVPlayer(url: url)
    }
    
    private func generateThumbnail(url: URL, at timeSeconds: Double, maxRetries: Int, retryDelay: TimeInterval) async throws -> UIImage {
        var currentAttempt = 0
        
        while currentAttempt <= maxRetries {
            currentAttempt += 1
            
            let asset = AVURLAsset(url: url)
            do {
                let (isPlayable, _, tracks) = try await asset.load(.isPlayable, .duration, .tracks)
                
                guard isPlayable else {
                    print("Asset is not playalbe")
                    if currentAttempt > maxRetries { throw ThumbnailError.assetNotPlayable}
                    
                    try await Task.sleep(nanoseconds: .init(retryDelay * 1_000_000_000))
                    
                    continue
                }
                guard !tracks.isEmpty, tracks.contains(where: {$0.mediaType == .video}) else {
                    print("no video tracks")
                    if currentAttempt > maxRetries {throw ThumbnailError.assetLoadingFailed(nil)}
                    
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    continue
                }
                
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                imageGenerator.maximumSize = CGSize(width: 300, height: 300)
                let requestTime = CMTimeMakeWithSeconds(timeSeconds, preferredTimescale: 600)
                
                let cgImage: CGImage
                cgImage = try await imageGenerator.image(at: requestTime).image
                
                let thumbnailImage = UIImage(cgImage: cgImage)
                return thumbnailImage
            } catch {
                print("Error on attempting to generate thumbnail: \(error)")
                if currentAttempt > maxRetries {
                    if error is ThumbnailError {
                        throw error
                    } else { throw ThumbnailError.imageGenerationFailed(error)}
                }
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            }
            
        }
        print("All retries failed")
        throw ThumbnailError.maxRetriesReached
    }
    
    private func setupPlayerBaseViewConstraints() {
        playerBaseView.backgroundColor = .lightGray
        playerBaseView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(playerBaseView.snp.width).multipliedBy(9.0/16.0)
        }
    }
    
    
    private func setupButtons() {
        fullScreenButton = UIButton(type: .system)
        fullScreenButton.setTitle("Play Fullscreen", for: .normal)
        fullScreenButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(fullScreenButton)
        
        fullScreenButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(playerBaseView.snp.bottom).offset(30)
        }
        fullScreenButton.addTarget(self, action: #selector(fullScreenPlayButtonTapped), for: .touchUpInside)
        
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
    
    private func setupEmbeddedPlayerViewControllerAndThumbnail() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot setup embedded player.")
            return
        }
        
        embeddedPlayerViewController = AVPlayerViewController()
        guard let embeddedVC = embeddedPlayerViewController else { return }
        
        embeddedVC.player = player
        
        addChild(embeddedVC)
        playerBaseView.addSubview(embeddedVC.view)
        embeddedVC.view.translatesAutoresizingMaskIntoConstraints = false
        embeddedVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        embeddedVC.didMove(toParent: self)
        
        thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
        thumbnailImageView.isUserInteractionEnabled = false
        
        if let overlayView = embeddedVC.contentOverlayView {
            overlayView.addSubview(thumbnailImageView)
            thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
            thumbnailImageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            print("Warning: contentOverlayView is nil. Thumbnail might not be added correctly.")
        }
        
        if let videoURL = videoURL {
            Task {
                do {
                    let asset = AVURLAsset(url: videoURL)
                    let durationCMTime = try await asset.load(.duration)
                    let durationInSec = CMTimeGetSeconds(durationCMTime)
                    let thumbnailTimeSec = durationInSec > 0 ? durationInSec / 2.0 : 1.0
                    
                    print("Attempting to load thumbnail at: \(thumbnailTimeSec)s for URL: \(videoURL)")
                    let image = try await generateThumbnail(url: videoURL, at: thumbnailTimeSec, maxRetries: 2, retryDelay: 2.0)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.thumbnailImageView.image = image
                        self?.thumbnailImageView.isHidden = false
                        print("Thumbnail Loaded and set to contentOverlayView")
                    }
                    
                } catch let error as ThumbnailError {
                    DispatchQueue.main.async { [weak self] in
                        self?.thumbnailImageView.image = UIImage(systemName: "exclamationmark.triangle")
                        self?.thumbnailImageView.tintColor = .systemRed
                        print("no Thumbnail Loaded (Custom Error): \(error.localizedDescription)")
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.thumbnailImageView.image = UIImage(systemName: "xmark.octagon")
                        self?.thumbnailImageView.tintColor = .systemRed
                        print("Thumbnail cannot be loaded (Unknown Error): \(error.localizedDescription)")
                    }
                }
            }
        } else {
            thumbnailImageView.image = UIImage(systemName: "film.fill")
            thumbnailImageView.tintColor = .darkGray
            thumbnailImageView.isHidden = false
            print("Error: Video URL is nil, cannot generate thumbnail. Showing placeholder.")
        }
    }
    
    private func updateUIForPlayerState() {
        let isPlayerReady = (player != nil && player?.currentItem != nil)
        fullScreenButton.isEnabled = isPlayerReady
        inlinePlayPauseButton.isEnabled = isPlayerReady
        
        thumbnailImageView?.isHidden = false
    }
    
    
    @objc private func fullScreenPlayButtonTapped() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot play full screen.")
            return
        }
        
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = player
        
        present(fullScreenPlayerVC, animated: true) {
            self.thumbnailImageView?.isHidden = true
            fullScreenPlayerVC.player?.play()
        }
    }
    
    @objc private func tapInlinePlayPauseButton() {
        guard let player = player else {
            print("Error: AVPlayer instance is nil. Cannot play/pause inline.")
            return
        }
        
        if player.rate == 0 {
            // KVO에서 rate 변경을 감지하므로, 여기서 thumbnailImageView.isHidden을 직접 제어할 필요가 없을 수도 있음.
            // 하지만 사용자 버튼 탭에 즉각 반응하도록 남겨둘 수 있음.
            player.play()
            // inlinePlayPauseButton.setTitle("Pause", for: .normal) // KVO에서 처리 가능
            // thumbnailImageView?.isHidden = true // KVO에서 처리 가능
        } else {
            player.pause()
            // inlinePlayPauseButton.setTitle("Play", for: .normal) // KVO에서 처리 가능
        }
    }
}
#Preview {
    UINavigationController(rootViewController: BasicVideoPlayerViewController())
}
