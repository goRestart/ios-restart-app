import LGCoreKit
import LGComponents

final class NotificationsTabCoordinator: TabCoordinator {

    init() {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager = LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = NotificationsViewModel()
        let featureFlags = FeatureFlags.sharedInstance
        let sessionManager = Core.sessionManager
        let rootViewController = NotificationsViewController(viewModel: viewModel)
        super.init(listingRepository: listingRepository, userRepository: userRepository,
                  chatRepository: chatRepository, myUserRepository: myUserRepository,
                  installationRepository: installationRepository, bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage, tracker: tracker,
                  rootViewController: rootViewController, featureFlags: featureFlags,
                  sessionManager: sessionManager,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)

        viewModel.navigator = self
    }

    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return true
    }
}


// MARK: - NotificationsTabNavigator

extension NotificationsTabCoordinator: NotificationsTabNavigator {
    func openMyRatingList() {
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        openRatingList(myUserId)
    }
    
    func openNotificationDeepLink(deepLink: DeepLink) {
        navigate(with: deepLink)
    }
}
