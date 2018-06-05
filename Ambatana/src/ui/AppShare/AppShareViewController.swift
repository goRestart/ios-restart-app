import UIKit
import LGComponents

final class AppShareViewController: UIViewController {

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

    fileprivate let socialSharer = SocialSharer()
    fileprivate let myUserId: String?
    fileprivate let myUserName: String?

    static func canBeShown() -> Bool {
        return SocialSharer.canShareInAny([.fbMessenger, .whatsapp, .email])
    }

    @discardableResult static func showOnViewControllerIfNeeded(_ viewController: UIViewController,
                                                                myUserId: String?,
                                                                myUserName: String?) -> Bool {
        guard !KeyValueStorage.sharedInstance.userAppShared else { return false }
        guard canBeShown() else { return false }
        viewController.present(AppShareViewController(myUserId: myUserId, myUserName: myUserName),
                               animated: true,
                               completion: nil)
        return true
    }

    init(myUserId: String?, myUserName: String?) {
        self.myUserId = myUserId
        self.myUserName = myUserName
        super.init(nibName: "AppShareViewController", bundle: nil)
        setupForModalWithNonOpaqueBackground()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        inviteFBMessengerBtn.setRoundedCorners()
        inviteWhatsappBtn.setRoundedCorners()
        inviteEmailBtn.setRoundedCorners()
    }


    // MARK: - Actions

    @IBAction func onInviteFBMessenger(_ sender: AnyObject) {
        let socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        socialSharer.share(socialMessage, shareType: .fbMessenger, viewController: self)
    }

    @IBAction func onInviteWhatsapp(_ sender: AnyObject) {
        let socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        socialSharer.share(socialMessage, shareType: .whatsapp, viewController: self)
    }

    @IBAction func onInviteEmail(_ sender: AnyObject) {
        let socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        socialSharer.share(socialMessage, shareType: .email, viewController: self)
    }

    @IBAction func onClose(_ sender: AnyObject) {
        dismiss()
    }

    @IBAction func onDontAskAgain(_ sender: AnyObject) {
        KeyValueStorage.sharedInstance.userAppShared = true
        dismiss()

        let trackerEvent = TrackerEvent.appInviteFriendDontAsk(.listingList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    // MARK: - Private methods

    private func setupUI() {
        contentContainer.cornerRadius = LGUIKitConstants.bigCornerRadius

        inviteFBMessengerBtn.setTitle(R.Strings.appShareFbmessengerButton, for: .normal)
        inviteWhatsappBtn.setTitle(R.Strings.appShareWhatsappButton, for: .normal)
        inviteEmailBtn.setTitle(R.Strings.appShareEmailButton, for: .normal)
        
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

        headerImageView.image = R.Asset.BackgroundsAndImages.inviteLetgo.image
        titleLabel.text = R.Strings.appShareTitle
        titleLabel.font = UIFont.systemMediumFont(size: 17)
        subtitleLabel.text = R.Strings.appShareSubtitle
        subtitleLabel.font = UIFont.systemRegularFont(size: 15)
    }

    private func trackShown() {
        let trackerEvent = TrackerEvent.appInviteFriendStart(.listingList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    fileprivate func dismissShowingShareOk() {
        view.isHidden = true
        showAutoFadingOutMessageAlert(message: R.Strings.settingsInviteFacebookFriendsOk) { [weak self] in
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
        let trackerEvent = TrackerEvent.appInviteFriend(shareType.trackingShareNetwork, typePage: .listingList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        switch state {
        case .completed:
            dismissShowingShareOk()

            let trackerEvent = TrackerEvent.appInviteFriendComplete(shareType.trackingShareNetwork, typePage: .listingList)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        case .cancelled, .failed:
            let trackerEvent = TrackerEvent.appInviteFriendCancel(shareType.trackingShareNetwork, typePage: .listingList)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        }

    }
}
