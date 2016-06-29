//
//  UserView.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol UserViewDelegate: class {
    func userViewAvatarPressed(userView: UserView)
    func userViewAvatarLongPressStarted(userView: UserView)
    func userViewAvatarLongPressEnded(userView: UserView)
}

enum UserViewStyle {
    case CompactShadow(size: CGSize), CompactBorder(size: CGSize), Full

    var bgColor: UIColor {
        switch self {
        case .Full:
            return UIColor.white.colorWithAlphaComponent(0.9)
        case .CompactShadow, .CompactBorder:
            return UIColor.clearColor()
        }
    }

    var usernameLabelFont: UIFont {
        switch self {
        case .Full:
            return UIFont.mediumBodyFont
        case .CompactShadow, .CompactBorder:
            return UIFont.smallBodyFont
        }
    }

    var usernameLabelColor: UIColor {
        switch self {
        case .Full:
            return UIColor.black
        case .CompactShadow, .CompactBorder:
            return UIColor.white
        }
    }

    var subtitleLabelFont: UIFont {
        switch self {
        case .Full:
            return UIFont.smallBodyFontLight
        case .CompactShadow, .CompactBorder:
            return UIFont.subtitleFontLight
        }
    }

    var subtitleLabelColor: UIColor {
        switch self {
        case .Full:
            return UIColor.black
        case .CompactShadow, .CompactBorder:
            return UIColor.white
        }
    }

    var avatarBorderColor: UIColor? {
        switch self {
        case .Full, .CompactShadow:
            return nil
        case .CompactBorder:
            return UIColor.white
        }
    }
}

class UserView: UIView {
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet var avatarMarginConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    private var style: UserViewStyle = .Full

    weak var delegate: UserViewDelegate?

    
    // MARK: - Lifecycle

    static func userView(style: UserViewStyle) -> UserView {
        let view = NSBundle.mainBundle().loadNibNamed("UserView", owner: self, options: nil).first as! UserView
        view.style = style
        view.setup()
        return view
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.height / 2
    }

    
    // MARK: - Public methods

    func setupWith(userAvatar avatar: NSURL?, userName: String?, userId: String?) {
        setupWith(userAvatar: avatar, userName: userName, subtitle: nil, userId: userId)
    }

    func setupWith(userAvatar avatar: NSURL?, userName: String?, subtitle: String?, userId: String?) {
        let placeholder = LetgoAvatar.avatarWithID(userId, name: userName)
        setupWith(userAvatar: avatar, placeholder: placeholder, userName: userName, subtitle: subtitle)
    }

    func setupWith(userAvatar avatar: NSURL?, placeholder: UIImage?, userName: String?, subtitle: String?) {
        if let avatar = avatar {
            userAvatarImageView.lg_setImageWithURL(avatar, placeholderImage: placeholder)
        } else {
            userAvatarImageView.image = placeholder
        }
        userNameLabel.text = userName
        subtitleLabel.text = subtitle
    }
    
    func showShadow(show: Bool) {
        if show {
            layer.shadowOffset = CGSize.zero
            layer.shadowOpacity = 0.24
            layer.shadowRadius = 2.0
        } else {
            layer.shadowOpacity = 0.0
            layer.shadowRadius = 0.0
        }
    }


    // MARK: - Private methods

    private func setup() {
        clipsToBounds = false
        
        showShadow(true)

        backgroundColor = style.bgColor
        userNameLabel.font = style.usernameLabelFont
        userNameLabel.textColor = style.usernameLabelColor
        subtitleLabel.font = style.subtitleLabelFont
        subtitleLabel.textColor = style.subtitleLabelColor

        if let borderColor = style.avatarBorderColor {
            userAvatarImageView.layer.borderWidth = 1
            userAvatarImageView.layer.borderColor = borderColor.CGColor
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarPressed))
        addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(avatarLongPressed(_:)))
        addGestureRecognizer(longPressGesture)
    }

    dynamic private func avatarPressed() {
        delegate?.userViewAvatarPressed(self)
    }

    dynamic private func avatarLongPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            delegate?.userViewAvatarLongPressStarted(self)
        case .Cancelled, .Ended:
            delegate?.userViewAvatarLongPressEnded(self)
        default:
            break
        }
    }
}