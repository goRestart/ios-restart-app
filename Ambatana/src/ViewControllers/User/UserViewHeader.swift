//
//  UserViewHeader.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import SDWebImage

class UserViewHeader: UIView {

    static let height: CGFloat = 130
    private static let bgViewMaxHeight: CGFloat = 90

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bgViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sellingButton: UIButton!
    @IBOutlet weak var buyingButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var indicatorView: UIView!

    var indicatorSelectedColor: UIColor? {
        get {
            return indicatorView.backgroundColor
        }
        set {
            indicatorView.backgroundColor = newValue
        }
    }

    // MARK: - Lifecycle

    static func userViewHeader() -> UserViewHeader? {
        guard let view = NSBundle.mainBundle().loadNibNamed("UserViewHeader", owner: self,
            options: nil).first as? UserViewHeader else { return nil }
        view.setupUI()
        return view
    }
}


// MARK: - Public methods

extension UserViewHeader {
    func setAvatar(url: NSURL?, placeholderImage: UIImage?) {
        avatarImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage)
    }

    func setCollapsePercentage(percentage: CGFloat) {
        let maxH = UserViewHeader.bgViewMaxHeight
        let minH = sellingButton.frame.height

        let height = maxH - (maxH - minH) * percentage
        bgViewHeightConstraint.constant = min(maxH, height)
    }

    func setAvatarHidden(hidden: Bool) {
        let isHidden = avatarImageView.alpha == 0
        guard isHidden != hidden else { return }

        UIView.animateWithDuration(0.2) { [weak self] in
            self?.avatarImageView.alpha = hidden ? 0 : 1
        }
    }
}


// MARK: - Private methods

extension UserViewHeader {
    private func setupUI() {
        setupUserAvatarView()
    }

    private func setupUserAvatarView() {
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        avatarImageView.clipsToBounds = true
    }
}
