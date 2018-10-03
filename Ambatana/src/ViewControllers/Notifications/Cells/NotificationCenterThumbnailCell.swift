import LGCoreKit
import LGComponents

protocol NotificationCenterThumbnailCellDelegate: class {
    func didTapCollectionViewCell(_ cell: NotificationCenterThumbnailCell, deeplink: String?)
}

final class NotificationCenterThumbnailCell: UICollectionViewCell, ReusableCell {
    private struct Layout {
        static let titleTrailing: CGFloat = 8
    }
    
    static let thumbnailSideSize = FeatureFlags.sharedInstance.imageSizesNotificationCenter.thumbnailSize
    
    let thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        return thumbnailImageView
    }()
    
    var deeplink: String?
    
    
    static func cellSize() -> CGSize {
        return CGSize(width: thumbnailSideSize, height: thumbnailSideSize)
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    
    // MARK: - UI

    private func setupLayout() {
        contentView.addSubviewForAutoLayout(thumbnailImageView)
        let constraints = [
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            thumbnailImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            thumbnailImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func resetUI() {
        thumbnailImageView.image = nil
    }
    
    func setup(imageUrlString: String, shape: NotificationImageShape, deeplink: String?) {
        guard let url = URL(string: imageUrlString) else { return }
        var placeholderImage: UIImage?
        switch shape {
        case .square:
            thumbnailImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
            placeholderImage = R.Asset.BackgroundsAndImages.notificationThumbnailSquarePlaceholder.image
        case .circle:
            thumbnailImageView.cornerRadius = Metrics.modularNotificationThumbnailSize/2
            placeholderImage = R.Asset.BackgroundsAndImages.notificationThumbnailCirclePlaceholder.image
        }
        thumbnailImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage) { [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.thumbnailImageView.image = image
            }
        }
        self.deeplink = deeplink
    }
    
    
    // MARK: - Accessibility
    
    private func setAccessibilityIds() {
        set(accessibilityId: .notificationsModularThumbnailCollectionViewCell)
        thumbnailImageView.set(accessibilityId: .notificationsModularThumbnailView)
    }
}

fileprivate extension ImageSizesNotificationCenter {
    var thumbnailSize: CGFloat {
        switch self {
        case .control, .baseline:
            return 76
        case .nineSix:
            return 96
        case .oneTwoEight:
            return 128
        }
    }
}
