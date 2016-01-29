//
//  AppShareViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 28/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class AppShareViewController: UIViewController {
    @IBOutlet weak var contentContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var inviteFBMessengerBtn: UIButton!
    @IBOutlet weak var inviteFBMessengerIcon: UIImageView!
    @IBOutlet weak var inviteFBMessengerHeight: NSLayoutConstraint!
    @IBOutlet weak var inviteFBMessengerTop: NSLayoutConstraint!

    @IBOutlet weak var inviteWhatsappBtn: UIButton!
    @IBOutlet weak var inviteWhatsappIcon: UIImageView!
    @IBOutlet weak var inviteWhatsappHeight: NSLayoutConstraint!
    @IBOutlet weak var inviteWhatsappTop: NSLayoutConstraint!

    @IBOutlet weak var inviteEmailBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!

    private let socialMessage: SocialMessage

    static func showOnViewControllerIfNeeded(viewController: UIViewController) -> Bool {
        // If never shown before, show app share view
//        if !UserDefaultsManager.sharedInstance.loadAlreadyShared() {
            let appShareCtrl = AppShareViewController()
            viewController.presentViewController(appShareCtrl, animated: true, completion: nil)
            UserDefaultsManager.sharedInstance.saveAlreadyRated(true)
            return true
//        }
//        return false
    }

    init() {
        self.socialMessage = SocialMessage(title: "", body: "", url: nil, imageURL: nil)
        super.init(nibName: "AppShareViewController", bundle: nil)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }


    // MARK: - Actions

    @IBAction func onInviteFBMessenger(sender: AnyObject) {
    }

    @IBAction func onInviteWhatsapp(sender: AnyObject) {
    }

    @IBAction func onInviteEmail(sender: AnyObject) {
    }

    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius

        inviteFBMessengerBtn.setCustomButtonStyle()
        inviteWhatsappBtn.setCustomButtonStyle()
        inviteEmailBtn.setCustomButtonStyle()

        //TODO: i18n

        if !SocialHelper.canShareInFBMessenger() {
            inviteFBMessengerHeight.constant = 0
            inviteFBMessengerTop.constant = 0
            inviteFBMessengerBtn.hidden = true
            inviteFBMessengerIcon.hidden = true
        }

        if !SocialHelper.canShareInWhatsapp() {
            inviteWhatsappHeight.constant = 0
            inviteWhatsappTop.constant = 0
            inviteWhatsappBtn.hidden = true
            inviteWhatsappIcon.hidden = true
        }
    }
}
