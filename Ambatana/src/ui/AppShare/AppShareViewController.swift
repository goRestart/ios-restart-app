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
        return SocialSharer.canShareInAny([.fbMessenger, .whatsapp, .email])
    }

    @discardableResult static func showOnViewControllerIfNeeded(_ viewController: UIViewController) -> Bool {
        guard !KeyValueStorage.sharedInstance.userAppShared else { return false }
        guard canBeShown() else { return false }
        viewController.present(AppShareViewController(), animated: true, completion: nil)
        return true
    }

    init() {
        super.init(nibName: "AppShareViewController", bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
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

    @IBAction func onInviteFBMessenger(_ sender: AnyObject) {
        let socialMessage = AppShareSocialMessage()
        socialSharer.share(socialMessage, shareType: .fbMessenger, viewController: self)
    }

    @IBAction func onInviteWhatsapp(_ sender: AnyObject) {
        let socialMessage = AppShareSocialMessage()
        socialSharer.share(socialMessage, shareType: .whatsapp, viewController: self)
    }

    @IBAction func onInviteEmail(_ sender: AnyObject) {
        let socialMessage = AppShareSocialMessage()
        socialSharer.share(socialMessage, shareType: .email, viewController: self)
    }

    @IBAction func onClose(_ sender: AnyObject) {
        dismiss()
    }

    @IBAction func onDontAskAgain(_ sender: AnyObject) {
        KeyValueStorage.sharedInstance.userAppShared = true
        dismiss()

        let trackerEvent = TrackerEvent.appInviteFriendDontAsk(.productList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = LGUIKitConstants.alertCornerRadius

        inviteFBMessengerBtn.setTitle(LGLocalizedString.appShareFbmessengerButton, for: .normal)
        inviteWhatsappBtn.setTitle(LGLocalizedString.appShareWhatsappButton, for: .normal)
        inviteEmailBtn.setTitle(LGLocalizedString.appShareEmailButton, for: .normal)

        inviteFBMessengerBtn.rounded = true
        inviteWhatsappBtn.rounded = true
        inviteEmailBtn.rounded = true
        
        if !SocialSharer.canShareIn(.fbMessenger) {
            inviteFBMessengerHeight.constant = 0
            inviteFBMessengerTop.constant = 20
            inviteFBMessengerBtn.isHidden = true
            inviteFBMessengerIcon.isHidden = true
        }

        if !SocialSharer.canShareIn(.whatsapp) {
            inviteWhatsappHeight.constant = 0
            inviteWhatsappTop.constant = 0
            inviteWhatsappBtn.isHidden = true
            inviteWhatsappIcon.isHidden = true
        }

        if !SocialSharer.canShareIn(.email) {
            inviteEmailHeight.constant = 0
            inviteEmailTop.constant = 0
            inviteEmailBtn.isHidden = true
            inviteEmailIcon.isHidden = true
        }

        headerImageView.image = UIImage(named: "invite_letgo")
        titleLabel.text = LGLocalizedString.appShareTitle
        titleLabel.font = UIFont.systemMediumFont(size: 17)
        subtitleLabel.text = LGLocalizedString.appShareSubtitle
        subtitleLabel.font = UIFont.systemRegularFont(size: 15)
    }

    private func trackShown() {
        let trackerEvent = TrackerEvent.appInviteFriendStart(.productList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    fileprivate func dismissShowingShareOk() {
        view.isHidden = true
        showAutoFadingOutMessageAlert(LGLocalizedString.settingsInviteFacebookFriendsOk) { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
    }

    private func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - SocialShareDelegate

extension AppShareViewController: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        let trackerEvent = TrackerEvent.appInviteFriend(shareType.trackingShareNetwork, typePage: .productList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        switch state {
        case .completed:
            dismissShowingShareOk()

            let trackerEvent = TrackerEvent.appInviteFriendComplete(shareType.trackingShareNetwork, typePage: .productList)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        case .cancelled, .failed:
            let trackerEvent = TrackerEvent.appInviteFriendCancel(shareType.trackingShareNetwork, typePage: .productList)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        }

    }
}
