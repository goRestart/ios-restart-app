//
//  UserProfileHeaderView.swift
//  LetGo
//
//  Created by Sergi Gracia on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate: class {
    func didTapEditAvatar()
    func didTapAvatar()
}

enum UserHeaderViewBadge {
    case noBadge
    case silver
    case gold
    case pro

    init(userBadge: UserReputationBadge) {
        switch userBadge {
        case .noBadge: self = .noBadge
        case .silver: self = .silver
        case .gold : self = .gold
        }
    }
}

final class UserProfileHeaderView: UIView {
    let userNameLabel = UILabel()
    let ratingView = RatingView(layout: .normal)
    let locationLabel = UILabel()
    let memberSinceLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let editAvatarButton = UIButton()
    private let verifiedBadgeImageView = UIImageView()
    private let proBadgeImageView = UIImageView()
    weak var delegate: UserProfileHeaderDelegate?

    let isPrivate: Bool

    private struct Layout {
        static let verticalMargin: CGFloat = 5.0
        static let imageHeight: CGFloat = 110.0
        static let verifiedBadgeHeight: CGFloat = 30
        static let editAvatarButtonHeight: CGFloat = 44
        static let editAvatarButtonRightInset: CGFloat = 7
        static let editAvatarButtonTopInset: CGFloat = 4
        static let proBadgeHeight: CGFloat = 20
        static let proBadgeWidth: CGFloat = 50
    }

    init(isPrivate: Bool) {
        self.isPrivate = isPrivate
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var userBadge: UserHeaderViewBadge = .noBadge {
        didSet {
            updateBadge()
        }
    }

    func setAvatar(_ url: URL?, placeholderImage: UIImage?) {
        if let url = url {
            avatarImageView.lg_setImageWithURL(url)
            editAvatarButton.setImage(UIImage(named: "user_profile_edit_avatar"), for: .normal)
        } else {
            avatarImageView.image = placeholderImage
            editAvatarButton.setImage(UIImage(named: "user_profile_add_avatar"), for: .normal)
        }
    }

    private func updateBadge() {
        verifiedBadgeImageView.isHidden = true
        proBadgeImageView.isHidden = true

        switch userBadge {
        case .noBadge: break
        case .silver, .gold:
            verifiedBadgeImageView.isHidden = false
        case .pro:
            proBadgeImageView.isHidden = false
        }
    }

    private func setupView() {
        addSubviewsForAutoLayout([userNameLabel, ratingView, locationLabel, memberSinceLabel, avatarImageView,
                                  editAvatarButton, verifiedBadgeImageView, proBadgeImageView])

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .grayLight
        avatarImageView.layer.cornerRadius = Layout.imageHeight / 2
        avatarImageView.clipsToBounds = true

        userNameLabel.font = .profileUserHeadline
        userNameLabel.textColor = .lgBlack

        locationLabel.font = .smallButtonFont
        locationLabel.textColor = .lgBlack

        memberSinceLabel.font = .mediumBodyFont
        memberSinceLabel.textColor = .grayDark
        editAvatarButton.isHidden = !isPrivate
        editAvatarButton.addTarget(self, action: #selector(didTapEditAvatar), for: .touchUpInside)

        verifiedBadgeImageView.image = #imageLiteral(resourceName: "ic_karma_badge_active")
        verifiedBadgeImageView.contentMode = .scaleAspectFit

        proBadgeImageView.image = #imageLiteral(resourceName: "ic_pro_tag_with_shadow")
        proBadgeImageView.cornerRadius = 10
        proBadgeImageView.contentMode = .scaleAspectFit
    }

    private func setupConstraints() {
        let constraints = [
            userNameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            userNameLabel.topAnchor.constraint(equalTo: topAnchor),
            userNameLabel.rightAnchor.constraint(equalTo: avatarImageView.leftAnchor, constant: -Layout.verticalMargin),

            ratingView.leftAnchor.constraint(equalTo: leftAnchor),
            ratingView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Layout.verticalMargin),

            locationLabel.leftAnchor.constraint(equalTo: leftAnchor),
            locationLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: Layout.verticalMargin),

            memberSinceLabel.leftAnchor.constraint(equalTo: leftAnchor),
            memberSinceLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: Layout.verticalMargin),

            avatarImageView.rightAnchor.constraint(equalTo: rightAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.imageHeight),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            editAvatarButton.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: -Layout.editAvatarButtonTopInset),
            editAvatarButton.rightAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: Layout.editAvatarButtonRightInset),
            editAvatarButton.heightAnchor.constraint(equalToConstant: Layout.editAvatarButtonHeight),
            editAvatarButton.widthAnchor.constraint(equalToConstant: Layout.editAvatarButtonHeight),

            verifiedBadgeImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            verifiedBadgeImageView.rightAnchor.constraint(equalTo: avatarImageView.rightAnchor),
            verifiedBadgeImageView.heightAnchor.constraint(equalToConstant: Layout.verifiedBadgeHeight),
            verifiedBadgeImageView.widthAnchor.constraint(equalToConstant: Layout.verifiedBadgeHeight),

            proBadgeImageView.centerYAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            proBadgeImageView.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            proBadgeImageView.heightAnchor.constraint(equalToConstant: Layout.proBadgeHeight),
            proBadgeImageView.widthAnchor.constraint(equalToConstant: Layout.proBadgeWidth),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        userNameLabel.set(accessibilityId: .userHeaderExpandedNameLabel)
        locationLabel.set(accessibilityId: .userHeaderExpandedLocationLabel)
        memberSinceLabel.set(accessibilityId: .userHeaderExpandedMemberSinceLabel)
        editAvatarButton.set(accessibilityId: .userHeaderExpandedAvatarButton)
    }

    @objc private func didTapEditAvatar() {
        delegate?.didTapEditAvatar()
    }
}
