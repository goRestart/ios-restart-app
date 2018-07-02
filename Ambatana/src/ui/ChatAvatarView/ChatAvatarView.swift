import LGComponents

enum ChatBadgeStyle {
    case topRight(height: CGFloat?)
    case topLeft(height: CGFloat?)
    case bottomRight(height: CGFloat?)
    case bottomLeft(height: CGFloat?)
    case centerBottom(height: CGFloat?, width: CGFloat?)
    case centerTop(height: CGFloat?, width: CGFloat?)

    func styleConstraintsFor(mainView: UIView, badge: UIView) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        var badgeHeight: CGFloat?
        var badgeWidth: CGFloat?
        switch self {
        case .topRight(let height):
            badgeHeight = height
            badgeWidth = height
            constraints = [badge.topAnchor.constraint(equalTo: mainView.topAnchor),
                           badge.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)]
        case .topLeft(let height):
            badgeHeight = height
            badgeWidth = height
            constraints = [badge.topAnchor.constraint(equalTo: mainView.topAnchor),
                           badge.leadingAnchor.constraint(equalTo: mainView.leadingAnchor)]
        case .bottomRight(let height):
            badgeHeight = height
            badgeWidth = height
            constraints = [badge.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
                           badge.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)]
        case .bottomLeft(let height):
            badgeHeight = height
            badgeWidth = height
            constraints = [badge.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
                           badge.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)]
        case .centerBottom(let height, let width):
            badgeHeight = height
            badgeWidth = width
            constraints = [badge.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
                           badge.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
                           badge.trailingAnchor.constraint(greaterThanOrEqualTo: mainView.trailingAnchor),
                           badge.leadingAnchor.constraint(greaterThanOrEqualTo: mainView.leadingAnchor)]
        case .centerTop(let height, let width):
            badgeHeight = height
            badgeWidth = width
            constraints = [badge.topAnchor.constraint(equalTo: mainView.topAnchor),
                           badge.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
                           badge.trailingAnchor.constraint(greaterThanOrEqualTo: mainView.trailingAnchor),
                           badge.leadingAnchor.constraint(greaterThanOrEqualTo: mainView.leadingAnchor)]
        }

        if let badgeHeight = badgeHeight {
            constraints.append(badge.heightAnchor.constraint(equalToConstant: badgeHeight))
        }
        if let badgeWidth = badgeWidth {
            constraints.append(badge.widthAnchor.constraint(equalToConstant: badgeWidth))
        }

        return constraints
    }
}

enum ChatAvatarCornerRadius {
    case round
    case custom(radius: CGFloat)
}


final class ChatAvatarView: UIView {
    let mainView: UIImageView = UIImageView()
    private let badgeView: UIImageView = UIImageView()
    private var mainCornerRadius: ChatAvatarCornerRadius
    private var badgeStyle: ChatBadgeStyle
    private var shareBounds: Bool

    init(mainCornerRadius: ChatAvatarCornerRadius, badgeStyle: ChatBadgeStyle, shareBounds: Bool) {
        self.mainCornerRadius = mainCornerRadius
        self.badgeStyle = badgeStyle
        self.shareBounds = shareBounds
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch mainCornerRadius {
        case .round:
            mainView.setRoundedCorners()
        case .custom(let radius):
            mainView.cornerRadius = radius
        }
    }

    private func setupUI() {
        mainView.contentMode = .scaleAspectFill
        badgeView.contentMode = .scaleAspectFill

        if shareBounds {
            addSubviewForAutoLayout(mainView)
            mainView.addSubviewForAutoLayout(badgeView)
        } else {
            addSubviewsForAutoLayout([mainView, badgeView])
        }

        var constraints = badgeStyle.styleConstraintsFor(mainView: mainView, badge: badgeView)
        constraints.append(contentsOf: [mainView.topAnchor.constraint(equalTo: topAnchor),
                                        mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                        mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                        mainView.leadingAnchor.constraint(equalTo: leadingAnchor)])
        NSLayoutConstraint.activate(constraints)
    }

    func setMainImage(mainImage: UIImage?) {
        mainView.image = mainImage
    }

    func setBadgeImage(badge: UIImage?) {
        badgeView.image = badge
    }

    func setCornerRadius(cornerRadius: ChatAvatarCornerRadius) {
        mainCornerRadius = cornerRadius
    }

    func setBadgeStyle(badgeStyle: ChatBadgeStyle) {
        self.badgeStyle = badgeStyle
    }

    func setShareBounds(shareBounds: Bool) {
        self.shareBounds = shareBounds
    }

    func lg_setImageWithURL(_ url: URL, placeholderImage: UIImage? = nil, completion: ImageDownloadCompletion? = nil) {
        mainView.lg_setImageWithURL(url, placeholderImage: placeholderImage, completion: completion)
    }
}
