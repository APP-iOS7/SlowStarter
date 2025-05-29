//
//  SlowChatViewController.swift
//  SlowStarter
//
//  Created by 멘태 on 5/13/25.
//

import UIKit
import Combine

enum Section {
    case main
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
            UICollectionView.CellRegistration { cell, _, message in
                cell.message = message
            }
        }()
        
        let receivedCellRegistration: UICollectionView.CellRegistration<ReceivedMessageCell, AIChatMessage> = {
            UICollectionView.CellRegistration { [weak self] cell, indexPath, message in
                cell.message = message
                cell.summaryButtom.addAction(UIAction { _ in
                    self?.viewModel.didTapSummaryButton(index: indexPath.row, message: message)
                }, for: .touchUpInside)
            }
        }()
        
        let loadingCellRegistration: UICollectionView.CellRegistration<LoadingCell, Void> = {
            UICollectionView.CellRegistration { cell, _, _ in
                cell.configure()
            }
        }()
        
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
        
        return dataSource
    }()
    
    private let inputContainerView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inputTextFieldView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inputTextField: UITextField = {
        let tf: UITextField = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.tintColor = .lightGray
        tf.placeholder = "메시지 보내기"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var sendButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        button.tintColor = .black
        button.contentMode = .scaleAspectFit
        button.backgroundColor = .green
        button.addAction(UIAction { [weak self] _ in
            self?.tappedSendButton()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var lastKeyboardVisibleHeight: CGFloat = 0
    
    private var isInitialLoad: Bool = true
    
    private var cellHeightCache: [UUID: CGFloat] = .init()
    
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
    
    // MARK: Functions
    private func setConstraints() {
        view.addSubview(collectionView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(inputTextFieldView)
        inputContainerView.addSubview(sendButton)
        inputTextFieldView.addSubview(inputTextField)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            inputTextFieldView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 5),
            inputTextFieldView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 10),
            inputTextFieldView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            inputTextFieldView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -5),
            
            inputTextField.topAnchor.constraint(equalTo: inputTextFieldView.topAnchor),
            inputTextField.leadingAnchor.constraint(equalTo: inputTextFieldView.leadingAnchor, constant: 10),
            inputTextField.trailingAnchor.constraint(equalTo: inputTextFieldView.trailingAnchor, constant: -10),
            inputTextField.bottomAnchor.constraint(equalTo: inputTextFieldView.bottomAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor)
        ])
        
        sendButton.layer.cornerRadius = 20
        inputTextFieldView.layer.cornerRadius = 20
    }
    
    private func setCollectionView() {
        collectionView.dataSource = dataSource
        
        // 섹션 추가
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
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
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .dropFirst() // viewModel에서 초기화 될 때 무시
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] newItems in
                guard let self = self else { return }
                let oldItems = self.dataSource.snapshot().itemIdentifiers(inSection: .main)
                
                self.cellHeightCache.removeAll() // cell size 다시 계산
                
                if case .message(let id) = oldItems.first,
                   let first = newItems.first {
                    if id == first.id { // 배열 뒤에 추가
                        self.applySnapshot(for: newItems)
                        return
                    } else { // 배열 앞에 추가(이전 대화)
                        self.applySnapshot(forPreviousMessages: newItems)
                        return
                    }
                }
                
                self.applySnapshot(for: newItems) // default: 배열 뒤에 추가
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
        viewModel.fetchMessages()
    }
    
    private func tappedSendButton() {
        guard let text: String = inputTextField.text else { return }
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
        viewModel.didTapSendButton(text: text)
    }
    
    private func scrollToLatestMessage() {
        let numberOfItems = dataSource.snapshot().numberOfItems(inSection: .main)
        guard numberOfItems > 0 else { return }
        
        let indexPath: IndexPath = IndexPath(item: numberOfItems - 1, section: 0)
        var position: UICollectionView.ScrollPosition = .bottom // 셀은 일반적으로 컬렉션뷰 바닥에 위치
        
        // 셀이 가진 제약에 근거해 셀의 layout 정보를 계산 (화면에 그려지지 않아도 ok)
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            let cellHeight: CGFloat = layoutAttributes.size.height
            let visibleHeight: CGFloat = collectionView.frame.height
            
            // 셀이 frame보다 크면서, 최초 진입 시가 아닐 때: 셀을 컬렉션뷰 상단에 위치
            if cellHeight > visibleHeight && !self.isInitialLoad { position = .top }
        }
        
        collectionView.scrollToItem(at: indexPath, at: position, animated: !self.isInitialLoad)
        collectionView.layoutIfNeeded() // UI 갱신
        
        if self.isInitialLoad { self.isInitialLoad = false } // 최초 진입 시
    }
    
    private func scrollToMessage(at index: Int) {
        let indexPath: IndexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        collectionView.layoutIfNeeded()
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
        
        // 컬렉션뷰에 영향을 주지 않는 SafeArea 영역 제거
        let calculatedKeyboardHeight: CGFloat = keyboardFrame.height - self.view.safeAreaInsets.bottom
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

extension ChatViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            if scrollView.isDragging || scrollView.isDecelerating { // 스크롤 중이거나, 관성으로 움직일 때
                viewModel.fetchMessages()
            }
        }
    }
}

// MARK: - DelegateFlowLayout
extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        let cellWidth: CGFloat =
        collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
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
}

// MARK: - Diffable DataSource
extension ChatViewController {
    // 컬렉션뷰 채팅셀 추가, 갱신
    private func applySnapshot(for messages: [AIChatMessage]) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        
        for message in messages {
            let id = ChatItemIdentifier.message(message.id)
            if snapshot.itemIdentifiers.contains(id) {
                snapshot.reconfigureItems([id]) // 이미 있는 cell을 다시 구성
            } else {
                snapshot.appendItems([id], toSection: .main) // 새로운 cell을 추가
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: !isInitialLoad) { [weak self] in
            self?.collectionView.layoutIfNeeded()
            self?.scrollToLatestMessage()
        }
    }
    
    // 이전 채팅셀 추가
    private func applySnapshot(forPreviousMessages messages: [AIChatMessage]) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        
        guard let firstItem = snapshot.itemIdentifiers.first,
              case .message(let id) = firstItem,
              let index = messages.firstIndex(where: { $0.id == id }) else { return }
        
        let previousMessages: [ChatItemIdentifier] = Array(messages[0..<index]).map { .message($0.id) }
        
        snapshot.insertItems(previousMessages, beforeItem: firstItem) // 이전 대화 추가
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.scrollToMessage(at: index)
        }
    }
    
    // 컬렉션뷰 로딩셀 추가, 삭제
    private func applyLoadingSnapshot(_ isLoading: Bool) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatItemIdentifier> = dataSource.snapshot()
        
        // isLoading = true 면
        if isLoading {
            if !snapshot.itemIdentifiers.contains(.loadingIndicator) { // 중복 추가 방지
                snapshot.appendItems([.loadingIndicator], toSection: .main) // 로딩셀 추가
            }
        } else { // isLoading = false
            // 로딩셀이 있으면
            if snapshot.itemIdentifiers.contains(.loadingIndicator) {
                snapshot.deleteItems([.loadingIndicator]) // 로딩셀 삭제
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.collectionView.layoutIfNeeded()
            self?.scrollToLatestMessage()
        }
    }
}
