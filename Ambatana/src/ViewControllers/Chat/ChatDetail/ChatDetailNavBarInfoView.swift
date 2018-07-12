import Foundation
import LGCoreKit
import LGComponents

enum ChatDetailNavBarInfo {
    case assistant(name: String, imageUrl: URL?)
    case listing(name: String?, price: String, imageUrl: URL?)
}

final class ChatDetailNavBarInfoView: UIView {

    override var intrinsicContentSize: CGSize { return UILayoutFittingExpandedSize }

    private struct Layout {
        static let imageHeight: CGFloat = 36
        static let assistantBadgeHeight: CGFloat = 14
        static let transactionBadgeHeight: CGFloat = 24
        static let arrowHeight: CGFloat = 12
        static let listingImageCornerRadius: CGFloat = 5
        static let topBottomMargin: CGFloat = 2
    }

    private var imageView: ChatAvatarView = ChatAvatarView(mainCornerRadius: .round,
                                                           badgeStyle: .bottomRight(height: Layout.assistantBadgeHeight),
                                                           shareBounds: false)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 15)
        label.textColor = UIColor.blackText
        label.textAlignment = .left
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(size: 13)
        label.textColor = UIColor.grayText
        label.textAlignment = .left
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.rightChevron.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var action: (()->())?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(executeAction))
        self.addGestureRecognizer(tapRecognizer)

        addSubviewsForAutoLayout([imageView, titleLabel, arrowImageView, subtitleLabel])

        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.topBottomMargin),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.topBottomMargin),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Metrics.margin),
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            arrowImageView.heightAnchor.constraint(equalToConstant: Layout.arrowHeight),
            arrowImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Metrics.margin),
            arrowImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Metrics.margin),
            arrowImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Metrics.margin),
            subtitleLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            subtitleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
            ])
    }

    @objc private func executeAction() {
        action?()
    }

    func setupWith(info: ChatDetailNavBarInfo, action: (()->())?) {
        self.action = action
        switch info {
        case .assistant(let name, let url):

            setupHeaderViewWith(imageCornerRadius: .round,
                                imageBadgeStyle: .bottomRight(height: Layout.assistantBadgeHeight),
                                badgeImage: R.Asset.IconsButtons.icAssistantTag.image,
                                placeholderImage: LetgoAvatar.avatarWithID(nil, name: name),
                                imageURL: url,
                                titleText: name,
                                subtitleText: R.Strings.chatConversationsListLetgoAssistantTag,
                                showArrow: false)
        case .listing(let name, let price, let url):

            setupHeaderViewWith(imageCornerRadius: .custom(radius: Layout.listingImageCornerRadius),
                                imageBadgeStyle: .topLeft(height: Layout.transactionBadgeHeight),
                                badgeImage: nil,
                                placeholderImage: R.Asset.IconsButtons.productPlaceholder.image,
                                imageURL: url,
                                titleText: name,
                                subtitleText: price,
                                showArrow: true)
        }
    }

    private func setupHeaderViewWith(imageCornerRadius: ChatAvatarCornerRadius,
                                     imageBadgeStyle: ChatBadgeStyle,
                                     badgeImage: UIImage?,
                                     placeholderImage: UIImage?,
                                     imageURL: URL?,
                                     titleText: String?,
                                     subtitleText: String?,
                                     showArrow: Bool) {

        imageView.setCornerRadius(cornerRadius: imageCornerRadius)
        imageView.setBadgeStyle(badgeStyle: imageBadgeStyle)
        imageView.setShareBounds(shareBounds: false)

        if let url = imageURL {
            imageView.lg_setImageWithURL(url, placeholderImage: placeholderImage)
        } else {
            imageView.setMainImage(mainImage: placeholderImage)
        }
        imageView.setBadgeImage(badge: badgeImage)
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
        arrowImageView.isHidden = !showArrow
    }
}
