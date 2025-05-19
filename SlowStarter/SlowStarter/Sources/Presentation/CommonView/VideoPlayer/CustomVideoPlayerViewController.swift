////
////  CustomVideoPlayerViewController.swift
////  SlowStarter
////
////  Created by 이재용 on 5/15/25.
////
//
//import UIKit
//import AVKit // AVPlayerViewController 등을 사용하지 않더라도 AVFoundation과 함께 자주 사용됨
//import AVFoundation // AVPlayer, AVPlayerLayer 등 핵심 미디어 프레임워크
//import SnapKit // Auto Layout을 코드로 쉽게 작성하기 위한 라이브러리
//
//// AVPlayer의 재생 상태를 쉽게 확인하기 위한 extension
//extension AVPlayer {
//    /// 현재 플레이어가 재생 중인지 여부를 반환합니다. (rate가 0이 아니고, 에러가 없는 경우)
//    var isPlaying: Bool {
//        return rate != 0 && error == nil
//    }
//}
//
///// AVPlayer와 AVPlayerLayer를 사용하여 직접 UI를 구성한 커스텀 비디오 플레이어 뷰 컨트롤러
//class CustomVideoPlayerViewController: UIViewController {
//    
//    // MARK: - UI Properties
//    
//    /// 모든 컨트롤 버튼 및 UI 요소를 담는 컨테이너 뷰
//    private var totalBtnView: UIView!
//    /// 비디오 재생 시간을 표시하고 탐색할 수 있는 슬라이더
//    private var timeLineSlider: UISlider!
//    /// 현재 재생 시간과 전체 비디오 길이를 텍스트로 표시하는 레이블 (예: "00:10 / 01:30")
//    private var timeLineLabel: UILabel!
//    /// 재생/일시정지 기능을 하는 버튼
//    private var playButton: UIButton!
//    /// 현재 재생 배속을 텍스트로 표시하는 레이블 (예: "x 1.0")
//    private var speedDisplayLabel: UILabel!
//    /// 플레이어 뷰 컨트롤러를 닫는 버튼
//    private var closeButton: UIButton!
//    /// 비디오를 10초 앞으로 이동시키는 버튼
//    private var plusTimeButton: UIButton!
//    /// 비디오를 10초 뒤로 이동시키는 버튼
//    private var minusTimeButton: UIButton!
//    /// 재생 배속을 변경하는 버튼
//    private var speedButton: UIButton!
//    
//    // MARK: - Player Properties
//    
//    /// 비디오 재생을 담당하는 AVPlayer 인스턴스
//    var videoPlayer: AVPlayer?
//    /// AVPlayerLayer가 추가되어 실제 비디오 화면이 그려지는 뷰
//    let videoBackView = UIView() // UIView 인스턴스 생성
//    
//    // MARK: - Control Properties
//    
//    /// 일정 시간 후 UI 컨트롤을 숨기기 위한 타이머
//    var uiTimer: Timer?
//    /// 비디오 재생 시간을 주기적으로 감지하여 UI를 업데이트하기 위한 옵저버 토큰
//    var timeObserver: Any? // Swift 3 이전 스타일, Any로 변경 고려
//    /// 현재 설정된 재생 배속 모드를 나타내는 정수 값 (1: 0.5배속, 2: 1.0배속, 3: 2.0배속)
//    var speedMode = 2 // 기본 1.0배속으로 초기화
//    
//    // MARK: - Lifecycle Methods
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .darkGray // 뷰의 기본 배경색 설정
//        
//        // 비디오가 재생될 배경 뷰 설정
//        setupVideoBackView()
//        // UI 요소들 생성 및 레이아웃 설정
//        setupUI()
//        // 플레이어 시작 시 UI 초기 상태 설정
//        setStartUIStatus()
//        
//        // 화면 전체에 탭 제스처를 추가하여 UI 컨트롤 표시/숨김 토글
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleUIControls))
//        self.view.addGestureRecognizer(tapGestureRecognizer)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        // 뷰가 화면에 나타난 후 비디오 URL을 가져와 재생 설정
//        // 네트워크 URL을 사용하므로, viewDidAppear에서 호출하여 화면 로딩과 분리
//        // getNetworkVideoURL()이 nil을 반환할 수 있으므로 안전하게 처리 필요
//        if let videoURL = self.getNetworkVideoURL() {
//            setVideoView(url: videoURL)
//        } else {
//            // TODO: URL 로드 실패 시 사용자에게 알림 또는 오류 처리 로직 추가
//            print("Error: Could not get video URL.")
//        }
//        // UI 자동 숨김 타이머 시작
//        resetUITimer()
//    }
//    
//    // MARK: - UI Setup Methods
//    
//    /// 모든 UI 컨트롤을 담는 `totalBtnView`와 그 안의 요소들을 설정합니다.
//    func setupUI() {
//        // 전체 컨트롤 뷰 초기화 및 설정
//        totalBtnView = UIView()
//        totalBtnView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 반투명 검은색 배경
//        view.addSubview(totalBtnView) // 메인 뷰에 추가
//        // SnapKit을 사용하여 화면 전체를 덮도록 제약 설정 (초기에는 숨겨짐)
//        totalBtnView.snp.makeConstraints { make in
//            // make.edges.equalToSuperview() // 이전 코드: 전체를 덮음 -> 의도된 것인지 확인 필요
//            // 일반적으로 컨트롤 뷰는 하단이나 특정 영역에 위치하므로 수정 제안
//            make.leading.trailing.bottom.equalToSuperview() // 화면 하단에 고정
//            make.height.equalTo(100) // 예시 높이, 내부 요소에 따라 조절
//        }
//        
//        // 닫기 버튼 초기화 및 설정 (totalBtnView 바깥, 화면 상단에 위치)
//        closeButton = UIButton(type: .system) // @IBOutlet이 아니므로 여기서 인스턴스 생성
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .white
//        closeButton.addTarget(self, action: #selector(closeViewAction), for: .touchUpInside) // 액션 연결
//        view.addSubview(closeButton) // 메인 뷰에 직접 추가 (totalBtnView와 독립적)
//        closeButton.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
//            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(10)
//            make.width.height.equalTo(30)
//        }
//        
//        // 시간 표시 레이블 초기화 및 설정
//        timeLineLabel = UILabel() // @IBOutlet이 아니므로 여기서 인스턴스 생성
//        timeLineLabel.text = "00:00 / 00:00" // 초기 텍스트
//        timeLineLabel.textColor = .white
//        timeLineLabel.font = UIFont.systemFont(ofSize: 12)
//        timeLineLabel.textAlignment = .center
//        totalBtnView.addSubview(timeLineLabel) // totalBtnView에 추가
//        timeLineLabel.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().inset(10) // totalBtnView 하단에서 10만큼 안쪽
//            make.leading.equalToSuperview().inset(10) // totalBtnView 왼쪽에서 10만큼 안쪽
//        }
//        
//        // 재생/일시정지 버튼 초기화 및 설정
//        playButton = UIButton(type: .system) // @IBOutlet이 아니므로 여기서 인스턴스 생성
//        playButton.tintColor = .white
//        playButton.addTarget(self, action: #selector(clickPlayButton), for: .touchUpInside)
//        totalBtnView.addSubview(playButton)
//        playButton.snp.makeConstraints { make in
//            make.centerY.equalTo(timeLineLabel) // 시간 레이블과 세로 중앙 정렬
//            make.leading.equalTo(timeLineLabel.snp.trailing).offset(10) // 시간 레이블 오른쪽으로 10만큼 이동
//            make.width.height.equalTo(30) // 버튼 크기
//        }
//        
//        // 10초 뒤로가기 버튼 초기화 및 설정
//        minusTimeButton = UIButton(type: .system) // @IBOutlet이 아니므로 여기서 인스턴스 생성
//        minusTimeButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
//        minusTimeButton.tintColor = .white
//        minusTimeButton.addTarget(self, action: #selector(minus10Seconds), for: .touchUpInside)
//        totalBtnView.addSubview(minusTimeButton)
//        minusTimeButton.snp.makeConstraints { make in
//            make.centerY.equalTo(playButton) // 재생 버튼과 세로 중앙 정렬
//            make.leading.equalTo(playButton.snp.trailing).offset(10) // 재생 버튼 오른쪽으로 10만큼 이동
//            make.width.height.equalTo(30)
//        }
//        
//        // 10초 앞으로가기 버튼 초기화 및 설정
//        plusTimeButton = UIButton(type: .system)
//        plusTimeButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
//        plusTimeButton.tintColor = .white
//        plusTimeButton.addTarget(self, action: #selector(plus10Seconds), for: .touchUpInside)
//        totalBtnView.addSubview(plusTimeButton)
//        plusTimeButton.snp.makeConstraints { make in
//            make.centerY.equalTo(playButton) // 재생 버튼과 세로 중앙 정렬
//            make.leading.equalTo(minusTimeButton.snp.trailing).offset(10) // -10초 버튼 오른쪽으로 10만큼 이동
//            make.width.height.equalTo(30)
//        }
//        
//        // 배속 변경 버튼 초기화 및 설정
//        speedButton = UIButton(type: .system) // @IBOutlet이 아니므로 여기서 인스턴스 생성
//        speedButton.setTitleColor(.white, for: .normal)
//        speedButton.titleLabel?.font = .systemFont(ofSize: 13)
//        speedButton.addTarget(self, action: #selector(clickSpeedAction), for: .touchUpInside)
//        totalBtnView.addSubview(speedButton)
//        speedButton.snp.makeConstraints { make in
//            make.centerY.equalTo(playButton) // 재생 버튼과 세로 중앙 정렬
//            make.trailing.equalToSuperview().inset(10) // totalBtnView 오른쪽에서 10만큼 안쪽
//        }
//        
//        // 배속 표시 레이블 초기화 및 설정
//        speedDisplayLabel = UILabel() // @IBOutlet이 아니므로 여기서 인스턴스 생성
//        speedDisplayLabel.textColor = .white
//        speedDisplayLabel.font = .systemFont(ofSize: 13)
//        totalBtnView.addSubview(speedDisplayLabel)
//        speedDisplayLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(playButton) // 재생 버튼과 세로 중앙 정렬
//            make.trailing.equalTo(speedButton.snp.leading).offset(-5) // 배속 버튼 왼쪽으로 5만큼 이동
//        }
//        
//        // 타임 슬라이더 초기화 및 설정
//        timeLineSlider = UISlider()
//        timeLineSlider.minimumTrackTintColor = .red // 지나온 시간 트랙 색상
//        timeLineSlider.maximumTrackTintColor = .lightGray // 남은 시간 트랙 색상
//        timeLineSlider.thumbTintColor = .white // 슬라이더 핸들 색상
//        timeLineSlider.addTarget(self, action: #selector(timeLineValueChanged), for: .valueChanged)
//        totalBtnView.addSubview(timeLineSlider)
//        timeLineSlider.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(10) // totalBtnView 좌우로 10만큼 여백
//            make.bottom.equalTo(timeLineLabel.snp.top).offset(-10) // 시간 레이블 위로 10만큼 이동
//        }
//    }
//    
//    /// 플레이어 시작 시 UI 요소들의 초기 상태를 설정합니다.
//    func setStartUIStatus() {
//        totalBtnView.isHidden = true // 처음에는 컨트롤 뷰 숨김
//        timeLineLabel.text = "00:00 / 00:00" // 초기 시간 텍스트
//        timeLineSlider.value = 0.0 // 슬라이더 초기 위치
//        self.setSpeedModeWithLevel(level: 2) // 기본 배속 1.0x로 설정 (speedMode = 2)
//        self.setPlayButtonImage() // 초기 재생 버튼 이미지 설정 (보통 'play' 아이콘)
//    }
//    
//    // MARK: - Orientation
//    
//    /// 이 뷰 컨트롤러가 지원하는 화면 방향을 설정합니다. (가로 모드만 지원)
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .landscape
//    }
//    
//    // MARK: - Action Methods
//    
//    /// 닫기 버튼을 눌렀을 때 호출됩니다. 플레이어를 정지하고 현재 뷰 컨트롤러를 닫습니다.
//    @objc func closeViewAction() {
//        self.videoPlayer?.pause() // 플레이어 일시 정지
//        self.videoPlayer = nil // 플레이어 참조 해제 (메모리 관리)
//        self.dismiss(animated: true, completion: nil) // 현재 뷰 컨트롤러 닫기
//    }
//    
//    // MARK: - Video URL
//    
//    /// 네트워크 비디오 URL을 반환합니다. (현재는 고정된 샘플 URL 사용)
//    /// - Returns: 비디오 파일의 URL 또는 nil
//    func getNetworkVideoURL() -> URL? {
//        // TODO: 실제 서비스에서는 다양한 비디오 URL을 동적으로 받아오도록 수정 필요
//        return URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
//    }
//    
//    // MARK: - Player Setup
//    
//    /// 주어진 URL로 AVPlayer 및 AVPlayerLayer를 설정하고 비디오 재생을 준비합니다.
//    /// - Parameter url: 재생할 비디오의 URL
//    func setVideoView(url: URL) {
//        videoPlayer = AVPlayer(url: url) // AVPlayer 인스턴스 생성
//        let playerLayer = AVPlayerLayer(player: videoPlayer) // AVPlayerLayer 생성 및 AVPlayer 연결
//        
//        playerLayer.frame = videoBackView.bounds // videoBackView의 크기에 맞게 레이어 프레임 설정
//        playerLayer.videoGravity = .resizeAspect // 비디오 콘텐츠 비율 유지하며 표시
//        
//        // videoBackView에 이미 다른 AVPlayerLayer가 있다면 제거 (새 비디오 로드 시 중요)
//        videoBackView.layer.sublayers?.filter({ $0 is AVPlayerLayer }).forEach { $0.removeFromSuperlayer() }
//        videoBackView.layer.addSublayer(playerLayer) // videoBackView에 playerLayer 추가
//        
//        videoPlayer?.play() // 비디오 재생 시작
//        setPlayButtonImage() // 재생 상태에 맞춰 버튼 이미지 업데이트
//        
//        // 주기적인 시간 감지 옵저버 설정
//        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // 0.01초 간격
//        // 이전 옵저버가 있다면 제거
//        if let observer = timeObserver as? Any { // AnyObject에서 Any로 캐스팅하여 사용
//            videoPlayer?.removeTimeObserver(observer)
//            timeObserver = nil
//        }
//        // 새 옵저버 추가. [weak self]로 순환 참조 방지
//        timeObserver = videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] _ in
//            self?.updateVideoPlayerSlider() // 주기적으로 슬라이더 및 시간 레이블 업데이트
//        }) as AnyObject? // 반환 타입이 Any이므로 AnyObject로 캐스팅 (또는 Any로 프로퍼티 타입 변경)
//    }
//    
//    /// 비디오가 실제로 그려질 `videoBackView`를 설정합니다.
//    private func setupVideoBackView() {
//        videoBackView.backgroundColor = .black // 비디오 로딩 전 배경색
//        view.addSubview(videoBackView) // 메인 뷰에 추가
//        view.sendSubviewToBack(videoBackView) // 다른 UI 요소들 뒤로 보내 비디오가 배경처럼 보이도록 함
//        // SnapKit을 사용하여 화면 전체를 채우도록 제약 설정
//        videoBackView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//    
//    // MARK: - Layout
//    
//    /// 뷰의 하위 뷰들의 레이아웃이 결정된 후 호출됩니다. (예: 화면 회전 시)
//    /// `AVPlayerLayer`의 프레임을 `videoBackView`의 현재 크기에 맞게 업데이트합니다.
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // videoBackView의 layer 중 AVPlayerLayer를 찾아 프레임 업데이트
//        if let playerLayer = videoBackView.layer.sublayers?.first(where: {$0 is AVPlayerLayer}) as? AVPlayerLayer {
//            playerLayer.frame = videoBackView.bounds
//        }
//    }
//    
//    // MARK: - UI Timer Control
//    
//    /// UI 컨트롤 자동 숨김 타이머를 리셋(재시작)합니다.
//    func resetUITimer() {
//        uiTimer?.invalidate() // 기존 타이머가 있다면 무효화
//        // 5초 후에 hideUIControls 메서드를 호출하는 타이머 생성 (반복 안 함)
//        // 원래 코드: repeats: true -> UI가 계속 깜빡일 수 있음, false로 변경 제안
//        uiTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideUIControls), userInfo: nil, repeats: false)
//    }
//    
//    /// UI 컨트롤을 숨깁니다. (타이머에 의해 호출됨)
//    @objc func hideUIControls() {
//        totalBtnView.isHidden = true
//    }
//    
//    /// 화면 탭 시 UI 컨트롤의 표시/숨김 상태를 토글합니다.
//    @objc func toggleUIControls() {
//        totalBtnView.isHidden.toggle() // isHidden 상태 반전
//        if totalBtnView.isHidden {
//            uiTimer?.invalidate() // UI가 숨겨지면 타이머 중지
//        } else {
//            self.resetUITimer() // UI가 보이면 타이머 리셋 (다시 5초 후 숨김)
//        }
//    }
//    
//    // MARK: - Player UI Update
//    
//    /// 비디오 재생 시간에 맞춰 슬라이더와 시간 레이블을 업데이트합니다. (timeObserver에 의해 주기적으로 호출)
//    func updateVideoPlayerSlider() {
//        guard let player = videoPlayer, let currentItem = player.currentItem else { return }
//        
//        let duration: CMTime = currentItem.duration
//        let currentTime: CMTime = currentItem.currentTime()
//        
//        // 비디오 길이(duration)가 유효하지 않거나 무한대(라이브 스트리밍 등)인 경우 처리
//        if CMTIME_IS_INVALID(duration) || CMTIME_IS_INDEFINITE(duration) {
//            timeLineSlider.value = 0.0
//            timeLineLabel.text = "00:00 / --:--" // 알 수 없음을 표시
//            return
//        }
//        
//        let durationSeconds = CMTimeGetSeconds(duration)
//        let currentTimeSeconds = CMTimeGetSeconds(currentTime)
//        
//        // 슬라이더 값 업데이트 (현재 시간 / 전체 시간)
//        if durationSeconds > 0 { // 0으로 나누기 방지
//            timeLineSlider.value = Float(currentTimeSeconds / durationSeconds)
//        } else {
//            timeLineSlider.value = 0.0
//        }
//        // 시간 레이블 텍스트 업데이트
//        self.setTimeLabel()
//    }
//    
//    /// `timeLineLabel`의 텍스트를 현재 재생 시간과 전체 비디오 길이로 설정합니다.
//    func setTimeLabel() {
//        let currentTimeString = getVideoCurrentTime() ?? "00:00"
//        let totalTimeString = getVideoTotalTime() ?? "--:--" // 전체 길이를 알 수 없을 때
//        
//        timeLineLabel.text = "\(currentTimeString) / \(totalTimeString)"
//    }
//    
//    /// 비디오의 전체 길이를 "mm:ss" 형식의 문자열로 반환합니다.
//    func getVideoTotalTime() -> String? {
//        guard let duration = videoPlayer?.currentItem?.duration,
//              CMTIME_IS_VALID(duration), // 유효한 시간인지 확인
//              !CMTIME_IS_INDEFINITE(duration) // 무한대가 아닌지 확인
//        else { return nil } // 조건을 만족하지 않으면 nil 반환
//        
//        let totalSeconds = CMTimeGetSeconds(duration)
//        let minute = Int(floor(totalSeconds / 60)) // 분 계산
//        let second = Int(totalSeconds) % 60 // 초 계산 (60으로 나눈 나머지)
//        return setTimeString(times: minute) + ":" + setTimeString(times: second)
//    }
//    
//    /// 현재 재생된 시간을 "mm:ss" 형식의 문자열로 반환합니다.
//    func getVideoCurrentTime() -> String? {
//        guard let currentTime = videoPlayer?.currentTime(),
//              CMTIME_IS_VALID(currentTime),
//              !CMTIME_IS_INDEFINITE(currentTime) // 현재 시간도 무한대일 수 있음 (이론상)
//        else { return nil }
//        
//        let currentSeconds = CMTimeGetSeconds(currentTime)
//        let minute = Int(floor(currentSeconds / 60))
//        let second = Int(currentSeconds) % 60
//        return setTimeString(times: minute) + ":" + setTimeString(times: second)
//    }
//    
//    /// 정수형 시간을 두 자리 문자열("00")로 포맷팅합니다. (예: 5 -> "05")
//    func setTimeString(times: Int) -> String {
//        return String(format: "%02d", times)
//    }
//    
//    // MARK: - Slider Interaction
//    
//    /// 타임 슬라이더의 값이 변경되었을 때 호출됩니다. 비디오 재생 위치를 변경합니다.
//    @objc func timeLineValueChanged(_ slider: UISlider) {
//        guard let player = videoPlayer, let duration = player.currentItem?.duration else { return }
//        
//        let wasPlaying = player.isPlaying // 슬라이더 조작 전 재생 상태 저장
//        player.pause() // 슬라이더 조작 중에는 일시 정지
//        
//        // 슬라이더 값(0.0 ~ 1.0)에 전체 길이를 곱하여 목표 시간(초) 계산
//        let value = Float64(slider.value) * CMTimeGetSeconds(duration)
//        // CMTime으로 변환
//        let seekTime = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        
//        // 지정된 시간으로 비디오 탐색 (seek)
//        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] isFinished in
//            guard let self = self else { return } // self가 nil이 아닌지 확인
//            if isFinished { // 탐색이 완료되면
//                if wasPlaying { // 이전에 재생 중이었다면
//                    player.play() // 다시 재생
//                    self.setSpeedModeWithLevel(level: self.speedMode) // 현재 배속 유지
//                }
//            }
//            self.setPlayButtonImage() // 재생 버튼 이미지 업데이트
//        }
//        // 슬라이더 조작 시 UI 타이머 리셋
//        self.resetUITimer()
//    }
//    
//    // MARK: - Play/Pause Control
//    
//    /// 재생/일시정지 버튼을 눌렀을 때 호출됩니다.
//    @objc func clickPlayButton() {
//        guard let player = videoPlayer else { return }
//        
//        if player.isPlaying { // 현재 재생 중이면
//            player.pause() // 일시 정지
//        } else { // 현재 정지 또는 일시 정지 상태이면
//            player.play() // 재생
//            self.setSpeedModeWithLevel(level: self.speedMode) // 현재 설정된 배속으로 재생
//        }
//        self.setPlayButtonImage() // 버튼 이미지 업데이트
//        self.resetUITimer() // UI 타이머 리셋
//    }
//    
//    /// 현재 재생 상태에 따라 재생/일시정지 버튼의 이미지를 변경합니다.
//    func setPlayButtonImage() {
//        if videoPlayer?.isPlaying ?? false { // nil coalescing으로 안전하게 접근
//            self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//        } else {
//            self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        }
//    }
//    
//    // MARK: - Time Skip Control
//    
//    /// 10초 앞으로 비디오를 이동시킵니다.
//    @objc func plus10Seconds() {
//        self.setActionMoveSeconds(sec: 10.0) // TimeInterval 타입으로 전달
//        self.resetUITimer()
//    }
//    
//    /// 10초 뒤로 비디오를 이동시킵니다.
//    @objc func minus10Seconds() {
//        self.setActionMoveSeconds(sec: -10.0) // TimeInterval 타입으로 전달
//        self.resetUITimer()
//    }
//    
//    /// 지정된 시간(초)만큼 비디오 재생 위치를 이동시킵니다.
//    /// - Parameter sec: 이동할 시간 (양수: 앞으로, 음수: 뒤로)
//    func setActionMoveSeconds(sec: TimeInterval) {
//        guard let player = videoPlayer else { return }
//        
//        let currentTime = player.currentTime() // 현재 시간 가져오기
//        
//        let wasPlaying = player.isPlaying // 이동 전 재생 상태 저장
//        player.pause() // 이동 중에는 일시 정지
//        
//        // 현재 시간에 sec을 더하여 목표 시간 계산
//        let currentTimeInSecondsMove = CMTimeGetSeconds(currentTime).advanced(by: sec)
//        // CMTime으로 변환
//        let seekTime = CMTime(seconds: currentTimeInSecondsMove, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        
//        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] isFinished in
//            guard let self = self else { return }
//            if isFinished {
//                if wasPlaying { // 이전에 재생 중이었다면
//                    player.play() // 다시 재생
//                    self.setSpeedModeWithLevel(level: self.speedMode) // 현재 배속 유지
//                }
//            }
//            self.setPlayButtonImage() // 재생 버튼 이미지 업데이트
//        }
//    }
//    
//    // MARK: - Speed Control
//    
//    /// 배속 변경 버튼을 눌렀을 때 호출됩니다. 배속 단계를 순환시킵니다.
//    @objc func clickSpeedAction() {
//        // 현재 배속 모드에 따라 다음 배속 모드로 변경
//        // 1 (0.5x) -> 2 (1.0x) -> 3 (2.0x) -> 1 (0.5x) ...
//        // 원래 코드: case 1 -> level 1, case 2 -> level 2... -> speedMode 값을 직접 사용해도 됨
//        // speedMode가 1, 2, 3을 순환하도록 수정
//        speedMode += 1
//        if speedMode > 3 {
//            speedMode = 1
//        }
//        self.setSpeedModeWithLevel(level: speedMode)
//        self.resetUITimer() // UI 타이머 리셋
//    }
//    
//    /// 지정된 레벨에 따라 재생 배속을 설정하고 UI를 업데이트합니다.
//    /// - Parameter level: 설정할 배속 레벨 (1: 0.5x, 2: 1.0x, 3: 2.0x)
//    func setSpeedModeWithLevel(level: Int) {
//        guard let player = videoPlayer else { return }
//        
//        let rate: Float // 실제 AVPlayer에 설정될 재생 속도
//        let text: String // speedDisplayLabel에 표시될 텍스트
//        
//        self.speedMode = level // 내부 speedMode 변수 업데이트
//        
//        switch level {
//        case 1: // 0.5 배속
//            text = "x 0.5"
//            rate = 0.5
//        case 3: // 2.0 배속
//            text = "x 2.0"
//            rate = 2.0
//        case 2: // 1.0 배속 (기본값)
//            fallthrough // 아래 default 케이스와 동일하게 처리
//        default: // 그 외의 경우 (안전장치)
//            self.speedMode = 2 // speedMode도 기본값으로 재설정
//            text = "x 1.0"
//            rate = 1.0
//        }
//        
//        speedDisplayLabel.text = text // 배속 텍스트 업데이트
//        speedButton.setTitle(text, for: .normal) // 버튼에도 동일 텍스트 표시 제안
//        
//        // 현재 재생 중일 때만 playImmediately(atRate:) 호출, 아니면 rate만 설정
//        if player.isPlaying {
//            player.playImmediately(atRate: rate) // 즉시 지정된 속도로 재생 (또는 재생 계속)
//        } else {
//            player.rate = rate // 재생 시작 시 이 속도로 재생됨
//        }
//    }
//    
//    // MARK: - Deinitialization
//    
//    /// 뷰 컨트롤러가 메모리에서 해제될 때 호출됩니다. 옵저버 및 타이머를 정리합니다.
//    deinit {
//        // timeObserver가 Any? 타입이므로 Any로 캐스팅하여 사용
//        if let observer = timeObserver as? Any, let player = videoPlayer {
//            player.removeTimeObserver(observer) // 등록된 시간 옵저버 제거
//        }
//        uiTimer?.invalidate() // UI 타이머 무효화
//        print("CustomPlayerViewController deinit") // 해제 확인용 로그
//    }
//}
//
//// MARK: - SwiftUI Preview (Xcode 11+)
//// #Preview 매크로는 Xcode 15부터 사용 가능, 이전 버전에서는 PreviewProvider 사용
//// 현재 코드에서는 #Preview를 사용하고 있으므로, Xcode 15 환경으로 가정
//#Preview {
//    CustomVideoPlayerViewController()
//}
