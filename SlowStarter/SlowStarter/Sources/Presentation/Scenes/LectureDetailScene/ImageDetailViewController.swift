import UIKit

class ImageDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let zoomableImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var currentImageTransform: CGAffineTransform = .identity
    private var isInitialCornerRadiusSet = false
    
    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        zoomableImageView.image = image
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dimmedBackgroundView)
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(zoomableImageView)
        setupLayoutConstraints()
        configureGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isInitialCornerRadiusSet {
            updateCornerRadiusBasedOnScale()
            isInitialCornerRadiusSet = true
        }
    }
    
    private func setupLayoutConstraints() {
        guard let image = zoomableImageView.image, image.size.height > 0 else { return }
        
        NSLayoutConstraint.activate([
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageContainerView.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor, multiplier: image.size.width / image.size.height),
            imageContainerView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32),
            imageContainerView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, constant: -32),
            
            zoomableImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            zoomableImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            zoomableImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            zoomableImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
        ])
    }
    
    private func configureGestureRecognizers() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchRecognizer.delegate = self
        imageContainerView.addGestureRecognizer(pinchRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panRecognizer.delegate = self
        imageContainerView.addGestureRecognizer(panRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        imageContainerView.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGesture(_:)))
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    @objc private func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        let scale = recognizer.scale
        switch recognizer.state {
        case .began:
            recognizer.scale = 1.0
        case .changed:
            imageContainerView.transform = currentImageTransform.scaledBy(x: scale, y: scale)
            updateCornerRadiusBasedOnScale()
        case .ended, .cancelled:
            currentImageTransform = imageContainerView.transform
        default:
            break
        }
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let currentScale = imageContainerView.transform.a
        guard currentScale > 0.001 else { return }
        
        switch recognizer.state {
        case .began:
            currentImageTransform = imageContainerView.transform
        case .changed:
            let adjustedX = translation.x / currentScale
            let adjustedY = translation.y / currentScale
            imageContainerView.transform = currentImageTransform.translatedBy(x: adjustedX, y: adjustedY)
        case .ended, .cancelled:
            currentImageTransform = imageContainerView.transform
        default:
            break
        }
    }
    
    @objc private func handleDoubleTapGesture(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.imageContainerView.transform = .identity
            self.currentImageTransform = .identity
            self.updateCornerRadiusBasedOnScale()
        }
    }
    
    @objc private func handleSingleTapGesture(_ recognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    private func updateCornerRadiusBasedOnScale() {
        let currentScale = imageContainerView.transform.a
        guard currentScale > 0.001 else { return }
        imageContainerView.layer.cornerRadius = 12 / currentScale
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
