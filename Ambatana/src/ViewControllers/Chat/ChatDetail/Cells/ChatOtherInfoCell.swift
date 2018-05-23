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
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabelTop: NSLayoutConstraint!
    @IBOutlet weak var infoIconHeight: NSLayoutConstraint!
    @IBOutlet weak var infoIconTop: NSLayoutConstraint!

    fileprivate static let verticalMargin: CGFloat = 8
    fileprivate static let iconsMargin: CGFloat = 8
    fileprivate static let iconsHeight: CGFloat = 14
    fileprivate static let verifyIconsWidth: CGFloat = 20


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setAccessibilityIds()
    }
}


// MARK: - Public

extension ChatOtherInfoCell {
    func setupVerifiedInfo(facebook: Bool, google: Bool, email: Bool) {
        guard facebook || google || email else {
            setVerifyEnabled(false)
            return
        }
        setInfoEnabled(false)
        setVerifyEnabled(true)
        fbIconWidth.constant = facebook ? ChatOtherInfoCell.verifyIconsWidth : 0
        googleIconWidth.constant = google ? ChatOtherInfoCell.verifyIconsWidth : 0
        mailIconWidth.constant = email ? ChatOtherInfoCell.verifyIconsWidth : 0
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
        infoLabel.text = LGLocalizedString.chatUserInfoLetgoAssistant
    }
    
    private func setLocationEnabled(_ enabled: Bool) {
        locationIconTop.constant = enabled ? ChatOtherInfoCell.verticalMargin : 0
        locationIconHeight.constant =  enabled ? ChatOtherInfoCell.iconsHeight : 0
        locationLabel.isHidden = !enabled
    }
    
    private func setVerifyEnabled(_ enabled: Bool) {
        verifyIconTop.constant = enabled ? ChatOtherInfoCell.verticalMargin : 0
        verifyIconHeight.constant = enabled ? ChatOtherInfoCell.iconsHeight : 0
        verifyLabel.isHidden = !enabled
        verifyContainer.isHidden = !enabled
    }
    
    private func setInfoEnabled(_ enabled: Bool) {
        infoIconTop.constant = enabled ? ChatOtherInfoCell.verticalMargin : 0
        infoIconHeight.constant = enabled ? ChatOtherInfoCell.iconsHeight : 0
        infoLabel.isHidden = !enabled
        if !enabled {
            infoLabel.layout().height(0)
        }
    }
}


// MARK: - Private

fileprivate extension ChatOtherInfoCell {
    func setupUI() {
        userInfoContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        userInfoContainer.layer.shouldRasterize = true
        userInfoContainer.layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = .clear
        verifyLabel.text = LGLocalizedString.chatUserInfoVerifiedWith
    }
    
    func setAccessibilityIds() {
        set(accessibilityId: .chatOtherInfoCellContainer)
        nameLabel.set(accessibilityId: .chatOtherInfoCellNameLabel)
    }
}
