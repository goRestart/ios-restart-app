import LGComponents

private enum Layout {
    enum Size {
        static let avatar = CGSize(width: 64, height: 64)
    }
    enum Edges {
        static let content = UIEdgeInsets(top: 75,
                                          left: Metrics.veryBigMargin,
                                          bottom: 100,
                                          right: Metrics.veryBigMargin)
    }

    static let backgroundRatio: CGFloat = 1.22
}

final class AffiliationOnBoardingView: UIView {

    private let revealBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = R.Asset.Affiliation.materialBackground.image
        return imageView
    }()

    private let userAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.cornerRadius = Layout.Size.avatar.width / 2
        imageView.backgroundColor = .white
        return imageView
    }()

    private let message: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 28)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        let content = UIStackView.vertical([UIStackView.horizontal([userAvatar, UIView()]), message, UIView()])
        content.spacing = Metrics.margin
        addSubviewsForAutoLayout([revealBackground, content])

        [
            revealBackground.topAnchor.constraint(equalTo: topAnchor),
            revealBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            revealBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            revealBackground.heightAnchor.constraint(equalTo: revealBackground.widthAnchor,
                                                     multiplier: Layout.backgroundRatio),

            userAvatar.widthAnchor.constraint(equalToConstant: Layout.Size.avatar.width),
            userAvatar.heightAnchor.constraint(equalToConstant: Layout.Size.avatar.height),

            content.topAnchor.constraint(equalTo: topAnchor, constant: Layout.Edges.content.top),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.Edges.content.right),
            content.bottomAnchor.constraint(equalTo: revealBackground.bottomAnchor, constant: -Layout.Edges.content.bottom),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Edges.content.left)
        ].activate()
    }

    func set(avatar url: URL?, userName: String, userId: String, message: String) {
        userAvatar.image = LetgoAvatar.avatarWithID(userId, name: userName)
        self.message.text = message
        if let url = url {
            userAvatar.lg_setImageWithURL(url)
        }
    }
}
