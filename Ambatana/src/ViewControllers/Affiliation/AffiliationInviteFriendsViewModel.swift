import LGComponents
import LGCoreKit

final class AffiliationInviteFriendsViewModel: BaseViewModel {
    
    private let myUserRepository: MyUserRepository
    var navigator: AffiliationInviteFriendsNavigator?
    
    private let socialSharer: SocialSharer
    private let tracker: TrackerProxy

    // MARK: - Lifecycle
    
    convenience override init() {
        self.init(socialSharer: SocialSharer(),
                  myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(socialSharer: SocialSharer, myUserRepository: MyUserRepository, tracker: TrackerProxy) {
        self.socialSharer = socialSharer
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            tracker.trackEvent(TrackerEvent.appInviteFriendStart(.rewardCenter, rewardCampaign: .inviteFriendsAmazon))
        }
    }

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationInviteFriends()
        return true
    }

    func inviteSMSContactsButtonPressed() {
        navigator?.openAffiliationInviteSMSContacts()
    }
    
    func buildShare(type: ShareType, viewController: UIViewController) {
        let myUserId = myUserRepository.myUser?.objectId
        let myUserName = myUserRepository.myUser?.name
        let myUserAvatar = myUserRepository.myUser?.avatar?.fileURL?.absoluteString
        let socialMessage = AffiliationSocialMessage(myUserId:myUserId,
                                                     myUserName: myUserName,
                                                     myUserAvatar: myUserAvatar)
        socialSharer.share(socialMessage, shareType: type, viewController: viewController)
        socialSharer.delegate = viewController as? SocialSharerDelegate
    }
    
    func termsButtonPressed() {
        navigator?.openInviteTerms()
    }

    func shareOtherStarted() {
        tracker.trackEvent(TrackerEvent.appInviteFriend(.other,
                                                        typePage: .rewardCenter,
                                                        rewardCampaign: .inviteFriendsAmazon))
    }

    func shareOtherCompleted(withState state: SocialShareState) {
        guard state == .completed else { return }
        tracker.trackEvent(TrackerEvent.appInviteFriendComplete(.other,
                                                                typePage: .rewardCenter,
                                                                rewardCampaign: .inviteFriendsAmazon))
    }
}
