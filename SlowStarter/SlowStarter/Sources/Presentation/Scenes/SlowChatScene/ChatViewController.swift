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
    private var messages: [ChatMessage] = []
    
    private let sendedCellIdentifier: String = "SendedChatCell"
    private let receivedCellIdentifier: String = "ReceivedChatCell"
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private lazy var collectionViewTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCollectionView))
        return tap
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Cell Self-Sizing
        let cv: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.register(SendedChatCell.self, forCellWithReuseIdentifier: sendedCellIdentifier)
        cv.register(ReceivedChatCell.self, forCellWithReuseIdentifier: receivedCellIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.addGestureRecognizer(collectionViewTapGesture) // 키보드 down 제스쳐 추가
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ChatMessage> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, ChatMessage>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, chatMessage in
            
            if chatMessage.isSended {
                // SendedChatCell
                guard let self = self,
                      let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: self.sendedCellIdentifier,
                        for: indexPath
                      ) as? SendedChatCell else {
                    return UICollectionViewCell()
                }
                
                cell.chat = chatMessage
                return cell
            } else {
                // ReceivedChatCell
                guard let self = self,
                      let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: self.receivedCellIdentifier,
                        for: indexPath
                      ) as? ReceivedChatCell else {
                    return UICollectionViewCell()
                }
                
                cell.chat = chatMessage
                return cell
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
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatMessage> = dataSource.snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func bindViewModel() {
        viewModel.chatPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    let errorMessage: ChatMessage = ChatMessage(
                        text: error.localizedDescription,
                        isSended: false, timestamp: Date()
                    )
                    self.messages.append(errorMessage)
                    self.applySnapshot(messages: [errorMessage])
                }
            }, receiveValue: { [weak self] newMessage in
                guard let self = self else { return }
                self.messages.append(newMessage)
                self.applySnapshot(messages: [newMessage])
            })
        
            .store(in: &cancellables)
    }
    
    // 컬렉션뷰 데이터소스 갱신
    private func applySnapshot(messages: [ChatMessage], animating: Bool = true) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, ChatMessage> = dataSource.snapshot()
        snapshot.appendItems(messages, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
    
    private func tappedSendButton() {
        guard let text: String = inputTextField.text else { return }
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
        viewModel.didTapSendButton(message: text)
    }
    
    // MARK: - Selectors
    @objc private func tappedCollectionView() {
        view.endEditing(true) // 키보드 down
    }
}
