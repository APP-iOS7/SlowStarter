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
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Cell Self-Sizing
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.delaysContentTouches = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.addGestureRecognizer(collectionViewTapGesture) // 키보드 down 제스쳐 추가
        cv.isUserInteractionEnabled = true // 상호작용 허용
        return cv
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, AIChatMessage.ID> = {
        let sendedCellRegistration: UICollectionView.CellRegistration<SendedMessageCell, AIChatMessage> = {
            UICollectionView.CellRegistration { cell, _, message in
                cell.chat = message
            }
        }()
        
        let receivedCellRegistration: UICollectionView.CellRegistration<ReceivedMessageCell, AIChatMessage> = {
            UICollectionView.CellRegistration { [weak self] cell, indexPath, message in
                cell.chat = message
                cell.summaryButtom.addAction(UIAction { _ in
                    self?.viewModel.didTapSummaryButton(index: indexPath.row, message: message)
                }, for: .touchUpInside)
            }
        }()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, AIChatMessage.ID>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, id -> UICollectionViewCell? in
            guard let message: AIChatMessage = self?.viewModel.messageWith(id: id) else { return nil }
            
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
        var snapshot: NSDiffableDataSourceSnapshot<Section, AIChatMessage.ID> = dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.messageIDs)
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
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] messages in
                guard let self = self else { return }
                
                self.applySnapshot(messages)
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
    
    // 컬렉션뷰 최근 메시지로 이동
    private func scrollToLatestMessage(at index: Int) {
        guard let item: AIChatMessage = viewModel.messageAt(index: index) else { return }
        var indexPath: IndexPath = IndexPath(item: index, section: 0)
        var position: UICollectionView.ScrollPosition = .bottom
        
        if item.isSended {
            guard let cell: SendedMessageCell = collectionView.cellForItem(at: indexPath)
                    as? SendedMessageCell else { return }
            
            if cell.getMessageLableHeight() > collectionView.frame.height { position = .top }
        } else {
            guard let cell: ReceivedMessageCell = collectionView.cellForItem(at: indexPath)
                    as? ReceivedMessageCell else { return }
            
            if cell.getMessageLableHeight() > collectionView.frame.height {
                position = .top
                indexPath = IndexPath(item: index - 1, section: 0)
            }
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: position,
            animated: true
        )
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
            // 컨텐츠 사이즈가 화면보다 크지 않은 경우 0 반환
            let maxOffsetY = max(0, self.collectionView.contentSize.height - self.collectionView.frame.height)
            
            // 이미 최대로 스크롤 돼있으면 움직이지 않음
            if maxOffsetY == self.collectionView.contentOffset.y {
                self.lastKeyboardVisibleHeight = 0 // 키보드 이벤트 종료
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

// MARK: - Diffable DataSource
extension ChatViewController {
    // 컬렉션뷰 데이터소스 추가
    private func applySnapshot(_ messages: [AIChatMessage], animating: Bool = true) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, AIChatMessage.ID> = dataSource.snapshot()
        
        for message in messages {
            if snapshot.itemIdentifiers.contains(message.id) {
                snapshot.reconfigureItems([message.id]) // 이미 있는 cell을 다시 구성
            } else {
                snapshot.appendItems([message.id], toSection: .main) // 새로운 cell을 추가
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animating) { [weak self] in
            self?.scrollToLatestMessage(at: messages.count - 1)
        }
    }
}
