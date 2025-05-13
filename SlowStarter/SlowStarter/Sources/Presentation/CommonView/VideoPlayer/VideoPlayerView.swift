//
//  VideoPlayerView.swift
//  SlowStarter
//
//  Created by 이재용 on 5/13/25.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
class CustomVideoPlayerController: UIViewController {
    // Video가 재생되는 뷰
    let videoBackView = UIView()
    
    // MARK: - UI 컴포넌트 선언
    let totalButtonsView = UIView()
    let timeLineSlider = UISlider()
    let timeLineLabel = UILabel()
    let playButton = UIButton(type: .system)
    let speedDisplayLabel = UILabel()
    let fullScreenButton = UIButton(type: .system)
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let errorLabel = UILabel()
    
    // MARK: - Properties
    var videoPlayer: AVPlayer?
    var UITimer: Timer?
    var timeObserver: Any?
    var speedMode = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 영상 시작시 UI 세팅
    func setInitialUIStatus() {
        totalButtonsView.isHidden = true
        timeLineLabel.text = "00:00 / 00:00"
        timeLineSlider.value = 0.0
        set.setSpeedModeWithLevel(level: 2) // 1배속 시작
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setVideoView(url: self.getSavedVideoUrl())
        
        self.resetUITimer()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleUIControls))
        self.view.addGestureRecognizer(tapGesture)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    func closeViewAction() {
        self.videoPlayer?.pause()
        self.videoPlayer = nil
        self.dismiss(animated: true)
    }
    func getSavedVideoUrl() -> URL {
        return URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    }
    func setVideoView(url: URL) {
        videoPlayer = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: videoPlayer!)
        
        playerLayer.frame = videoBackView.frame
        videoBackView.layer.addSublayer(playerLayer)
        videoPlayer?.play()
        setPlayBtnImage()
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.updateVideoPlayerSlider()
        })
    }
    func setVideoAnotherView() {
        videoBackView.backgroundColor = .purple
        videoBackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoBackView)
        view.sendSubviewToBack(videoBackView)
        videoBackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    
    
    
    
    
}


