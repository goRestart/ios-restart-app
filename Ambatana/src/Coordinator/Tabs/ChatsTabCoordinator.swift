import LGCoreKit
import LGComponents

final class ChatsTabCoordinator: TabCoordinator {

    let chatConversationsListViewModel: ChatConversationsListViewModel
    
    convenience init() {
        self.init(chatConversationsListViewModel: ChatConversationsListViewModel())
    }
    
    init(chatConversationsListViewModel: ChatConversationsListViewModel) {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.chatConversationsListViewModel = chatConversationsListViewModel
        let rootViewController = ChatConversationsListViewController(viewModel: chatConversationsListViewModel)
        let sessionManager = Core.sessionManager
        super.init(listingRepository: listingRepository,
                  userRepository: userRepository,
                  chatRepository: chatRepository,
                  myUserRepository: myUserRepository,
                  installationRepository: installationRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage,
                  tracker: tracker,
                  rootViewController: rootViewController,
                  featureFlags: featureFlags,
                  sessionManager: sessionManager,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)
        
        chatConversationsListViewModel.navigator = self
    }

    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return true
    }
}

extension ChatsTabCoordinator: ChatsTabNavigator {
    func openBlockedUsers() {
        let vm = ChatBlockedUsersViewModel(navigator: self)
        let vc = ChatBlockedUsersViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openInactiveConversations() {
        let vm = ChatInactiveConversationsListViewModel(navigator: self)
        let vc = ChatInactiveConversationsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
