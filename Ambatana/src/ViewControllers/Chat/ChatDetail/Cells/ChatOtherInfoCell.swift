import UIKit
import LGComponents

class ChatOtherInfoCell: UITableViewCell, ReusableCell {

    private enum Layout {
        static let bigMargin: CGFloat = 12
        static let verticalMargin: CGFloat = 8
        static let horizontalMargin: CGFloat = 8
        static let iconsMargin: CGFloat = 8
        static let iconsHeight: CGFloat = 14
        static let verifyIconsWidth: CGFloat = 20
    }

    private var bubbleView: UIView = {
        let view = UIView()
        view.cornerRadius = ChatBubbleLayout.cornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .chatOthersBubbleBgColorWhite
        return view
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackText
        label.font = .systemFont(size: 17)
        return label
    }()

    private var verifyIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icVerified.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var verifyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayDark
        label.font = .systemFont(size: 13)
        label.text = R.Strings.chatUserInfoVerifiedWith
        return label
    }()

    private var verifyContainer: UIView = UIView()

    private var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayDark
        label.font = .systemFont(size: 13)
        return label
    }()

    private var infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icChatInfoDark.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayDark
        label.font = .systemFont(size: 13)
        label.numberOfLines = 0
        label.text = R.Strings.chatUserInfoLetgoAssistant
        return label
    }()

    private var facebookIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icUserPublicFb.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var googleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icUserPublicGoogle.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var emailIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icUserPublicEmail.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icLocation.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var avatarAction: (()->Void)?

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = ChatBubbleLayout.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        imageView.isHidden = true
        return imageView
    }()

    var bubbleBottomMargin: NSLayoutConstraint?
    var bubbleLeftMargin: NSLayoutConstraint?

    private var verifyIconHeight: NSLayoutConstraint?
    private var verifyIconTop: NSLayoutConstraint?

    private var fbIconWidth: NSLayoutConstraint?
    private var googleIconWidth: NSLayoutConstraint?
    private var mailIconWidth: NSLayoutConstraint?

    private var locationIconHeight: NSLayoutConstraint?
    private var locationIconTop: NSLayoutConstraint?

    private var infoLabelTop: NSLayoutConstraint?
    private var infoIconHeight: NSLayoutConstraint?
    private var infoIconWidth: NSLayoutConstraint?
    private var infoIconTop: NSLayoutConstraint?


    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public

    func set(name: String?) {
        nameLabel.text = name
    }

    func setupVerifiedInfo(facebook: Bool, google: Bool, email: Bool) {
        guard facebook || google || email else {
            setVerifyEnabled(false)
            return
        }
        setInfoEnabled(false)
        setVerifyEnabled(true)
        fbIconWidth?.constant = facebook ? Layout.verifyIconsWidth : 0
        googleIconWidth?.constant = google ? Layout.verifyIconsWidth : 0
        mailIconWidth?.constant = email ? Layout.verifyIconsWidth : 0
    }

    func setupLocation(_ location: String?) {
        guard let location = location, !location.isEmpty else {
            setLocationEnabled(false)
            return
        }
        setInfoEnabled(false)
        setLocationEnabled(true)
        locationLabel.text = location
    }
    
    func setupLetgoAssistantInfo() {
        setLocationEnabled(false)
        setVerifyEnabled(false)
        setInfoEnabled(true)
    }

    func set(bubbleBackgroundColor: UIColor?) {
        guard let bubbleBackgroundColor = bubbleBackgroundColor else { return }
        bubbleView.backgroundColor = bubbleBackgroundColor
    }
    
    func set(userAvatar: UIImage?, avatarAction: (()->Void)?) {
        avatarImageView.image = userAvatar
        avatarImageView.isHidden = userAvatar == nil
        let avatarSpace = (2 * ChatBubbleLayout.margin + ChatBubbleLayout.avatarSize)
        bubbleLeftMargin?.constant = userAvatar != nil ? avatarSpace : ChatBubbleLayout.margin

        self.avatarAction = avatarAction
        if let _ = avatarAction {
            avatarImageView.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
            avatarImageView.addGestureRecognizer(tapRecognizer)
        }
    }

    private func setLocationEnabled(_ enabled: Bool) {
        locationIconTop?.constant = enabled ? Layout.verticalMargin : 0
        locationIconHeight?.constant =  enabled ? Layout.iconsHeight : 0
        locationLabel.isHidden = !enabled
    }
    
    private func setVerifyEnabled(_ enabled: Bool) {
        verifyIconTop?.constant = enabled ? Layout.verticalMargin : 0
        verifyIconHeight?.constant = enabled ? Layout.iconsHeight : 0
        verifyLabel.isHidden = !enabled
        verifyContainer.isHidden = !enabled
    }
    
    private func setInfoEnabled(_ enabled: Bool) {
        infoIconTop?.constant = enabled ? Layout.verticalMargin : 0
        infoIconHeight?.constant = enabled ? Layout.iconsHeight : 0
        infoIconWidth?.constant = enabled ? Layout.iconsHeight : 0
        infoLabel.isHidden = !enabled
        if !enabled {
            infoLabel.layout().height(0)
        }
    }

    @objc private func avatarTapped() {
        avatarAction?()
    }
}


// MARK: - Private

fileprivate extension ChatOtherInfoCell {
    func setupUI() {
        backgroundColor = .clear
        contentView.addSubviewsForAutoLayout([bubbleView, avatarImageView])

        bubbleView.addSubviewsForAutoLayout([nameLabel, infoIcon, verifyIcon, verifyLabel, verifyContainer,
                                                    locationIcon, locationLabel, infoLabel])

        verifyContainer.addSubviewsForAutoLayout([facebookIcon, googleIcon, emailIcon])
    }

    func setupConstraints() {

        var constraints = [
            avatarImageView.heightAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: ChatBubbleLayout.avatarSize),
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -ChatBubbleLayout.minBubbleMargin)
        ]

        let bubbleBottom = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryShortMargin)
        let bubbleLeft = bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: ChatBubbleLayout.margin)

        bubbleBottomMargin = bubbleBottom
        bubbleLeftMargin = bubbleLeft

        constraints.append(contentsOf: [bubbleBottom, bubbleLeft])

        let bubbleElementsConstraints = [
            nameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Layout.bigMargin),
            nameLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Layout.horizontalMargin),
            nameLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Layout.verticalMargin),

            infoIcon.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Layout.bigMargin),
            infoLabel.leadingAnchor.constraint(equalTo: infoIcon.trailingAnchor, constant: Layout.horizontalMargin),
            infoLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Layout.horizontalMargin),

            verifyIcon.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Layout.bigMargin),
            verifyLabel.leadingAnchor.constraint(equalTo: verifyIcon.trailingAnchor, constant: Layout.horizontalMargin),
            verifyLabel.centerYAnchor.constraint(equalTo: verifyIcon.centerYAnchor),
            verifyContainer.leadingAnchor.constraint(equalTo: verifyLabel.trailingAnchor, constant: Layout.horizontalMargin),
            verifyContainer.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -Layout.horizontalMargin),
            verifyContainer.centerYAnchor.constraint(equalTo: verifyIcon.centerYAnchor),

            locationIcon.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Layout.bigMargin),
            locationIcon.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Layout.verticalMargin),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: Layout.horizontalMargin),
            locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -Layout.horizontalMargin),
            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor)
        ]

        constraints.append(contentsOf: bubbleElementsConstraints)

        let verifyContainerConstraints = [
            facebookIcon.leadingAnchor.constraint(equalTo: verifyContainer.leadingAnchor),
            facebookIcon.topAnchor.constraint(equalTo: verifyContainer.topAnchor),
            facebookIcon.bottomAnchor.constraint(equalTo: verifyContainer.bottomAnchor),
            googleIcon.leadingAnchor.constraint(equalTo: facebookIcon.trailingAnchor),
            googleIcon.topAnchor.constraint(equalTo: verifyContainer.topAnchor),
            googleIcon.bottomAnchor.constraint(equalTo: verifyContainer.bottomAnchor),
            emailIcon.leadingAnchor.constraint(equalTo: googleIcon.trailingAnchor),
            emailIcon.trailingAnchor.constraint(equalTo: verifyContainer.trailingAnchor),
            emailIcon.topAnchor.constraint(equalTo: verifyContainer.topAnchor),
            emailIcon.bottomAnchor.constraint(equalTo: verifyContainer.bottomAnchor)
        ]
        constraints.append(contentsOf: verifyContainerConstraints)

        let verifyHeight = verifyIcon.heightAnchor.constraint(equalToConstant: Layout.iconsHeight)
        let verifyTop = verifyIcon.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: Layout.verticalMargin)

        let fbWidth = facebookIcon.widthAnchor.constraint(equalToConstant: Layout.verifyIconsWidth)
        let googleWidth = googleIcon.widthAnchor.constraint(equalToConstant: Layout.verifyIconsWidth)
        let mailWidth = emailIcon.widthAnchor.constraint(equalToConstant: Layout.verifyIconsWidth)

        let locationHeight = locationIcon.heightAnchor.constraint(equalToConstant: Layout.iconsHeight)
        let locationTop = locationIcon.topAnchor.constraint(equalTo: verifyIcon.bottomAnchor, constant: Layout.verticalMargin)

        let infoIcHeight = infoIcon.heightAnchor.constraint(equalToConstant: Layout.iconsHeight)
        let infoIcWidth = infoIcon.widthAnchor.constraint(equalToConstant: Layout.iconsHeight)

        let infoIcTop = infoIcon.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Layout.verticalMargin)
        let infoLabTop = infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Layout.verticalMargin)

        verifyIconHeight = verifyHeight
        verifyIconTop = verifyTop

        fbIconWidth = fbWidth
        googleIconWidth = googleWidth
        mailIconWidth = mailWidth

        locationIconHeight = locationHeight
        locationIconTop = locationTop

        infoIconHeight = infoIcHeight
        infoIconWidth = infoIcWidth
        infoIconTop = infoIcTop
        infoLabelTop = infoLabTop

        constraints.append(contentsOf: [verifyHeight, verifyTop, fbWidth, googleWidth, mailWidth, locationHeight,
                                        locationTop, infoIcHeight, infoIcWidth, infoIcTop, infoLabTop])

        NSLayoutConstraint.activate(constraints)
    }
    
    func setAccessibilityIds() {
        set(accessibilityId: .chatOtherInfoCellContainer)
        nameLabel.set(accessibilityId: .chatOtherInfoCellNameLabel)
        avatarImageView.set(accessibilityId: .chatCellAvatar)
    }
}
