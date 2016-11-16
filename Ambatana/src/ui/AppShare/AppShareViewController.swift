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
    @IBOutlet weak var headerImageView: UIImageView!

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
    @IBOutlet weak var inviteEmailIcon: UIImageView!
    @IBOutlet weak var inviteEmailHeight: NSLayoutConstraint!
    @IBOutlet weak var inviteEmailTop: NSLayoutConstraint!

    let socialSharer = SocialSharer()

    static func canBeShown() -> Bool {
        return SocialSharer.canShareInAny([.FBMessenger, .Whatsapp, .Email])
    }

    static func showOnViewControllerIfNeeded(viewController: UIViewController) -> Bool {
        guard !KeyValueStorage.sharedInstance.userAppShared else { return false }
        guard canBeShown() else { return false }
        viewController.presentViewController(AppShareViewController(), animated: true, completion: nil)
        return true
    }

    init() {
        super.init(nibName: "AppShareViewController", bundle: nil)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
        socialSharer.delegate = self
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
        let socialMessage = AppShareSocialMessage()
        socialSharer.share(socialMessage, shareType: .FBMessenger, viewController: self)
    }

    @IBAction func onInviteWhatsapp(sender: AnyObject) {
        let socialMessage = AppShareSocialMessage()
        socialSharer.share(socialMessage, shareType: .Whatsapp, viewController: self)
    }

    @IBAction func onInviteEmail(sender: AnyObject) {
        let socialMessage = AppShareSocialMessage()
        socialSharer.share(socialMessage, shareType: .Email, viewController: self)
    }

    @IBAction func onClose(sender: AnyObject) {
        dismiss()
    }

    @IBAction func onDontAskAgain(sender: AnyObject) {
        KeyValueStorage.sharedInstance.userAppShared = true
        dismiss()

        let trackerEvent = TrackerEvent.appInviteFriendDontAsk(.ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = LGUIKitConstants.alertCornerRadius

        inviteFBMessengerBtn.setTitle(LGLocalizedString.appShareFbmessengerButton, forState: UIControlState.Normal)
        inviteWhatsappBtn.setTitle(LGLocalizedString.appShareWhatsappButton, forState: UIControlState.Normal)
        inviteEmailBtn.setTitle(LGLocalizedString.appShareEmailButton, forState: UIControlState.Normal)

        inviteFBMessengerBtn.rounded = true
        inviteWhatsappBtn.rounded = true
        inviteEmailBtn.rounded = true
        
        if !SocialSharer.canShareIn(.FBMessenger) {
            inviteFBMessengerHeight.constant = 0
            inviteFBMessengerTop.constant = 20
            inviteFBMessengerBtn.hidden = true
            inviteFBMessengerIcon.hidden = true
        }

        if !SocialSharer.canShareIn(.Whatsapp) {
            inviteWhatsappHeight.constant = 0
            inviteWhatsappTop.constant = 0
            inviteWhatsappBtn.hidden = true
            inviteWhatsappIcon.hidden = true
        }

        if !SocialSharer.canShareIn(.Email) {
            inviteEmailHeight.constant = 0
            inviteEmailTop.constant = 0
            inviteEmailBtn.hidden = true
            inviteEmailIcon.hidden = true
        }

        headerImageView.image = UIImage(named: "invite_letgo")
        titleLabel.text = LGLocalizedString.appShareTitle
        titleLabel.font = UIFont.systemMediumFont(size: 17)
        subtitleLabel.text = LGLocalizedString.appShareSubtitle
        subtitleLabel.font = UIFont.systemRegularFont(size: 15)
    }

    private func trackShown() {
        let trackerEvent = TrackerEvent.appInviteFriendStart(.ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func dismissShowingShareOk() {
        view.hidden = true
        showAutoFadingOutMessageAlert(LGLocalizedString.settingsInviteFacebookFriendsOk) { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: nil)
        }
    }

    private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - SocialShareDelegate

extension AppShareViewController: SocialSharerDelegate {
    func shareStartedIn(shareType: ShareType) {
        let trackerEvent = TrackerEvent.appInviteFriend(shareType.trackingShareNetwork, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        switch state {
        case .Completed:
            dismissShowingShareOk()

            let trackerEvent = TrackerEvent.appInviteFriendComplete(shareType.trackingShareNetwork, typePage: .ProductList)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        case .Cancelled, .Failed:
            let trackerEvent = TrackerEvent.appInviteFriendCancel(shareType.trackingShareNetwork, typePage: .ProductList)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        }

    }
}
