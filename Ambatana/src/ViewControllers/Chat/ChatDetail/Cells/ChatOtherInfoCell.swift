//
//  ChatOtherInfoCell.swift
//  LetGo
//
//  Created by Eli Kohen on 14/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatOtherInfoCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var userInfoContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifyIcon: UIImageView!
    @IBOutlet weak var verifyIconHeight: NSLayoutConstraint!
    @IBOutlet weak var verifyIconTop: NSLayoutConstraint!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var verifyContainer: UIView!
    @IBOutlet weak var fbIconWidth: NSLayoutConstraint!
    @IBOutlet weak var googleIconWidth: NSLayoutConstraint!
    @IBOutlet weak var mailIconWidth: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIconHeight: NSLayoutConstraint!
    @IBOutlet weak var locationIconTop: NSLayoutConstraint!

    private static let iconsMargin: CGFloat = 8
    private static let iconsHeight: CGFloat = 14
    private static let verifyIconsWidth: CGFloat = 20


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}


// MARK: - Public

extension ChatOtherInfoCell {
    func setupVerifiedInfo(facebook facebook: Bool, google: Bool, email: Bool) {
        guard facebook || google || email else {
            verifyIconTop.constant = 0
            verifyIconHeight.constant = 0
            verifyLabel.hidden = true
            verifyContainer.hidden = true
            return
        }
        verifyIconTop.constant = ChatOtherInfoCell.iconsMargin
        verifyIconHeight.constant = ChatOtherInfoCell.iconsHeight
        verifyLabel.hidden = false
        verifyContainer.hidden = false

        fbIconWidth.constant = facebook ? ChatOtherInfoCell.verifyIconsWidth : 0
        googleIconWidth.constant = google ? ChatOtherInfoCell.verifyIconsWidth : 0
        mailIconWidth.constant = email ? ChatOtherInfoCell.verifyIconsWidth : 0
    }

    func setupLocation(location: String?) {
        guard let location = location where !location.isEmpty else {
            locationIconTop.constant = 0
            locationIconHeight.constant = 0
            locationLabel.hidden = true
            return
        }
        locationIconTop.constant = ChatOtherInfoCell.iconsMargin
        locationIconHeight.constant = ChatOtherInfoCell.iconsHeight
        locationLabel.hidden = false
        locationLabel.text = location
    }
}


// MARK: - Private

private extension ChatOtherInfoCell {
    func setupUI() {
        userInfoContainer.layer.cornerRadius = LGUIKitConstants.chatCellCornerRadius
        userInfoContainer.layer.shouldRasterize = true
        userInfoContainer.layer.rasterizationScale = UIScreen.mainScreen().scale
        backgroundColor = UIColor.clearColor()
        verifyLabel.text = LGLocalizedString.chatUserInfoVerifiedWith
    }
}
