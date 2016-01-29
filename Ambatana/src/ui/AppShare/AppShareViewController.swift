//
//  AppShareViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 28/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI

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
    @IBOutlet weak var dontAskAgainBtn: UIButton!

    static func showOnViewControllerIfNeeded(viewController: UIViewController) -> Bool {
        if !UserDefaultsManager.sharedInstance.loadAlreadyShared() {
            let appShareCtrl = AppShareViewController()
            viewController.presentViewController(appShareCtrl, animated: true, completion: nil)
            UserDefaultsManager.sharedInstance.saveAlreadyRated(true)
            return true
        }
        return false
    }

    init() {
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
        trackShown()
    }


    // MARK: - Actions

    @IBAction func onInviteFBMessenger(sender: AnyObject) {
        let socialMessage = SocialHelper.socialMessageAppShare(Constants.appShareFbMessengerURL)
        SocialHelper.shareOnFbMessenger(socialMessage, delegate: self)

        let trackerEvent = TrackerEvent.appInviteFriend(.FBMessenger, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    @IBAction func onInviteWhatsapp(sender: AnyObject) {
        let socialMessage = SocialHelper.socialMessageAppShare(Constants.appShareWhatsappURL)
        SocialHelper.shareOnWhatsapp(socialMessage, viewController: self)

        let trackerEvent = TrackerEvent.appInviteFriend(.Whatsapp, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    @IBAction func onInviteEmail(sender: AnyObject) {
        let socialMessage = SocialHelper.socialMessageAppShare(Constants.appShareEmailURL)
        SocialHelper.shareOnEmail(socialMessage, viewController: self, delegate: self)

        let trackerEvent = TrackerEvent.appInviteFriend(.Email, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onDontAskAgain(sender: AnyObject) {
        UserDefaultsManager.sharedInstance.saveAlreadyShared(true)
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius

        inviteFBMessengerBtn.setCustomButtonStyle()
        inviteWhatsappBtn.setCustomButtonStyle()
        inviteEmailBtn.setCustomButtonStyle()

        titleLabel.text = LGLocalizedString.appShareTitle
        subtitleLabel.text = LGLocalizedString.appShareSubtitle
        inviteFBMessengerBtn.setTitle(LGLocalizedString.appShareFbmessengerButton, forState: UIControlState.Normal)
        inviteWhatsappBtn.setTitle(LGLocalizedString.appShareWhatsappButton, forState: UIControlState.Normal)
        inviteEmailBtn.setTitle(LGLocalizedString.appShareEmailButton, forState: UIControlState.Normal)
        dontAskAgainBtn.setTitle(LGLocalizedString.ratingViewDontAskAgainButton, forState: UIControlState.Normal)

        if !SocialHelper.canShareInFBMessenger() {
            inviteFBMessengerHeight.constant = 0
            inviteFBMessengerTop.constant = 20
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

    private func trackShown() {
        let trackerEvent = TrackerEvent.appInviteFriendStart(.ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


// MARK: - FBSDKSharingDelegate

extension AppShareViewController: FBSDKSharingDelegate {

    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        guard let _ = results else {
            // success and no results means app invite has been cancelled via DONE in webview
            let trackerEvent = TrackerEvent.appInviteFriendCancel(.FBMessenger, typePage: .ProductDetail)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            return
        }
        let trackerEvent = TrackerEvent.appInviteFriendComplete(.FBMessenger, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
    }

    func sharerDidCancel(sharer: FBSDKSharing!) {
        let trackerEvent = TrackerEvent.appInviteFriendCancel(.FBMessenger, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension AppShareViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult,
        error: NSError?) {
            controller.dismissViewControllerAnimated(true, completion: nil)
            if result == MFMailComposeResultSent {
                let trackerEvent = TrackerEvent.appInviteFriendComplete(.Email, typePage: .ProductDetail)
                TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            } else if result == MFMailComposeResultCancelled {
                let trackerEvent = TrackerEvent.appInviteFriendCancel(.Email, typePage: .ProductDetail)
                TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            }
    }
}
