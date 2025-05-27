// VideoPlayerViewController.swift

import UIKit
import AVKit
import AVFoundation
import SnapKit



class VideoPlayerViewController: UIViewController {
    
    // MARK: - UI Properties
    private var playerBaseView: UIView = UIView()
    private var thumbnailImageView: UIImageView! // viewDidLoad에서 초기화
    // (선택적) 로딩 인디케이터
    // private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Player Properties
    private var embeddedPlayerViewController: AVPlayerViewController?
    
    // KVO Observation 객체들
    private var playerRateObservation: NSKeyValueObservation?
    private var playerItemStatusObservation: NSKeyValueObservation?
    
    private var player: AVPlayer? {
        willSet {
            // 1. 기존 player에 대한 모든 옵저버 및 알림 정리
            // Rate 옵저버 해제
            playerRateObservation?.invalidate()
            playerRateObservation = nil
            
            // Item Status 옵저버 해제
            playerItemStatusObservation?.invalidate()
            playerItemStatusObservation = nil
            
            // DidPlayToEndTime 알림 제거
            if let oldPlayerItem = player?.currentItem { // player는 아직 이전 값을 가지고 있음
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldPlayerItem)
                print("DidPlayToEndTime observer removed from old player's item (willSet).")
            }
        }
        didSet {
            // player가 nil이 되면 아무것도 하지 않음 (willSet에서 이미 모든 관련 옵저버/알림이 정리되었어야 함)
            guard let newPlayer = player else {
                print("Player is now nil. All observers/notifications should be invalidated/removed.")
                // 만약 player가 nil이 될 때 추가적인 UI 정리가 필요하다면 여기서 수행
                // 예: embeddedPlayerViewController.player = nil
                // thumbnailImageView.image = 플레이스홀더 등
                return
            }

            // 1. AVPlayer.rate 옵저빙 설정 (블록 기반)
            playerRateObservation = newPlayer.observe(\.rate, options: [.new, .old]) { [weak self] _, change in
                guard let self = self else { return }
                if let newRate = change.newValue {
                    print("Player rate changed to: \(newRate) (Block KVO)")
                    DispatchQueue.main.async {
                        if newRate > 0 { // 재생 시작
                            self.thumbnailImageView?.isHidden = true
                            print("Thumbnail hidden due to player rate > 0 (Block KVO)")
                        } else { // 일시정지 또는 종료
                            // 필요시 썸네일 다시 표시 (예: 사용자가 명시적으로 일시정지했을 때)
                            // self.thumbnailImageView?.isHidden = false
                        }
                    }
                }
            }
            print("Block KVO for 'rate' added to new player.")

            // 2. AVPlayerItem.status 옵저빙 설정 (블록 기반)
            //    player.currentItem은 player가 AVPlayerItem으로 초기화된 후에야 non-nil이 됨.
            if let newPlayerItem = newPlayer.currentItem {
                playerItemStatusObservation = newPlayerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
                    guard let self = self else { return }
                    // change.newValue 또는 item.status를 직접 사용 가능
                    let status = item.status
                    
                    DispatchQueue.main.async {
                        // self.activityIndicator.stopAnimating() // 로딩 인디케이터 숨김
                        switch status {
                        case .readyToPlay:
                            print("✅ PlayerItem status: readyToPlay. Video is loaded (Block KVO).")
                            // 비디오가 재생 준비되면 썸네일 숨김
                            self.thumbnailImageView?.isHidden = true
                            
                            // (선택적) 자동 재생
                            // self.player?.play()
                            
                        case .failed:
                            let error = item.error
                            print("❌ PlayerItem status: failed. Error: \(String(describing: error?.localizedDescription)) (Block KVO)")
                            // 에러 발생 시 사용자에게 알림 및 에러 썸네일 표시
                            self.thumbnailImageView?.image = UIImage(systemName: "exclamationmark.triangle.fill")
                            self.thumbnailImageView?.tintColor = .systemRed
                            self.thumbnailImageView?.contentMode = .scaleAspectFit
                            self.thumbnailImageView?.isHidden = false
                        case .unknown:
                            print("ℹ️ PlayerItem status: unknown. (Block KVO)")
                            // 로딩 중 상태. 필요시 로딩 인디케이터 표시
                            // self.activityIndicator.startAnimating()
                        @unknown default:
                            print("PlayerItem status: encountered an unknown new status. (Block KVO)")
                        }
                    }
                }
                print("Block KVO for 'item.status' added to new player's item.")
                
                // 3. DidPlayToEndTime 알림 등록
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.playerItemDidReachEnd(notification:)),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: newPlayerItem)
                print("DidPlayToEndTime observer added to new player's item (didSet).")
            } else {
                print("Warning: New player's currentItem is nil. Cannot observe item status or add DidPlayToEndTime notification.")
            }
        }
    }
    private(set) var videoURL: URL? // 외부에서 읽기만 가능하도록, 설정은 updateVideo 통해
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureAudioSession()
        
        view.addSubview(playerBaseView)
        setupPlayerBaseViewConstraints()
        
        setupEmbeddedPlayerViewControllerAndThumbnailView()
        // setupActivityIndicator() // 로딩 인디케이터 설정 (선택적)
        
        updateUIForPlayerState() // 초기 UI (플레이스홀더 썸네일 등)
        
    }
    
    deinit {
        player?.pause()
        
        // 블록 기반 KVO는 observation 객체가 해제될 때 자동으로 invalidate 되지만,
        // 명시적으로 호출하는 것이 더 안전하고 예측 가능성을 높임.
        // player의 willSet에서 이미 처리하고 있으므로, 여기서는 player가 nil이 아닌 상태로
        // 뷰 컨트롤러가 해제될 경우를 대비한 최종 정리.
        playerRateObservation?.invalidate()
        playerItemStatusObservation?.invalidate()
        
        // NotificationCenter 옵저버도 확실히 제거
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil) // 모든 객체에 대한 알림 제거
        // 또는 NotificationCenter.default.removeObserver(self) // 이 컨트롤러에 등록된 모든 알림 제거
        
        embeddedPlayerViewController?.player = nil
        print("VideoPlayerViewController deinitialized")
    }
    
    // MARK: - Public Interface
    public func updateVideo(with newVideoURL: URL?) {
        // 1. 기존 플레이어 일시정지 (옵저버 등은 player의 willSet에서 자동으로 정리됨)
        player?.pause()
        
        // 2. 새 URL로 videoURL 프로퍼티 업데이트
        self.videoURL = newVideoURL
        
        // 3. 새 URL로 AVPlayer 인스턴스 재생성 및 할당
        if let url = newVideoURL {
            let newPlayerItem = AVPlayerItem(url: url)
            // self.player에 할당 시 willSet/didSet이 호출되어 옵저버 및 알림이 자동으로 관리됨
            self.player = AVPlayer(playerItem: newPlayerItem)
        } else {
            // self.player에 nil 할당 시 willSet/didSet이 호출되어 옵저버 및 알림이 자동으로 관리됨
            self.player = nil
        }
        
        // 4. AVPlayerViewController에 새 player 연결
        //    (player가 nil이 되면 embeddedVC의 player도 nil로 설정됨)
        embeddedPlayerViewController?.player = self.player
        
        // 5. 썸네일 로드 및 표시 (URL이 nil이면 플레이스홀더 표시)
        loadAndDisplayThumbnail(for: newVideoURL)
        
        // 6. 플레이어 상태에 따른 UI 업데이트
        updateUIForPlayerState()
        
        print("VideoPlayerViewController updated with URL: \(newVideoURL?.absoluteString ?? "nil")")
    }
    
    // observeValue(forKeyPath:of:change:context:) 메서드는 블록 기반 KVO 사용으로 인해 제거됨.

    // MARK: - Notification Handling
    @objc private func playerItemDidReachEnd(notification: Notification) {
        // 알림을 보낸 객체가 현재 player의 currentItem과 같은지 확인 (선택적이지만 안전)
        guard let playerItem = notification.object as? AVPlayerItem,
              playerItem == player?.currentItem else {
            return
        }
        
        print("Video finished playing (DidPlayToEndTime notification).")
        // 비디오 재생 완료 후 처리 (예: 처음으로 되감기, 다음 비디오 재생, 썸네일 다시 표시 등)
        // player?.seek(to: .zero)
        // thumbnailImageView?.isHidden = false
    }

    // MARK: - Setup Methods
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Error configuring AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func setupPlayerBaseViewConstraints() {
        playerBaseView.backgroundColor = .black // 썸네일 로드 전 또는 비디오 영역 배경
        playerBaseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupEmbeddedPlayerViewControllerAndThumbnailView() {
        // AVPlayerViewController 설정
        embeddedPlayerViewController = AVPlayerViewController()
        guard let embeddedVC = embeddedPlayerViewController else {
            print("Failed to create AVPlayerViewController.")
            return
        }
        
        // embeddedVC.player는 updateVideo(with:)에서 player가 설정될 때 함께 설정됨
        
        addChild(embeddedVC)
        playerBaseView.addSubview(embeddedVC.view)
        embeddedVC.view.translatesAutoresizingMaskIntoConstraints = false
        embeddedVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        embeddedVC.didMove(toParent: self)
        
        // 썸네일 이미지 뷰 생성 및 초기 설정 (한 번만 실행)
        if thumbnailImageView == nil {
            thumbnailImageView = UIImageView()
            thumbnailImageView.contentMode = .scaleAspectFill
            thumbnailImageView.clipsToBounds = true
            thumbnailImageView.backgroundColor = .clear // playerBaseView의 배경색이 보이도록
            thumbnailImageView.isUserInteractionEnabled = false
            
            // AVPlayerViewController의 contentOverlayView에 썸네일 뷰 추가
            // contentOverlayView는 컨트롤 위에 표시되므로 썸네일이 컨트롤을 가릴 수 있음.
            // 컨트롤 아래에 표시하려면 embeddedVC.view에 직접 추가하고 zPosition을 조정하거나,
            // 별도의 썸네일 전용 뷰를 playerBaseView에 추가하는 것을 고려.
            // 여기서는 contentOverlayView를 사용.
            if let overlayView = embeddedVC.contentOverlayView {
                overlayView.addSubview(thumbnailImageView)
                thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
                thumbnailImageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            } else {
                print("Warning: contentOverlayView is nil. Thumbnail might not be added to overlay.")
                // 대체: playerBaseView에 썸네일 뷰를 추가하고, embeddedVC.view보다 아래에 있도록 함
                playerBaseView.insertSubview(thumbnailImageView, belowSubview: embeddedVC.view) // 예시
                thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
                thumbnailImageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
        
        // 초기 썸네일 (플레이스홀더)
        // 실제 비디오 썸네일은 updateVideo -> loadAndDisplayThumbnail에서 로드
        loadAndDisplayThumbnail(for: nil)
    }

    // (선택적) 로딩 인디케이터 설정
    // private func setupActivityIndicator() {
    //     activityIndicator.color = .white
    //     playerBaseView.addSubview(activityIndicator)
    //     activityIndicator.snp.makeConstraints { make in
    //         make.center.equalToSuperview()
    //     }
    // }

    // MARK: - Thumbnail Handling
    private func loadAndDisplayThumbnail(for url: URL?) {
        guard let thumbnailImageView = thumbnailImageView else {
            print("ThumbnailImageView is not initialized. Cannot load thumbnail.")
            return
        }

        // URL이 nil이면 플레이스홀더 썸네일 표시
        guard let validVideoURL = url else {
            DispatchQueue.main.async { [weak self] in
                // self?.activityIndicator.stopAnimating()
                thumbnailImageView.image = UIImage(systemName: "film.fill")
                thumbnailImageView.tintColor = .systemGray
                thumbnailImageView.contentMode = .scaleAspectFit // 아이콘이 잘리지 않도록
                thumbnailImageView.isHidden = false
                print("Video URL is nil. Showing placeholder thumbnail.")
            }
            return
        }
        
        // 썸네일 로딩 시작 시 UI 업데이트
        DispatchQueue.main.async { [weak self] in
            thumbnailImageView.image = nil // 이전 이미지 제거
            // self?.activityIndicator.startAnimating() // 로딩 인디케이터 시작
            thumbnailImageView.isHidden = true // 로딩 중에는 숨김 (또는 로딩 인디케이터로 대체)
        }

        Task { // 비동기 썸네일 생성
            do {
                // 영상 시작 10% 지점 또는 최대 5초 지점의 썸네일 (긴 영상 고려)
                let image = try await generateThumbnail(url: validVideoURL, atTimeRatio: 0.1, maxDurationForRatio: 5.0, maxRetries: 2, retryDelay: 1.0)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // self.activityIndicator.stopAnimating()
                    self.thumbnailImageView.image = image
                    self.thumbnailImageView.contentMode = .scaleAspectFill // 실제 썸네일은 꽉 채우기
                    
                    // 플레이어가 이미 재생 중이거나 준비 완료 상태면 썸네일 숨김 유지
                    if self.player?.rate ?? 0 > 0 || self.player?.currentItem?.status == .readyToPlay {
                        self.thumbnailImageView.isHidden = true
                    } else {
                        self.thumbnailImageView.isHidden = false
                    }
                    print("Thumbnail loaded and set for: \(validVideoURL.lastPathComponent)")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    // self?.activityIndicator.stopAnimating()
                    thumbnailImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
                    thumbnailImageView.tintColor = .systemYellow
                    thumbnailImageView.contentMode = .scaleAspectFit
                    thumbnailImageView.isHidden = false
                    print("Failed to load thumbnail for \(validVideoURL.lastPathComponent): \(error.localizedDescription)")
                }
            }
        }
    }

    /// 비디오 URL과 시간 비율(0.0 ~ 1.0) 및 최대 시간(초)을 기반으로 썸네일을 비동기적으로 생성합니다.
    private func generateThumbnail(url: URL, atTimeRatio ratio: Double, maxDurationForRatio: TimeInterval, maxRetries: Int, retryDelay: TimeInterval) async throws -> UIImage {
        let asset = AVURLAsset(url: url)
        
        let duration = try await asset.load(.duration) // AVAsset의 프로퍼티 로드
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        guard durationInSeconds.isFinite, durationInSeconds > 0 else {
            throw ThumbnailError.assetLoadingFailed(nil)
        }
        
        // 썸네일 추출 시간 계산: 비율에 따른 시간 또는 최대 시간 중 작은 값 사용
        let timeFromRatio = durationInSeconds * ratio
        let targetTimeInSeconds = min(timeFromRatio, maxDurationForRatio)
        let requestTime = CMTimeMakeWithSeconds(targetTimeInSeconds, preferredTimescale: 600)
        
        var currentAttempt = 0
        while currentAttempt <= maxRetries {
            currentAttempt += 1
            do {
                // 에셋이 재생 가능한지, 비디오 트랙이 있는지 확인
                let (isPlayable, tracks) = try await asset.load(.isPlayable, .tracks)
                guard isPlayable, tracks.contains(where: { $0.mediaType == .video }) else {
                    if currentAttempt > maxRetries { throw ThumbnailError.assetNotPlayable }
                    try await Task.sleep(for: .seconds(retryDelay)) // nanoseconds 대신 TimeInterval 사용
                    continue
                }

                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true // 비디오 방향 적용
                imageGenerator.maximumSize = CGSize(width: 600, height: 600) // 썸네일 최대 크기
                
                let cgImage = try await imageGenerator.image(at: requestTime).image // Swift Concurrency API 사용
                let thumbnailImage = UIImage(cgImage: cgImage)
                return thumbnailImage
                
            } catch {
                print("Error generating thumbnail (attempt \(currentAttempt)/\(maxRetries+1)) for \(url.lastPathComponent): \(error.localizedDescription)")
                if currentAttempt > maxRetries {
                    // 이미 ThumbnailError 타입이면 그대로 throw, 아니면 래핑
                    if let thumbnailError = error as? ThumbnailError {
                        throw thumbnailError
                    } else {
                        throw ThumbnailError.imageGenerationFailed(error)
                    }
                }
                try? await Task.sleep(for: .seconds(retryDelay)) // 재시도 전 대기
            }
        }
        throw ThumbnailError.maxRetriesReached // 모든 재시도 실패
    }
    
    // MARK: - UI Update Logic
    private func updateUIForPlayerState() {
        // 이 함수는 주로 초기 상태 또는 명시적인 UI 업데이트에 사용.
        // 실제 재생/일시정지 시 썸네일 가시성은 KVO 콜백에서 주로 처리.
        if player == nil || player?.rate == 0 {
            // 플레이어가 없거나 멈춰있고, 썸네일 이미지가 있다면 썸네일 표시
            if thumbnailImageView?.image != nil { // 썸네일 이미지가 nil이 아닌 경우 (플레이스홀더 또는 로드된 썸네일)
                thumbnailImageView?.isHidden = false
            }
            // 썸네일 이미지가 nil인 경우 (예: 로딩 중이거나 실패 초기 상태)는 loadAndDisplayThumbnail에서 isHidden 관리
        } else { // 재생 중이면 썸네일 숨김
            thumbnailImageView?.isHidden = true
        }
    }
    
    // MARK: - (Optional) Actions for custom controls
    @objc private func playPauseButtonTapped() {
        guard let player = player else { return }
        if player.rate == 0 {
            player.play()
            // Update button UI to "Pause"
        } else {
            player.pause()
            // Update button UI to "Play"
        }
    }
    
    @objc private func openFullScreenPlayer() {
        guard let player = player else { return }
        let fullScreenVC = AVPlayerViewController()
        fullScreenVC.player = player
        // 전체 화면 플레이어에 대한 설정 추가 가능 (예: showsPlaybackControls)
        present(fullScreenVC, animated: true) {
            fullScreenVC.player?.play() // 전체 화면 진입 후 자동 재생
        }
    }
}

// MARK: - SwiftUI Preview (Xcode 15+)
#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 15.0, *)
struct VideoPlayerViewControllerPreviewProviderFinal: PreviewProvider { // 이름 충돌 방지
    static var previews: some View {
        VideoPlayerViewController.PreviewContainer {
            let vc = VideoPlayerViewController()
            // 테스트를 위해 뷰가 나타난 후 비디오 로드 (선택적)
            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //     if let testURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
            //         vc.updateVideo(with: testURL)
            //     }
            // }
            return vc
        }
        .edgesIgnoringSafeArea(.all)
        .previewDisplayName("VideoPlayer VC (Block KVO Final)")
    }
}

// PreviewContainer를 VideoPlayerViewController의 확장으로 두는 것이 좋음
extension VideoPlayerViewController {
    // UIKit UIViewController를 SwiftUI Preview에서 사용하기 위한 래퍼
    @available(iOS 15.0, *)
    struct PreviewContainer<T: UIViewController>: UIViewControllerRepresentable {
        let viewControllerBuilder: () -> T
        
        init(_ builder: @escaping () -> T) {
            self.viewControllerBuilder = builder
        }
        
        func makeUIViewController(context: Context) -> T {
            return viewControllerBuilder()
        }
        
        func updateUIViewController(_ uiViewController: T, context: Context) {}
    }
}
#endif
