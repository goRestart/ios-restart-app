import Foundation
import RxSwift
import LGComponents

final class ListingCardUserView: UIView {
    enum Action {
        case favourite(isOn: Bool)
        case edit

        fileprivate func setupListingCardUserView(_ view: ListingCardUserView) {
            switch self {
            case .favourite(let isOn):
                view.set(favourite: isOn)
            case .edit:
                view.setEditMode()
            }
        }
    }
    struct Images {
        static let favourite = R.Asset.IconsButtons.NewItemPage.nitFavourite.image
        static let favouriteOn = R.Asset.IconsButtons.NewItemPage.nitFavouriteOn.image

        static let edit = R.Asset.IconsButtons.NewItemPage.nitEdit.image
        static let placeholder = R.Asset.IconsButtons.userPlaceholder.image
        static let share = R.Asset.IconsButtons.NewItemPage.nitShare.image
    }

    struct Layout {
        struct Height {
            static let userIcon: CGFloat = 34.0
            static let intrinsic: CGFloat = 64.0 // totally arbitrary
            static let userBadge: CGFloat = 20.0
        }
        struct Width { static let shareButton: CGFloat = 28 }
        struct Spacing {
            static let betweenButtons: CGFloat = 20
            static let betweenAvatarAndBadge: CGFloat = 3
        }
    }

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric,
                                                              height: Layout.Height.intrinsic) }

    let rxShareButton: Reactive<UIButton>
    let rxActionButton: Reactive<UIButton>
    let rxUserIcon: Reactive<UIButton>

    private let userIcon = UIButton(type: .custom)
    private let userNameLabel = UILabel()
    private let userBadgeImageView = UIImageView()

    private let actionLayoutGuide = UILayoutGuide()
    private let actionButton = UIButton()
    private let shareButton = UIButton()

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        rxShareButton = shareButton.rx
        rxActionButton = actionButton.rx
        rxUserIcon = userIcon.rx
        
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func populate(withUserName userName: String,
                  placeholder: UIImage?,
                  icon: URL?,
                  imageDownloader: ImageDownloaderType,
                  badgeType: UserReputationBadge) {
        userNameLabel.text = userName
        actionButton.tintColor = .white
        userBadgeImageView.isHidden = badgeType == .noBadge
        guard let url = icon else {
            userIcon.setBackgroundImage(placeholder ?? Images.placeholder, for: .normal)
            return
        }
        userIcon.tag = tag
        imageDownloader.downloadImageWithURL(url, completion: { [weak  self] (result, url) in
            if let value = result.value,
                let selfTag = self?.tag,
                self?.userIcon.tag == selfTag {
                self?.userIcon.setBackgroundImage(value.image, for: .normal)
                self?.userIcon.setNeedsLayout()
            }
        })
    }

    func set(action: Action) {
        action.setupListingCardUserView(self)
        actionButton.animateTo(alpha: 1)
    }

    fileprivate func set(favourite isFavourite: Bool) {
        if isFavourite {
            actionButton.setImage(Images.favouriteOn, for: .normal)
        } else {
            actionButton.setImage(Images.favourite, for: .normal)
        }
    }

    fileprivate func setEditMode() {
        actionButton.setImage(Images.edit, for: .normal)
    }

    @objc private func didTouchUpShareButton() {
        shareButton.bounce()
    }

    @objc private func didTouchUpActionButton() {
        actionButton.bounce()
    }

    private func setupUI() {
        setupUserIcon()
        setupUserInfo()
        setupActions()
        setupUserBadge()
    }

    private func setupUserIcon() {
        addSubviewForAutoLayout(userIcon)
        userIcon.layout(with: self)
            .top(by: Metrics.margin)
            .leading(by: Metrics.margin).bottom(by: -Metrics.margin)
        userIcon.layout().width(Layout.Height.userIcon).widthProportionalToHeight()

        userIcon.contentMode = .scaleAspectFit
        userIcon.clipsToBounds = true
    }

    private func setupUserBadge() {
        addSubviewForAutoLayout(userBadgeImageView)
        userBadgeImageView.image = R.Asset.IconsButtons.icKarmaBadgeActive.image
        userBadgeImageView.contentMode = .scaleAspectFit
        userBadgeImageView.isHidden = true
        userBadgeImageView
            .layout(with: userIcon)
            .trailing(by: Layout.Spacing.betweenAvatarAndBadge)
            .bottom(by: Layout.Spacing.betweenAvatarAndBadge)
        userBadgeImageView.layout().width(Layout.Height.userBadge).widthProportionalToHeight()
    }

    private func setupUserInfo() {
        addSubviewForAutoLayout(userNameLabel)
        userNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        userNameLabel.setContentHuggingPriority(.required, for: .vertical)

        userNameLabel
            .layout(with: userIcon)
            .leading(to: .trailingMargin, by: Metrics.margin)
            .top(by: Metrics.veryShortMargin)
        userNameLabel.font = UIFont.deckUsernameFont
        userNameLabel.textColor = .white
    }

    private func setupActions() {
        addLayoutGuide(actionLayoutGuide)
        addSubviewsForAutoLayout([actionButton, shareButton])

        actionButton.setImage(Images.favourite, for: .normal)
        actionButton.imageView?.contentMode = .center
        actionButton.addTarget(self, action: #selector(didTouchUpActionButton), for: .touchUpInside)
        actionButton.applyDefaultShadow()

        shareButton.setImage(Images.share, for: .normal)
        shareButton.imageView?.contentMode = .center
        shareButton.applyDefaultShadow()

        shareButton.layout().width(Layout.Width.shareButton)
        actionButton.layout(with: shareButton).proportionalWidth()
        actionButton.layout(with: shareButton).proportionalHeight()

        actionButton.layout(with: actionLayoutGuide).leading().top().bottom()
        shareButton.layout(with: actionLayoutGuide).trailing().top().bottom()
        shareButton.layout(with: actionButton).leading(to: .trailing, by: Layout.Spacing.betweenButtons)
        shareButton.addTarget(self, action: #selector(didTouchUpShareButton), for: .touchUpInside)

        actionLayoutGuide.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor,
                                                   constant: Metrics.margin).isActive = true
        actionLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -Metrics.margin).isActive = true
        actionLayoutGuide.topAnchor.constraint(equalTo: topAnchor,
                                               constant: Layout.Spacing.betweenButtons).isActive = true
        actionLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                  constant: -Layout.Spacing.betweenButtons).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userIcon.layer.cornerRadius = min(userIcon.width, userIcon.height) / 2.0
    }

    func prepareForReuse() {
        actionButton.alpha = 0.3
        userIcon.setBackgroundImage(Images.placeholder, for: .normal)
        userNameLabel.text = ""
    }
}
