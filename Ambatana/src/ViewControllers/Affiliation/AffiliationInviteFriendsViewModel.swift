import LGComponents
import LGCoreKit

final class AffiliationInviteFriendsViewModel: BaseViewModel {
    
    private let myUserRepository: MyUserRepository
    var navigator: AffiliationInviteFriendsNavigator?
    
    private let socialSharer: SocialSharer
    
    // MARK: - Lifecycle
    
    convenience override init() {
        self.init(socialSharer: SocialSharer(),
                  myUserRepository: Core.myUserRepository)
    }
    
    init(socialSharer: SocialSharer, myUserRepository: MyUserRepository) {
        self.socialSharer = socialSharer
        self.myUserRepository = myUserRepository
        super.init()
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
}
