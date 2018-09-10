import Foundation
import RxSwift
import LGComponents

// TODO: Use the new one
final class ListingCardUserView: UIView {
    private enum Images {
        static let placeholder = R.Asset.IconsButtons.userPlaceholder.image
    }
    enum Layout {
        struct Height {
            static let userIcon: CGFloat = 34.0
            static let intrinsic: CGFloat = 64.0 // totally arbitrary
            static let userBadge: CGFloat = 20.0
        }
        enum Spacing {
            static let betweenAvatarAndBadge: CGFloat = 3
        }
    }

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric,
                                                              height: Layout.Height.intrinsic) }

    let rxUserIcon: Reactive<UIButton>

    private let userIcon: UIButton = {
        let btn = UIButton(type: .custom)
        btn.contentMode = .scaleAspectFit
        btn.setBackgroundImage(Images.placeholder, for: .normal)
        btn.clipsToBounds = true
        return btn
    }()
    private let userNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.deckUsernameFont
        lbl.textColor = .black
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.setContentHuggingPriority(.required, for: .vertical)
        return lbl
    }()
    private let userBadgeImageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = false
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        img.image = R.Asset.IconsButtons.icKarmaBadgeActive.image
        return img
    }()

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        self.rxUserIcon = userIcon.rx
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

    private func setupUI() {
        addSubviewsForAutoLayout([userIcon, userBadgeImageView, userNameLabel])
        NSLayoutConstraint.activate([
            userIcon.topAnchor.constraint(equalTo: topAnchor),
            userIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            userIcon.bottomAnchor.constraint(equalTo: bottomAnchor),
            userIcon.widthAnchor.constraint(equalToConstant: Layout.Height.userIcon),
            userIcon.heightAnchor.constraint(equalTo: userIcon.widthAnchor),

            userBadgeImageView.leadingAnchor.constraint(equalTo: userIcon.leadingAnchor,
                                                        constant: Layout.Spacing.betweenAvatarAndBadge),
            userBadgeImageView.topAnchor.constraint(equalTo: userIcon.bottomAnchor,
                                                    constant: Layout.Spacing.betweenAvatarAndBadge),
            userBadgeImageView.widthAnchor.constraint(equalToConstant: Layout.Height.userBadge),
            userBadgeImageView.heightAnchor.constraint(equalTo: userBadgeImageView.widthAnchor),

            userNameLabel.leadingAnchor.constraint(equalTo: userIcon.trailingAnchor, constant: Metrics.margin),
            userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.veryShortMargin),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin)
        ])
        userIcon.layer.cornerRadius = Layout.Height.userIcon / 2
    }

    func prepareForReuse() {
        userIcon.setBackgroundImage(Images.placeholder, for: .normal)
        userNameLabel.text = ""
    }
}
