//
//  SlowChatViewController.swift
//  SlowStarter
//
//  Created by 멘태 on 5/13/25.
//

import UIKit
import Combine

enum Section: Hashable {
    case date(Date)
}

enum ChatItemIdentifier: Hashable {
    case message(UUID)
    case loadingIndicator
}

final class ChatViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: ChatViewModel
    
    weak var coordinator: ChatCoordinator?
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private lazy var collectionViewTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCollectionView))
        return tap
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 5 // 셀 간격
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.delaysContentTouches = false
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.addGestureRecognizer(collectionViewTapGesture) // 키보드 down 제스쳐 추가
        cv.isUserInteractionEnabled = true // 상호작용 허용
        return cv
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ChatItemIdentifier> = {
        let sendedCellRegistration: UICollectionView.CellRegistration<SendedMessageCell, AIChatMessage> = {
            UICollectionView.CellRegistration { [weak self] cell, _, message in
                guard let self = self else { return }
                
                cell.message = message // 메시지 주입
                cell.setPreferredMaxLayoutWidth(forCellWidth: self.collectionView.frame.width) // 최대 width 설정
            }
        }()
        
        let receivedCellRegistration: UICollectionView.CellRegistration<ReceivedMessageCell, AIChatMessage> = {
            UICollectionView.CellRegistration { [weak self] cell, _, message in
                guard let self = self else { return }
                
                cell.message = message // 메시지 주입
                cell.summaryButtom.addAction(UIAction { _ in
                    self.isLoadingSummaryMessage = true // 요약중인 상태 표시
                    self.viewModel.didTapSummaryButton(message: message) // 텍스트 요약 요청 전송
                    cell.showSummaryLoading(self.isLoadingSummaryMessage) // indicator start, stop
                }, for: .touchUpInside)
                cell.setPreferredMaxLayoutWidth(forCellWidth: self.collectionView.frame.width) // 최대 width 설정
            }
        }()
        
        let loadingCellRegistration: UICollectionView.CellRegistration<LoadingCell, Void> = {
            UICollectionView.CellRegistration { cell, _, _ in
                cell.configure()
            }
        }()
        
        let dateHeaderRegistration = UICollectionView.SupplementaryRegistration<DateHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, _, indexPath in
            guard let self = self else { return }
            
            let snapshot = self.dataSource.snapshot()
            let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
            
            if case .date(let date) = sectionIdentifier {
                headerView.configure(date)
            }
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, ChatItemIdentifier>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, identifier -> UICollectionViewCell? in
            
            switch identifier {
            case .message(let id):
                guard let message: AIChatMessage = self?.viewModel.message(with: id) else { return nil }
                
                if message.isSended {
                    return collectionView.dequeueConfiguredReusableCell(
                        using: sendedCellRegistration,
                        for: indexPath,
                        item: message
                    )
                } else {
                    return collectionView.dequeueConfiguredReusableCell(
                        using: receivedCellRegistration,
                        for: indexPath,
                        item: message
                    )
                }
            case .loadingIndicator:
                return collectionView.dequeueConfiguredReusableCell(
                    using: loadingCellRegistration,
                    for: indexPath,
                    item: ()
                )
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: dateHeaderRegistration,
                for: indexPath
            )
        }
        
        return dataSource
    }()
    
    private let inputContainerView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var inputTextView: UITextView = {
        let tv: UITextView = UITextView()
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.spellCheckingType = .no
        tv.tintColor = .lightGray
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .systemGray6
        tv.textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var sendButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "paperplane.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12)
        config.baseForegroundColor = UIColor(named: "SubColor1")
        config.baseBackgroundColor = UIColor(named: "MainColor")
        config.cornerStyle = .capsule
        button.configuration = config
        button.contentMode = .scaleAspectFit
        button.addAction(UIAction { [weak self] _ in
            self?.tappedSendButton()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var bottomButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.down")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(named: "SubColor1")
        config.cornerStyle = .capsule
        button.configuration = config
        button.alpha = 0.0
        button.contentMode = .scaleAspectFit
        button.addAction(UIAction { [weak self] _ in
            self?.scrollToLatestMessage()
        }, for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var lastKeyboardVisibleHeight: CGFloat = 0 // 키보드 높이
    private var isInitialLoad: Bool = true // 초기화 상태
    private var isLoadingPreviousMessages: Bool = false // 이전 대화가 추가 되는 상태
    private var isLoadingSummaryMessage: Bool = false // 메시지가 요약중인 상태
    private var anchorMessageID: UUID? // 이전 대화를 추가하는 기준이 되는 메시지 id
    private var cellHeightCache: [UUID: CGFloat] = .init() // 셀 높이를 저장 배열
    private var previousTextViewHeight: CGFloat = 0.0 // 텍스트뷰의 이전 높이
    private var inputTextViewHeightConstraint: NSLayoutConstraint! // 텍스트뷰 높이 동적 할당 변수
    
    // MARK: - Initializer
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setConstraints()
        setCollectionView()
        setKeyboardNotifications()
        bindViewModel()
        fetchMessages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previousTextViewHeight = previousTextViewHeight == 0 ? inputTextView.frame.height : previousTextViewHeight
    }
    
    // 화면이 회전될 때 컬렉션뷰를 다시 그림
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { [weak self] _ in
            self?.cellHeightCache.removeAll() // 셀 높이를 다시 계산하도록 캐시 삭제
            self?.collectionView.reloadData() // (비효율적) 셀 재구성
        }
    }
    
    // MARK: Functions
    private func setConstraints() {
        view.addSubview(collectionView)
        view.addSubview(inputContainerView)
        view.addSubview(bottomButton)
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(sendButton)
        
        // 텍스트뷰 초기 높이가 콘텐트 사이즈에 맞도록 설정
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalTo: sendButton.heightAnchor)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            inputContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 55),
            
            inputTextView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 10),
            inputTextView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 10),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            inputTextView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -10),
            inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            inputTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 35),
            sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor),
            
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            bottomButton.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -10),
            bottomButton.widthAnchor.constraint(equalToConstant: 35),
            bottomButton.heightAnchor.constraint(equalTo: bottomButton.widthAnchor)
        ])
        
        inputTextView.layer.cornerRadius = 15
    }
    
    private func setCollectionView() {
        collectionView.dataSource = dataSource
    }
    
    private func setKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func bindViewModel() {
        viewModel.messageUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.cellHeightCache.removeAll() // 이미 계산된 셀 크기를 다시 계산
                
                switch update {
                case .initialLoad(let messages):
                    self?.initialLoad(for: messages)
                case .append(let message):
                    self?.append(for: message)
                case .prepend(let messages):
                    self?.prepend(for: messages)
                case .summarize(let messageID):
                    self?.summarize(with: messageID)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst() // viewModel에서 초기화 될 때 무시
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.sendButton.isEnabled = false // 로딩중일 때 메시지 전송 x
                    self?.sendButton.backgroundColor = .systemGray6
                } else {
                    self?.sendButton.isEnabled = true
                    self?.sendButton.backgroundColor = .green
                }
                
                self?.applyLoadingSnapshot(isLoading) // 로딩셀 추가, 삭제
            }
            .store(in: &cancellables)
    }
    
    private func fetchMessages() {
        viewModel.initialFetchMessages()
    }
    
    private func tappedSendButton() {
        guard let text: String = inputTextView.text, !text.isEmpty else { return }
        
        inputTextView.text = ""
        inputTextView.resignFirstResponder()
        viewModel.didTapSendButton(text: text)
    }
    
    // anchor를 걸어둔 셀 아이템으로 이동
    private func scrollToCurrentMessage() {
        guard let anchorID = anchorMessageID,
              let indexPath = dataSource.indexPath(for: .message(anchorID)) else { return }
        
        collectionView.layoutIfNeeded() // UI 변동사항을 갱신하고 작업 시작
        collectionView.scrollToItem(at: indexPath, at: .top, animated: false) // 스크롤
        collectionView.contentOffset.y -= 50 // 하단이 가리지 않도록
        
        anchorMessageID = nil // anchor 삭제
        isLoadingPreviousMessages = false // 로딩 종료
    }
    
    // 최하단 셀 아이템으로 이동
    private func scrollToLatestMessage() {
        let snapshot = dataSource.snapshot()
        
        guard let lastSectionID = snapshot.sectionIdentifiers.last else { return }
        
        let indexPath: IndexPath = IndexPath(
            item: snapshot.numberOfItems(inSection: lastSectionID) - 1,
            section: snapshot.sectionIdentifiers.count - 1
        )
        
        var position: UICollectionView.ScrollPosition = .bottom // 셀은 일반적으로 컬렉션뷰 바닥에 위치
        
        // 셀이 가진 제약에 근거해 셀의 layout 정보를 계산 (화면에 그려지지 않아도 ok)
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            let cellHeight: CGFloat = layoutAttributes.size.height
            let visibleHeight: CGFloat = collectionView.frame.height
            
            // 셀이 frame보다 크면서, 최초 진입 시가 아닐 때: 셀을 컬렉션뷰 상단에 위치
            if cellHeight > visibleHeight && !self.isInitialLoad { position = .top }
        }
        
        collectionView.layoutIfNeeded() // UI 변동사항을 갱신하고 작업 시작
        collectionView.scrollToItem(at: indexPath, at: position, animated: !self.isInitialLoad) // 스크롤
        
        isInitialLoad = false
    }
    
    // MARK: - Selectors
    @objc private func tappedCollectionView() {
        view.endEditing(true) // 키보드 down
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard lastKeyboardVisibleHeight == 0 else { return } // 키보드가 이미 올라온 경우: 처리 x, (이중 동작 방지)
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        
        // 컬렉션뷰에 영향을 주지 않는 TabBar 영역 제거
        let tabBarHeight: CGFloat = tabBarController?.tabBar.frame.size.height ?? 0.0
        let calculatedKeyboardHeight: CGFloat = keyboardFrame.height - tabBarHeight
        guard calculatedKeyboardHeight > 0 else { return } // 계산된 키보드 높이가 0 이하일 때 처리 x
        
        self.lastKeyboardVisibleHeight = calculatedKeyboardHeight // 키보드 이벤트 시작
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            
            // 움직임이 예상되는 정도
            let targetOffsetY = self.collectionView.contentOffset.y + lastKeyboardVisibleHeight
            
            // 최대 스크롤 수치 (컨텐츠 사이즈 - 프레임 사이즈)
            // 컨텐츠 사이즈가 화면보다 크지 않은 경우 0 반환
            let maxOffsetY = max(0, self.collectionView.contentSize.height - self.collectionView.frame.height)
            
            // 최대 스크롤 영역을 벗어나는 것을 방지
            let newOffsetY = min(targetOffsetY, maxOffsetY)
            
            self.collectionView.contentOffset.y = newOffsetY // offset 적용
            self.view.layoutIfNeeded() // UI 갱신
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard lastKeyboardVisibleHeight > 0 else { return } // 키보드가 올라오지 않은 경우: 처리 x, (이중 동작 방지)
        
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            
            // 최대 스크롤 수치 (컨텐츠 사이즈 - 프레임 사이즈)
            let maxOffsetY = max(0, self.collectionView.contentSize.height - self.collectionView.frame.height)
            
            // contentOffset이 최하단에 가까울 때 위치 조정 x
            if self.collectionView.contentOffset.y > maxOffsetY - 10 {
                self.lastKeyboardVisibleHeight = 0
                return
            }
            
            let targetOffsetY = self.collectionView.contentOffset.y - lastKeyboardVisibleHeight // 움직임이 예상되는 정도
            let newOffsetY = max(targetOffsetY, 0) // 최소 스크롤 영역을 벗어나는 것을 방지
            
            self.collectionView.contentOffset.y = newOffsetY // offset 적용
            self.view.layoutIfNeeded() // UI 갱신
            
            self.lastKeyboardVisibleHeight = 0 // 키보드 이벤트 종료
        }
    }
}

// MARK: - CollectionView Delegate
extension ChatViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 1. 이전 대화 불러오기 (스크롤이 맨 위에 도달했을 때)
        if scrollView.contentOffset.y <= 0 {
            if scrollView.isDragging && !isLoadingPreviousMessages { // 스크롤 중이거나, 관성으로 움직일 때
                isLoadingPreviousMessages = true // 중복 동작 방지
                
                guard let firstIndexPath = collectionView.indexPathsForVisibleItems.sorted().first,
                      let firstIdentifier = dataSource.itemIdentifier(for: firstIndexPath),
                      case .message(let id) = firstIdentifier else { return } // 최상위 cell id
                
                anchorMessageID = id // 스크롤이 고정될 cell id
                viewModel.fetchPreviousMessages() // 이전 대화 불러옴
            }
        }
        
        // 2. 바텀 버튼 노출, 숨김 (스크롤이 맨 밑에 있지 않을 때)
        let maxOffsetY: CGFloat = scrollView.contentSize.height - scrollView.frame.height // 최하단 오프셋
        let threshHold: CGFloat = 500.0 // 임계값
        
        // contentSize가 충분히 크지 않으면 종료
        if scrollView.contentSize.height < scrollView.frame.height + threshHold { return }
        
        if scrollView.contentOffset.y < maxOffsetY - threshHold { // 스크롤이 밑에서 500 이상 위에 있을 때
            bottomButton.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut]) { [weak self] in
                self?.bottomButton.alpha = 1.0 // 버튼 표시
            }
        } else if scrollView.contentOffset.y >= maxOffsetY - 10 { // 스크롤이 맨 밑에 위치할 때
            bottomButton.isHidden = true
            bottomButton.alpha = 0.0 // 버튼 숨김
        }
    }
}

// MARK: - DelegateFlowLayout
extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        let cellWidth: CGFloat = collectionView.bounds.width
        
        // 로딩셀인 경우 정해진 고정 size를 반환
        guard case .message(let id) = item else {
            return CGSize(width: cellWidth, height: 60)
        }
        
        // 저장된 height가 있으면 그대로 사용
        if let cachedHeight = cellHeightCache[id] {
            return CGSize(width: cellWidth, height: cachedHeight)
        }
        
        guard let message: AIChatMessage = viewModel.message(with: id) else { return .zero }
        
        // 저장된 height가 없으면 계산
        if message.isSended {
            let dummyCell: SendedMessageCell = SendedMessageCell()
            dummyCell.message = message
            dummyCell.setPreferredMaxLayoutWidth(forCellWidth: collectionView.bounds.width)
            
            let autoLayoutSize = dummyCell.contentView.systemLayoutSizeFitting(
                CGSize(width: cellWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            
            let calculatedHeight = autoLayoutSize.height
            cellHeightCache[id] = calculatedHeight
            
            return CGSize(width: cellWidth, height: calculatedHeight)
        } else {
            let dummyCell: ReceivedMessageCell = ReceivedMessageCell()
            dummyCell.message = message
            dummyCell.setPreferredMaxLayoutWidth(forCellWidth: collectionView.bounds.width)
            
            let autoLayoutSize = dummyCell.contentView.systemLayoutSizeFitting(
                CGSize(width: cellWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            
            let calculatedHeight = autoLayoutSize.height
            cellHeightCache[id] = calculatedHeight
            
            return CGSize(width: cellWidth, height: calculatedHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
}

// MARK: - Diffable DataSource
extension ChatViewController {
    // 초기 메시지 배열 추가
    private func initialLoad(for messages: [AIChatMessage]) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = NSDiffableDataSourceSnapshot()
        
        // 날짜별로 그룹핑, 오름차 순으로 정렬
        let groupedMessages = Dictionary(grouping: viewModel.messages) { message -> Date in
            return Calendar.current.startOfDay(for: message.timestamp)
        }
        let sortedDates = groupedMessages.keys.sorted { $0 < $1 }
        
        // 날짜 섹션별로 추가
        for date in sortedDates {
            let section = Section.date(date) // 추가될 섹션 정의
            snapshot.appendSections([section]) // 섹션을 스냅샷에 추가
            
            // 섹션에 들어갈 메시지 식별자
            let messagesInSection = groupedMessages[date]?
                .sorted { $0.timestamp < $1.timestamp }
                .map { ChatItemIdentifier.message($0.id) }
            
            if let items = messagesInSection, !items.isEmpty {
                snapshot.appendItems(items, toSection: .date(date)) // 섹션에 메시지 추가
            }
        }
        
        // 스냅샷 변경점 적용
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.scrollToLatestMessage() // 마지막 메시지로 스크롤
        }
    }
    
    // 새 메시지 추가
    private func append(for message: AIChatMessage) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        let section: Section = .date(Calendar.current.startOfDay(for: message.timestamp)) // 추가될 섹션
        let itemIdentifier: ChatItemIdentifier = .message(message.id) // 추가될 메시지 식별자
        
        // 섹션이 없으면 섹션 추가
        if !snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendSections([section])
        }
        
        // 아직 추가되지 않은 메시지일때
        if !snapshot.itemIdentifiers.contains(itemIdentifier) {
            snapshot.appendItems([itemIdentifier], toSection: section) // 섹션에 메시지 추가
        }
        
        // dataSource에 적용
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.scrollToLatestMessage() // 마지막 메시지로 스크롤
        }
    }
    
    // 이전 메시지 배열 추가
    private func prepend(for messages: [AIChatMessage]) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        
        guard let firstSection = snapshot.sectionIdentifiers.first else { return }
        
        // 날짜별로 그룹핑, 오름차 순으로 정렬
        let groupedMessages = Dictionary(grouping: messages) { message -> Date in
            return Calendar.current.startOfDay(for: message.timestamp)
        }
        let sortedDates = groupedMessages.keys.sorted { $0 < $1 }
        
        for date in sortedDates {
            let section: Section = .date(date) // 추가할 섹션
            
            // 섹션이 없으면 섹션 추가
            if !snapshot.sectionIdentifiers.contains(section) {
                snapshot.insertSections([section], beforeSection: firstSection)
            }
            
            let itemsInSection: [ChatItemIdentifier]? = groupedMessages[date]?
                .sorted { $0.timestamp < $1.timestamp } // 시간을 기준으로 오름차순 정렬
                .map { .message($0.id) } // 메시지 식별자로 타입 변경
            
            guard let items = itemsInSection else { return }
            
            // 추가할 섹션이 비어있지 않으면
            if let existingFirstItem = snapshot.itemIdentifiers(inSection: section).first {
                snapshot.insertItems(items, beforeItem: existingFirstItem) // 섹션의 첫 메시지 이전에 추가
            } else { // 섹션이 비어있으면
                snapshot.appendItems(items, toSection: section) // 섹션에 메시지 배열 추가
            }
        }
        
        // dataSource에 적용
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.scrollToCurrentMessage() // 현재 위치로 스크롤 고정
        }
    }
    
    // 요약 메시지 셀 재생성
    private func summarize(with id: UUID) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        let itemIdentifier: ChatItemIdentifier = .message(id) // 변경될 메시지 식별자
        
        // 아이템이 snapshot에 존재하는 경우
        if snapshot.itemIdentifiers.contains(itemIdentifier) {
            snapshot.reloadItems([itemIdentifier]) // 메시지 셀 재생성
        }
        
        // dataSource에 적용
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // 컬렉션뷰 로딩셀 추가, 삭제
    private func applyLoadingSnapshot(_ isLoading: Bool) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        guard let section = snapshot.sectionIdentifiers.last else { return }
        
        // isLoading = true 면
        if isLoading {
            if !snapshot.itemIdentifiers.contains(.loadingIndicator) { // 중복 추가 방지
                snapshot.appendItems([.loadingIndicator], toSection: section) // 로딩셀 추가
            }
        } else { // isLoading = false
            // 로딩셀이 있으면
            if snapshot.itemIdentifiers.contains(.loadingIndicator) {
                snapshot.deleteItems([.loadingIndicator]) // 로딩셀 삭제
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.scrollToLatestMessage() // 마지막 메시지로 이동
        }
    }
}

// MARK: - TextViewDelegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print("didChange!")
        
        let maxHeight: CGFloat = 200.0 // 텍스트뷰의 최대 높이
        var newHeight: CGFloat = // 변경될 텍스트뷰의 높이
            textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)).height
        
        if newHeight >= maxHeight { // 스크롤 사이즈가 최대 사이즈보다 커지면
            textView.isScrollEnabled = true // 스크롤 허용
            newHeight = maxHeight // 최대 크기로 고정
        } else {
            textView.isScrollEnabled = false // 작으면 스크롤 x
        }
        
        let heightDifference: CGFloat = newHeight - previousTextViewHeight // 높이 차이
        if heightDifference == 0 { return } // 차이가 없으면 종료
        
        let currentOffsetY: CGFloat = collectionView.contentOffset.y // 현재 오프셋
        let newOffsetY: CGFloat = currentOffsetY + heightDifference // 새 오프셋
        collectionView.contentOffset.y = newOffsetY // 오프셋 조정
        
        previousTextViewHeight = newHeight // 다음 동작을 위해 현재 값 저장
    }
}
