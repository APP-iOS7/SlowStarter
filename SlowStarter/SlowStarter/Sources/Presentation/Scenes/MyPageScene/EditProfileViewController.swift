import UIKit
import PhotosUI
import UniformTypeIdentifiers

@MainActor
class EditProfileViewController: UIViewController {

    // MARK: - UI Components
    private var profileImageView = UIImageView()
    private var nameTextField = UITextField()
    private var saveButton = UIButton(type: .system)
    private let deleteAccountButton = UIButton(type: .system)

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Properties
    var coordinator: MyPageCoordinator?
    private var originalUser: Users?
    private var originalProfileImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "프로필 수정"

        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = UIColor(hex: "#FEDBD0")
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)

        nameTextField.placeholder = "이름"
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocapitalizationType = .none

        saveButton.setTitle("저장하기", for: .normal)
        
        saveButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        saveButton.setTitleColor(UIColor(hex: "#442C2E"), for: .normal)
        saveButton.backgroundColor = UIColor(hex: "#FEDBD0")
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)

        deleteAccountButton.setTitle("회원탈퇴하기", for: .normal)
        deleteAccountButton.setTitleColor(.systemRed, for: .normal)
        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        deleteAccountButton.addTarget(self, action: #selector(handleDeleteAccountTapped), for: .touchUpInside)

        [profileImageView, nameTextField, saveButton, deleteAccountButton, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            deleteAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteAccountButton.leadingAnchor.constraint(equalTo: saveButton.leadingAnchor),
            deleteAccountButton.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 44),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Data Handling
    private func loadUserProfile() {
        activityIndicator.startAnimating()
        Task {
            do {
                guard let userFromDB = try await SupabaseDataManager.shared.fetchUserInfo() else {
                    showToast(message: "사용자 정보를 불러올 수 없습니다.")
                    handleLoadCompletion(user: nil, image: nil)
                    return
                }

                let profileImage = await loadImage(from: userFromDB.profileImageURL)
                handleLoadCompletion(user: userFromDB, image: profileImage)

            } catch {
                showToast(message: "프로필 로딩 오류: \(error.localizedDescription)")
                handleLoadCompletion(user: nil, image: nil)
            }
        }
    }

    private func handleLoadCompletion(user: Users?, image: UIImage?) {
        activityIndicator.stopAnimating()
        self.originalUser = user
        self.nameTextField.text = user?.name
        let finalImage = image ?? UIImage(systemName: "person.circle")
        self.profileImageView.image = finalImage
        self.originalProfileImage = finalImage
    }

    private func loadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) else {
            return nil
        }

        if let cachedImage = ImageCacheManager.shared.get(for: urlString) {
            return cachedImage
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            ImageCacheManager.shared.set(image, for: urlString)
            return image
        } catch {
            return nil
        }
    }

    // MARK: - Actions
    @objc private func selectProfileImage() {
        activityIndicator.startAnimating()
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func saveProfile() {
        guard let editedName = nameTextField.text, !editedName.isEmpty else {
            showToast(message: "이름을 입력해주세요.")
            return
        }

        guard let originalUser = originalUser else {
            showToast(message: "사용자 정보를 찾을 수 없습니다. 다시 시도해주세요.")
            return
        }

        let changes = determineProfileChanges(newName: editedName)

        guard changes.nameChanged || changes.imageState != .unchanged else {
            showToast(message: "변경된 내용이 없습니다.")
            return
        }

        setSavingUIState(isSaving: true)

        Task {
            do {
                let newImageURL = try await handleImageStorageUpdate(for: changes.imageState, userId: originalUser.userId)
                try await updateSupabaseDatabase(changes: changes, newImageURL: newImageURL, userId: originalUser.userId)
                try await updateCoreData(changes: changes, newImageURL: newImageURL, userId: originalUser.userId)
                updateLocalStateAndCache(changes: changes, newImageURL: newImageURL)
                handleSuccessfulSave()

            } catch {
                handleFailedSave(error: error)
            }
        }
    }

    @objc private func handleDeleteAccountTapped() {
        let alertController = UIAlertController(
            title: "회원탈퇴",
            message: "모든 사용자 정보가 삭제되며, 복구하실 수 없습니다.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let deleteAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { [weak self] _ in
            self?.proceedWithAccountDeletion()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true)
    }

    private func proceedWithAccountDeletion() {
        setSavingUIState(isSaving: true)
        Task {
            do {
                try await SupabaseDataManager.shared.deleteAccount()
                if let userId = self.originalUser?.userId {
                    _ = CoreDataManager.shared.deleteUserInfo(userId: userId)
                }
                ImageCacheManager.shared.clear()

                showToast(message: "회원탈퇴가 완료되었습니다.")

            } catch {
                showToast(message: "회원탈퇴 중 오류: \(error.localizedDescription)")
                print("🚨 Delete Account Error: \(error)")
                setSavingUIState(isSaving: false)
            }
        }
    }

    // MARK: - Save Profile Logic Helpers
    private func setSavingUIState(isSaving: Bool) {
        if isSaving {
            activityIndicator.startAnimating()
            saveButton.isEnabled = false
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            saveButton.isEnabled = true
            view.isUserInteractionEnabled = true
        }
    }

    private func handleSuccessfulSave() {
        setSavingUIState(isSaving: false)
        showToast(message: "프로필이 성공적으로 저장되었습니다.")
    }

    private func handleFailedSave(error: Error) {
        setSavingUIState(isSaving: false)
        showToast(message: "프로필 저장 오류: \(error.localizedDescription)")
    }
}

// MARK: - Profile Change Detection & Handling
private extension EditProfileViewController {
    enum ImageChangeState: Equatable {
        case unchanged
        case updated(newImage: UIImage)
        case cleared
    }

    struct ProfileChanges {
        let newName: String
        let nameChanged: Bool
        let imageState: ImageChangeState
    }

    func determineProfileChanges(newName: String) -> ProfileChanges {
        let nameChanged = newName != originalUser?.name
        let currentImage = profileImageView.image
        var imageState: ImageChangeState = .unchanged

        if currentImage?.pngData() != originalProfileImage?.pngData() {
            if currentImage == UIImage(systemName: "person.circle") {
                imageState = .cleared
            } else if let newImage = currentImage {
                imageState = .updated(newImage: newImage)
            }
        }
        
        return ProfileChanges(newName: newName, nameChanged: nameChanged, imageState: imageState)
    }

    func handleImageStorageUpdate(for imageState: ImageChangeState, userId: String) async throws -> String? {
        let storageBucket = "profiles"
        let userFolderPath = userId.lowercased()

        switch imageState {
        case .unchanged:
            return originalUser?.profileImageURL
            
        case .cleared:
            try await deletePreviousProfileImage(userFolderPath: userFolderPath, storageBucket: storageBucket)
            return nil
            
        case .updated(let newImage):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = formatter.string(from: Date())
            let newFileName = "\(timestamp).jpg"
            let newImageStoragePath = "\(userFolderPath)/\(newFileName)"
            
            guard let imageData = newImage.jpegData(compressionQuality: 0.75) else {
                throw NSError(domain: "ImageProcessingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "이미지 JPEG 변환 실패"])
            }
            try await SupabaseDataManager.shared.uploadProfileImage(
                bucket: storageBucket,
                filepath: newImageStoragePath,
                file: imageData,
                upsert: false
            )
            
            try await deletePreviousProfileImage(userFolderPath: userFolderPath, storageBucket: storageBucket)
            
            let publicURL = SupabaseDataManager.shared.createPublicImageURL(bucket: storageBucket, filePath: newImageStoragePath)
            
            return publicURL?.absoluteString
        }
    }

    func deletePreviousProfileImage(userFolderPath: String, storageBucket: String) async throws {
        guard let previousImageURLString = originalUser?.profileImageURL,
              !previousImageURLString.isEmpty,
              let previousImageURL = URL(string: previousImageURLString) else {
            return
        }

        let pathComponents = previousImageURL.pathComponents
        if let bucketIndex = pathComponents.firstIndex(of: storageBucket), bucketIndex + 1 < pathComponents.count {
            let filePathToDelete = pathComponents.suffix(from: bucketIndex + 1).joined(separator: "/")
            _ = await SupabaseDataManager.shared.deleteProfileImage(bucket: storageBucket, filePaths: [filePathToDelete])
        }
    }

    func updateSupabaseDatabase(changes: ProfileChanges, newImageURL: String?, userId: String) async throws {
        var updateDetails: [String: Any] = [:]
        
        if changes.nameChanged {
            updateDetails[Users.CodingKeys.name.rawValue] = changes.newName
        }
        if changes.imageState != .unchanged {
            updateDetails[Users.CodingKeys.profileImageURL.rawValue] = newImageURL
        }
        
        if !updateDetails.isEmpty {
            try await SupabaseDataManager.shared.updateUserProfile(userId: userId, details: updateDetails)
        }
    }
    
    func updateCoreData(changes: ProfileChanges, newImageURL: String?, userId: String) async throws {
        guard changes.nameChanged || changes.imageState != .unchanged else { return }
        
        let nameForCoreData: String? = changes.nameChanged ? changes.newName : nil
        let imageURLForCoreData: String? = (changes.imageState != .unchanged) ? newImageURL : nil
        
        let success = CoreDataManager.shared.updateUserInfo(
            userId: userId,
            name: nameForCoreData,
            image: imageURLForCoreData
        )
    }

    func updateLocalStateAndCache(changes: ProfileChanges, newImageURL: String?) {
        if changes.imageState != .unchanged {
            if let oldUrl = originalUser?.profileImageURL, !oldUrl.isEmpty {
                ImageCacheManager.shared.remove(for: oldUrl)
            }
            if case .updated(let newImage) = changes.imageState, let newUrl = newImageURL, !newUrl.isEmpty {
                ImageCacheManager.shared.set(newImage, for: newUrl)
            }
        }
        
        if changes.nameChanged {
            originalUser?.name = changes.newName
        }
        if changes.imageState != .unchanged {
            originalUser?.profileImageURL = newImageURL
        }
        originalProfileImage = profileImageView.image
    }
}

// MARK: - PHPickerViewControllerDelegate
extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider else { return }
        
        let _ = itemProvider.loadTransferable(type: Data.self) {[weak self] result in
            guard let self = self else { return }
            defer {
                Task { @MainActor in
                    self.activityIndicator.stopAnimating()
                }
            }
            
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    Task { @MainActor in
                        self.profileImageView.image = image
                    }
                }
                
            case .failure(_):
                Task {
                    await self.showToast(message: "이미지를 불러오는 데 실패했습니다.")
                }
            }
        }
    }
}

// MARK: - Toast Message
extension EditProfileViewController {
    private func showToast(message: String, completion: (() -> Void)? = nil) {
        setupUIToast(message: message, completion: completion)
    }
    
    private func setupUIToast(message: String, completion: (() -> Void)? = nil) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else {
            completion?(); return
        }
        keyWindow.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        let toastView = UIView()
        toastView.tag = 9999
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds = true
        toastView.alpha = 0.0
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        toastLabel.numberOfLines = 0
        toastView.addSubview(toastLabel)
        keyWindow.addSubview(toastView)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        setupLayoutToast(view: toastView, label: toastLabel, keyWindow: keyWindow)
    }
    
    private func setupLayoutToast(view: UIView, label: UILabel, keyWindow: UIWindow, completion: (() -> Void)? = nil) {
        let initialBottomConstant: CGFloat = 80
        let finalBottomConstant: CGFloat = -60
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: initialBottomConstant)
        
        keyWindow.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: keyWindow.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(lessThanOrEqualTo: keyWindow.trailingAnchor, constant: -30),
            view.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
            bottomConstraint
        ])
        keyWindow.layoutIfNeeded()
        view.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate( withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            view.alpha = 1.0
            view.transform = .identity
            bottomConstraint.constant = finalBottomConstant
            keyWindow.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate( withDuration: 0.5, delay: 2, options: .curveEaseIn, animations: {
                view.alpha = 0.0
                view.transform = CGAffineTransform(translationX: 0, y: 50)
            }, completion: { _ in
                view.removeFromSuperview()
                completion?()
            })
        })
    }
    
}

// MARK: - NSItemProvider Extension
extension NSItemProvider {
    func loadObject<T: NSItemProviderReading>(ofClass aClass: T.Type) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            _ = self.loadObject(ofClass: aClass) { object, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let object = object as? T {
                    continuation.resume(returning: object)
                } else {
                    continuation.resume(throwing: NSError(domain: "ItemProviderError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get expected type."]))
                }
            }
        }
    }
}
