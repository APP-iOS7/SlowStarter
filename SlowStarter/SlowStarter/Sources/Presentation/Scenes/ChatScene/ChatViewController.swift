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
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Messages.ID> = {
        let sendedCellRegistration: UICollectionView.CellRegistration<SendedMessageCell, Messages> = {
            UICollectionView.CellRegistration { cell, _, message in
                cell.chat = message
            }
        }()
        
        let receivedCellRegistration: UICollectionView.CellRegistration<ReceivedMessageCell, Messages> = {
            UICollectionView.CellRegistration { [weak self] cell, indexPath, message in
                cell.chat = message
                cell.summaryButtom.addAction(UIAction { _ in
                    self?.viewModel.didTapSummaryButton(index: indexPath.row, message: message)
                }, for: .touchUpInside)
            }
        }()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Messages.ID>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, id -> UICollectionViewCell? in
            guard let message: Messages = self?.viewModel.message(with: id) else { return nil }
            
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
    
    // MARK: - LifeCycle
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setConstraints()
        setCollectionView()
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
        let messageIds: [Messages.ID] = viewModel.allMessages.map { $0.id }
        var snapshot: NSDiffableDataSourceSnapshot<Section, Messages.ID> = dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(messageIds)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func bindViewModel() {
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] messages in
                guard let self = self else { return }
                
                messages.forEach { message in
                    self.applySnapshot(message.id)
                }
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
    
    // MARK: - Selectors
    @objc private func tappedCollectionView() {
        view.endEditing(true) // 키보드 down
    }
}

// MARK: - Diffable DataSource
extension ChatViewController {
    // 컬렉션뷰 데이터소스 추가
    private func applySnapshot(_ id: Messages.ID, animating: Bool = true) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, Messages.ID> = dataSource.snapshot()
                
        if snapshot.itemIdentifiers.contains(id) {
            snapshot.reconfigureItems([id]) // 이미 있는 cell을 다시 구성
        } else {
            snapshot.appendItems([id], toSection: .main) // 새로운 cell을 추가
        }
        
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
}
