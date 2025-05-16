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
        cv.delaysContentTouches = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.addGestureRecognizer(collectionViewTapGesture) // 키보드 down 제스쳐 추가
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    private let sendedCellRegistration: UICollectionView.CellRegistration<SendedMessageCell, Message> = {
        UICollectionView.CellRegistration { cell, _, message in
            cell.chat = message
        }
    }()
    
    private lazy var receivedCellRegistration: UICollectionView.CellRegistration<ReceivedMessageCell, Message> = {
        UICollectionView.CellRegistration { cell, indexPath, message in
            cell.chat = message
            cell.summaryButtom.addAction(UIAction { [weak self] _ in
                self?.viewModel.didTapSummaryButton(index: indexPath.row, message: message)
            }, for: .touchUpInside)
        }
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Message> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Message>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, message -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            if message.isSended {
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.sendedCellRegistration,
                    for: indexPath,
                    item: message
                )
            } else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.receivedCellRegistration,
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
        var snapshot: NSDiffableDataSourceSnapshot<Section, Message> = dataSource.snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func bindViewModel() {
        viewModel.addMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] message in
                self?.applySnapshot([message])
            }
            .store(in: &cancellables)
        
        viewModel.summaryMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] message in
                self?.updateSnapshot([message])
            }
            .store(in: &cancellables)
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
    private func applySnapshot(_ messages: [Message], animating: Bool = true) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, Message> = dataSource.snapshot()
        snapshot.appendItems(messages, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
    
    // 컬렉션뷰 데이터소스 수정
    private func updateSnapshot(_ messages: [Message], animating: Bool = true) {
        var snapshot: NSDiffableDataSourceSnapshot<Section, Message> = dataSource.snapshot()
        snapshot.reconfigureItems(messages)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
}
