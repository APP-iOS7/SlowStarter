////
////  VideoPlayerView.swift
////  SlowStarter
////
////  Created by 이재용 on 5/13/25.
////
//
// import UIKit
// import AVKit
// import AVFoundation
// import SnapKit
//
// extension AVPlayer {
//    var isPlaying: Bool {
//        return rate != 0 && error == nil
//    }
// }
// class CustomVideoPlayerController: UIViewController {
//    // Video가 재생되는 뷰
//    let videoBackView = UIView()
//    
//    // MARK: - UI 컴포넌트 선언
//    let totalButtonsView = UIView()
//    let timeLineSlider = UISlider()
//    let timeLineLabel = UILabel()
//    let playButton = UIButton(type: .system)
//    let speedDisplayLabel = UILabel()
//    let fullScreenButton = UIButton(type: .system)
//    let loadingIndicator = UIActivityIndicatorView(style: .large)
//    let errorLabel = UILabel()
//    
//    // MARK: - Properties
//    var videoPlayer: AVPlayer?
//    var uiTimer: Timer?
//    var timeObserver: Any?
//    var speedMode = 2
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    
//    // 영상 시작시 UI 세팅
//    func setInitialUIStatus() {
//        totalButtonsView.isHidden = true
//        timeLineLabel.text = "00:00 / 00:00"
//        timeLineSlider.value = 0.0
//        self.setSpeedModeWithLevel(level: 2) // 1배속 시작
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.setVideoView(url: self.getSavedVideoUrl())
//        
//        self.resetUITimer()
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleUIControls))
//        self.view.addGestureRecognizer(tapGesture)
//    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .landscape
//    }
//    func closeViewAction() {
//        self.videoPlayer?.pause()
//        self.videoPlayer = nil
//        self.dismiss(animated: true)
//    }
//    func getSavedVideoUrl() -> URL {
//        return URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
//    }
//    func setVideoView(url: URL) {
//        videoPlayer = AVPlayer(url: url)
//        let playerLayer = AVPlayerLayer(player: videoPlayer!)
//        
//        playerLayer.frame = videoBackView.frame
//        videoBackView.layer.addSublayer(playerLayer)
//        videoPlayer?.play()
//        setPlayButtonImage()
//        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserver = videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
//            self.updateVideoPlayerSlider()
//        })
//    }
//    func setVideoAnotherView() {
//        videoBackView.backgroundColor = .purple
//        videoBackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(videoBackView)
//        view.sendSubviewToBack(videoBackView)
//        videoBackView.snp.makeConstraints { make in
//            make.top.leading.trailing.bottom.equalToSuperview()
//        }
//        
//    }
//    
//    // MARK: UI TImer
//    func resetUITimer() {
//        UITimer?.invalidate()
//        UITimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideUIControls), userInfo: nil, repeats: false)
//    }
//    @objc func hideUIControls() {
//        totalButtonsView.isHidden = true
//    }
//    @objc func toggleUIcontrols() {
//        totalButtonsView.isHidden.toggle()
//        self.resetUITimer()
//    }
//    
//    // MARK: 영상 진행중 할 일
//    func updateVideoPlayerSlider() async {
//        guard let currentTime = videoPlayer?.currentTime() else {return}
//        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
//        timeLineSlider.value = Float(currentTimeInSeconds)
//        if let currentItem = videoPlayer?.currentItem {
//            let duration = currentItem.duration
//            if (CMTIME_IS_INVALID(duration)) {
//                return
//            }
//            let currentTime = currentItem.currentTime()
//            timeLineSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
//        }
//        await self.setTimeLabel()
//    }
//    
//    func setTimeLabel() async {
//        let urlValue = self.getSavedVideoUrl()
//        let asset: AVURLAsset = AVURLAsset(url: urlValue)
//        do {
//            let minute = try await Int(floor(asset.load(.duration).seconds / 60))
//            let second = try await Int(asset.load(.duration).seconds) % 60
//        }
//        catch {
//            print(error)
//        }
//        return setTimeString(times: minute) + ":" + setTimeString(times: second)
//    }
//    func getVideoTotalTime() -> String? {// 전체시간 가져오기
//        let urlValue = self.getSavedVideoUrl()
//        let asset: AVAsset = AVAsset(url: urlValue)
//        let minute = Int(floor(asset.duration.seconds / 60))
//        let second = Int(asset.duration.seconds) % 60
//        return setTimeString(times: minute) + ":" + setTimeString(times: second)
//    }
//    func getVideoCurrentTime() -> String? {//현재 재생된 시간 가져오기
//        guard let timeValue = moviePlayer?.currentItem?.currentTime() else {return nil}
//        let minute = Int(floor(timeValue.seconds / 60))
//        let second = Int(timeValue.seconds) % 60
//        return setTimeString(times: minute) + ":" + setTimeString(times: second)
//    }
//    func setTimeString(times : Int) -> String {
//        if(times < 10){
//            return "0"+String(times)
//        }else{
//            return String(times)
//        }
//    }
//    
//    //MARK: Slider 터치시
//    func timeLineValueChanged() {
//        videoPlayer?.pause()
//        guard let duration = videoPlayer?.currentItem?.duration else { return}
//        let value = Float64(timeLineSlider.value) * CMTimeGetSeconds(duration)
//        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
//        videoPlayer?.seek(to: seekTime, completionHandler: { _ in
//            self.videoPlayer?.play()
//            self.setPlayButtonImage()
//            self.setSpeedModeWithLevel(level: self.speedMode)
//        })
//        return
//    }
//    
//    func clickPlayAction() {
//        if self.videoPlayer?.isPlaying ?? false {
//            self.videoPlayer?.pause()
//        } else {
//            self.videoPlayer?.play()
//            self.setSpeedModeWithLevel(level: self.speedMode)
//        }
//        self.setPlayButtonImage()
//    }
//    func setPlayButtonImage() {
//        if self.videoPlayer?.isPlaying ?? false {
//            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//        } else {
//            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        }
//    }
//    
//    func goAfterTenSeconds() {
//        self.setActionMoveSeconds(sec: 10.0)
//    }
//    
//    func goBeforeTenSeconds() {
//        self.setActionMoveSeconds(sec: -10.0)
//    }
//    
//    func setActionMoveSeconds(sec: Double) {
//        videoPlayer?.pause()
//        guard let currentTime = videoPlayer?.currentItem?.duration else { return}
//        let currentTimeInSecondsMove = CMTimeGetSeconds(currentTime).advanced(by: sec)
//        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMove), timescale: 1)
//        self.videoPlayer?.seek(to: seekTime, completionHandler: {okay in
//            self.videoPlayer?.play()
//            self.setPlayButtonImage()
//            self.setSpeedModeWithLevel(level: self.speedMode)
//        })
//    }
//    
//    func clickSpeedAction() {
//        switch speedMode{
//        case 1:
//            self.setSpeedModeWithLevel(level: 2)
//        case 2:
//            self.setSpeedModeWithLevel(level: 3)
//        case 3:
//            self.setSpeedModeWithLevel(level: 1)
//        default:
//            break
//        }
//    }
//    
//    func setSpeedModeWithLevel(level: Int) {
//        switch level {
//        case 1:
//            speedMode = 1
//            speedDisplayLabel.text = "0.5x"
//            self.videoPlayer?.playImmediately(atRate: 0.5)
//            break
//        case 2:
//            speedMode = 2
//            speedDisplayLabel.text = "1x"
//            self.videoPlayer?.playImmediately(atRate: 1)
//            break
//        case 3:
//            speedMode = 3
//            speedDisplayLabel.text = "2x"
//            self.videoPlayer?.playImmediately(atRate: 2)
//            break
//        default:
//            break
//        }
//    }
//    
//    
//    
//    
//}
//
//
