//
//  UserView.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol UserViewDelegate: class {
    func userViewAvatarPressed(userView: UserView)
}

enum UserViewStyle {
    case CompactShadow(size: CGSize), CompactBorder(size: CGSize), Full
}

class UserView: UIView {
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet var avatarMarginConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    private var style: UserViewStyle = .Full

    weak var delegate: UserViewDelegate?

    
    // MARK: - Lifecycle

    static func userView(style: UserViewStyle) -> UserView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("UserView", owner: self,
            options: nil).first as? UserView else { return nil }
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
        userAvatarImageView.sd_setImageWithURL(avatar, placeholderImage: placeholder)
        userNameLabel.text = userName
        subtitleLabel.text = subtitle
    }


    // MARK: - Private methods

    private func setup() {
        clipsToBounds = false
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 2.0

        backgroundColor = StyleHelper.userViewBgColor(style)
        userNameLabel.font = StyleHelper.userViewUsernameLabelFont(style)
        userNameLabel.textColor = StyleHelper.userViewUsernameLabelColor(style)
        subtitleLabel.font = StyleHelper.userViewSubtitleLabelFont(style)
        subtitleLabel.textColor = StyleHelper.userViewSubtitleLabelColor(style)

        if let borderColor = StyleHelper.userViewAvatarBorderColor(style) {
            userAvatarImageView.layer.borderWidth = 1
            userAvatarImageView.layer.borderColor = borderColor.CGColor
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("avatarPressed"))
        addGestureRecognizer(tapGesture)
    }

    dynamic private func avatarPressed() {
        delegate?.userViewAvatarPressed(self)
    }
}