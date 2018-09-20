import LGCoreKit
import LGComponents

final class MainTabCoordinator: TabCoordinator {
    private lazy var phoneAskAssembly = ProfessionalDealerAskPhoneBuilder.modal(rootViewController)
    private var feedType: FeedType = .classic
    private let pushPermissionsManager: PushPermissionsManager
    private var feedNC: UINavigationController
    
    convenience init() {
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let sessionManager = Core.sessionManager
        let assembly = featureFlags.sectionedFeed.feedAssembly
        let pushPermissionsManager = LGPushPermissionsManager.sharedInstance
        self.init(listingRepository: listingRepository,
                  userRepository: userRepository,
                  chatRepository: chatRepository,
                  myUserRepository: myUserRepository,
                  installationRepository: installationRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage,
                  tracker: tracker,
                  featureFlags: featureFlags,
                  sessionManager: sessionManager,
                  feedType: assembly,
                  pushPermissionsManager: pushPermissionsManager)
    }

    init(listingRepository: ListingRepository,
         userRepository: UserRepository,
         chatRepository: ChatRepository,
         myUserRepository: MyUserRepository,
         installationRepository: InstallationRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         sessionManager: SessionManager,
         feedType: FeedType,
         pushPermissionsManager: PushPermissionsManager) {
        // Alloc a external navigation controller due a architecture limitation,
        // the Navigation controller is alloced in the Tab Coordinator constructor
        // but the new architeture requires a reference to the nc, so it should be alloced
        // in the same place than the Feed. It should be changed in a future
        // (MainTabCoordinator migration).
        // The tab coordinator will keep alive the navigation bar, it has a strong
        // reference.
        let nav = UINavigationController()
        let vc: BaseViewController
        let vm: FeedNavigatorOwnership
        
        if feedType == .pro {
            (vc, vm) = FeedBuilder.standard(nc: nav).makePro()
        } else {
            (vc, vm) = FeedBuilder.standard(nc: nav).makeClassic()
        }
        feedNC = nav
        self.pushPermissionsManager = pushPermissionsManager
        
        super.init(listingRepository: listingRepository,
                   userRepository: userRepository,
                   chatRepository: chatRepository,
                   myUserRepository: myUserRepository,
                   installationRepository: installationRepository,
                   bubbleNotificationManager: bubbleNotificationManager,
                   keyValueStorage: keyValueStorage,
                   tracker: tracker,
                   rootViewController: vc,
                   featureFlags: featureFlags,
                   sessionManager: sessionManager,
                   deeplinkMailBox: LGDeepLinkMailBox.sharedInstance,
                   externalNC: nav)
        nav.setViewControllers([vc], animated: false)
        vm.navigator = self
        self.feedType = feedType
    }
    

    func openSearch(query: String?,
                    categories: String?,
                    distanceRadius: String?,
                    sortCriteria: String?,
                    priceFlag: String?,
                    minPrice: String?,
                    maxPrice: String?) {
        let filters = ListingFilters(categoriesString: categories,
                                     distanceRadiusString: distanceRadius,
                                     sortCriteriaString: sortCriteria,
                                     priceFlagString: priceFlag,
                                     minPriceString: minPrice,
                                     maxPriceString: maxPrice)
        let searchType: SearchType?
        if let query = query {
            searchType = .user(query: query)
        } else {
            searchType = nil
        }
        let viewModel = MainListingsViewModel(searchType: searchType, filters: filters)
        viewModel.navigator = self
        viewModel.wireframe = MainListingWireframe(nc: navigationController)
        let vc = MainListingsViewController(viewModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }

    func readyToSearch() {
        guard let vc = rootViewController as? MainListingsViewController else { return }
        vc.searchTextFieldReadyToSearch()
    }

    // Note: override in subclasses
    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return super.shouldHideSellButtonAtViewController(viewController) &&
            !(viewController is MainListingsViewController || viewController is FeedViewController)
    }
}

extension MainTabCoordinator: MainTabNavigator {
    func openListingChat(_ listing: Listing,
                         source: EventParameterTypePage,
                         interlocutor: User?) {
        chatNavigator.openListingChat(listing,
                                      source: source,
                                      interlocutor: interlocutor,
                                      openChatAutomaticMessage: nil)
    }

    func openLoginIfNeeded(infoMessage: String, then loggedAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedAction()
            return
        }
        
        let vc = LoginBuilder.modal.buildPopupSignUp(
            withMessage: infoMessage,
            andSource: .directChat,
            loginAction: loggedAction,
            cancelAction: nil
        )
        viewController.present(vc, animated: true, completion: nil)
    }

    func openFullLoginIfNeeded(source: EventParameterLoginSourceValue, then loggedAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedAction()
            return
        }

        let vc = LoginBuilder.modal.buildMainSignIn(
            withSource: source,
            loginAction: loggedAction,
            cancelAction: nil)
        let nav = UINavigationController(rootViewController: vc)
        viewController.present(nav, animated: true, completion: nil)
    }

    func openMainListings(withSearchType searchType: SearchType, listingFilters: ListingFilters) {
        let vc: BaseViewController
        let vm: FeedNavigatorOwnership
        
        if feedType == .pro {
            (vc, vm) = FeedBuilder.standard(nc: feedNC).makePro(
                withSearchType: searchType, filters: listingFilters)
        } else {
            (vc, vm) = FeedBuilder.standard(nc: feedNC).makeClassic(
                withSearchType: searchType, filters: listingFilters)
        }
        
        vm.navigator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func openSearchAlertsList() {
        let vm = SearchAlertsListViewModel()
        vm.navigator = self
        let vc = SearchAlertsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openAskPhoneFromMainFeedFor(listing: Listing, interlocutor: User?) {
        let vc = phoneAskAssembly.buildProfessionalDealerAskPhone(listing: listing,
                                                                  interlocutor: interlocutor,
                                                                  chatNavigator: chatNavigator)
        navigationController.present(vc, animated: true, completion: nil)
    }

    func openPrivateUserProfile() {
        openFullLoginIfNeeded(source: .profile) {
            let coord = ProfileTabCoordinator(source: .mainListing)
            self.openChild(coordinator: coord,
                           parent: self.rootViewController,
                           animated: true,
                           forceCloseChild: true,
                           completion: nil)
        }
    }

    func openCommunity() {
        if featureFlags.community.shouldShowOnTab {
            openCommunityTab()
        } else if featureFlags.community.shouldShowOnNavBar {
            let coord = CommunityTabCoordinator(source: .navBar)
            openChild(coordinator: coord, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
        }
    }
    
    func openAffiliation() {
        guard featureFlags.affiliationEnabled.isActive else { return }
        openFullLoginIfNeeded(source: .feed) { [weak self] in
            guard let navigationController = self?.navigationController else { return }
            let affiliationChallengesAssembly = AffiliationChallengesBuilder.standard(navigationController)
            let vc = affiliationChallengesAssembly.buildAffiliationChallenges()
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func openAffiliationOnboarding(data: ReferrerInfo) {
        //TODO: Here facu's view for onboarding
        let alert = UIAlertController(title: "onboarding",
                                      message: "Aqui saldrá la pantalla molona",
                                      preferredStyle: .alert)
        let positive = UIAlertAction(title: "go!", style: .default) {[weak self] _ in
            self?.openAffiliation()
        }
        alert.add([positive])
        viewController.present(alert, animated: true, completion: nil)
    }

    func openSearches() {
        openChild(coordinator: SearchCoordinator(),
                  parent: rootViewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }
    
    func openWrongCountryModal() {
        let primaryAction = UIAction(interface: .button(R.Strings.affiliationOnboardingCountryErrorMainButton, .primary(fontSize: .medium)),
                                     action: { [weak self] in self?.appNavigator?.openSell(source: .referralNotAvailable, postCategory: nil, listingTitle: nil)
        })
        let secondaryAction = UIAction(interface: .button(R.Strings.affiliationOnboardingCountryErrorSecondaryButton, .terciary),
                                       action: { [weak self] in
                                        self?.appNavigator?.openHome()
        })
        let data = AffiliationModalData(
            icon: R.Asset.Affiliation.Error.errorFeatureUnavailable.image,
            headline: R.Strings.affiliationWrongCountryErrorHeadline,
            subheadline: R.Strings.affiliationWrongCountryErrorSubheadline,
            primary: primaryAction,
            secondary: secondaryAction
        )
        let vm = AffiliationModalViewModel(data: data)
        let vc = AffiliationModalViewController(viewModel: vm)
        
        vm.active = true
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        navigationController.present(vc, animated: true, completion: nil)
    }
}

extension MainTabCoordinator: ListingsMapNavigator { }

extension MainTabCoordinator: SearchAlertsListNavigator {
    func closeSearchAlertsList() {
        navigationController.popViewController(animated: true)
    }

    func openSearch() {
        navigationController.popToRootViewController(animated: false)
        readyToSearch()
    }
}
