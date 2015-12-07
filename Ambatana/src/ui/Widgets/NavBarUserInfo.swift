//
//  LGNavBarUserInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

protocol NavBarUserInfoDelegate: class {
    func navBarUserInfoTapped(navbarUserInfo: NavBarUserInfo)
}

@IBDesignable
class NavBarUserInfo: UIView {

    private static let nameLabelMargin = 8

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    weak var delegate: NavBarUserInfoDelegate?


    // MARK: - Static methods

    static func buildNavbarUserInfo() -> NavBarUserInfo? {
        guard let userInfoView = NSBundle.mainBundle().loadNibNamed("NavBarUserInfo", owner: self, options: nil).first
            as? NavBarUserInfo else { return nil }
        userInfoView.initialSetup()
        return userInfoView
    }


    // MARK: - Public methods

    func setupWith(avatar avatar: NSURL?, text: String?) {
        if let avatar = avatar {
            avatarImage.sd_setImageWithURL(avatar, placeholderImage: UIImage(named: "no_photo"))
        }

        nameLabel.text = text

        let maxSize = nameLabel.sizeThatFits(CGSize(width: CGFloat.max, height: nameLabel.height))
        self.width = avatarImage.width + NavBarUserInfo.nameLabelMargin + maxSize.width + NavBarUserInfo.nameLabelMargin
    }


    // MARK: - Private methods

    private func initialSetup() {
        avatarImage.layer.cornerRadius = CGRectGetWidth(avatarImage.frame) / 2

        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        addGestureRecognizer(tapGesture)
    }

    dynamic private func tapped() {
        delegate?.navBarUserInfoTapped(self)
    }
}
