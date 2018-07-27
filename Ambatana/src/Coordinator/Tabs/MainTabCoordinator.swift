import LGCoreKit
import LGComponents

final class MainTabCoordinator: TabCoordinator, FeedNavigator {

    private let feedAssembly: FeedAssembly
    private let pushPermissionsManager: PushPermissionsManager

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
        let assembly = featureFlags.sectionedMainFeed.feedAssembly
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
                  feedAssembly: assembly,
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
         feedAssembly: FeedAssembly,
         pushPermissionsManager: PushPermissionsManager) {
        self.feedAssembly = feedAssembly
        let (vc, vm) = feedAssembly.make()
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
                   sessionManager: sessionManager)
        vm.navigator = self
    }
    

    func openSearch(_ query: String, categoriesString: String?) {
        var filters = ListingFilters()
        if let categoriesString = categoriesString {
            filters.selectedCategories = ListingCategory.categoriesFromString(categoriesString)
        }
        let viewModel = MainListingsViewModel(searchType: .user(query: query), filters: filters)
        viewModel.navigator = self
        let vc = MainListingsViewController(viewModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }

    func readyToSearch() {
        guard let vc = rootViewController as? MainListingsViewController else { return }
        vc.searchTextFieldReadyToSearch()
    }

    // Note: override in subclasses
    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return super.shouldHideSellButtonAtViewController(viewController) && !(viewController is MainListingsViewController)
    }
}

extension MainTabCoordinator: MainTabNavigator {

    func openLoginIfNeeded(infoMessage: String, then loggedAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: .directChat, style: .popup(infoMessage), loggedInAction: loggedAction, cancelAction: nil)
    }

    func openMainListings(withSearchType searchType: SearchType, listingFilters: ListingFilters) {
        let (vc, vm) = feedAssembly.makeWith(searchType: searchType, filters: listingFilters)
        vm.navigator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func openFilters(withListingFilters listingFilters: ListingFilters,
                     filtersVMDataDelegate: FiltersViewModelDataDelegate?) {
        let vm = FiltersViewModel(currentFilters: listingFilters)
        vm.dataDelegate = filtersVMDataDelegate
        let filtersCoordinator = FiltersCoordinator(viewModel: vm)
        openChild(coordinator: filtersCoordinator, parent: navigationController,
                  animated: true, forceCloseChild: true, completion: nil)
    }

    func openLocationSelection(initialPlace: Place?,
                               distanceRadius: Int?,
                               locationDelegate: EditLocationDelegate) {
        guard let editLocationFiltersCoord =
            QuickLocationFiltersCoordinator(initialPlace: initialPlace,
                                            distanceRadius: distanceRadius,
                                            locationDelegate: locationDelegate) else { return }
        openChild(coordinator: editLocationFiltersCoord,
                  parent: rootViewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openTaxonomyList(withViewModel viewModel: TaxonomiesViewModel) {
        let vc = TaxonomiesViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    

    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void), negativeAction: @escaping (() -> Void)) {
        
        let positive: UIAction = UIAction(interface: .styledText(R.Strings.profilePermissionsAlertOk, .standard),
                                          action: { [weak self] in
                                            positiveAction()
                                            self?.pushPermissionsManager.showPushPermissionsAlert(prePermissionType: .listingListBanner)
        },
                                          accessibility: AccessibilityId.userPushPermissionOK)
        
        let negative: UIAction = UIAction(interface: .styledText(R.Strings.profilePermissionsAlertCancel, .cancel),
                                          action: negativeAction,
                                          accessibility: AccessibilityId.userPushPermissionCancel)
        navigationController.showAlertWithTitle(R.Strings.profilePermissionsAlertTitle,
                                                text: R.Strings.profilePermissionsAlertMessage,
                                                alertType: .iconAlert(icon: R.Asset.IconsButtons.customPermissionProfile.image),
                                                actions: [positive, negative])
    }
    
    func openSearchAlertsList() {
        let vm = SearchAlertsListViewModel()
        vm.navigator = self
        let vc = SearchAlertsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }


    func openMap(requester: ListingListMultiRequester,
                 listingFilters: ListingFilters,
                 locationManager: LocationManager) {
        let viewModel = ListingsMapViewModel(navigator: self,
                                             tracker: tracker,
                                             myUserRepository: myUserRepository,
                                             locationManager: locationManager,
                                             currentFilters: listingFilters,
                                             featureFlags: featureFlags)
        let viewController = ListingsMapViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openAskPhoneFromMainFeedFor(listing: Listing, interlocutor: User?) {
        let askNumVM = ProfessionalDealerAskPhoneViewModel(listing: listing, interlocutor: interlocutor, typePage: .feed)
        askNumVM.navigator = self
        let askNumVC = ProfessionalDealerAskPhoneViewController(viewModel: askNumVM)
        askNumVC.setupForModalWithNonOpaqueBackground()
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: true,
                                               animated: false)
        navigationController.present(askNumVC, animated: true, completion: nil)
    }

    func openPrivateUserProfile() {
        openLoginIfNeeded(from: .profile, style: .fullScreen, loggedInAction: {
            let coord = ProfileTabCoordinator(source: .mainListing)
            self.openChild(coordinator: coord, parent: self.rootViewController, animated: true, forceCloseChild: true, completion: nil)
        }, cancelAction: nil)
    }

    func openCommunity() {
        guard featureFlags.community.isActive else { return }
        if featureFlags.community.shouldShowOnTab {
            openCommunityTab()
        } else {
            let coord = CommunityTabCoordinator(source: .navBar)
            openChild(coordinator: coord, parent: rootViewController, animated: true, forceCloseChild: true, completion: nil)
        }
    }
} 

extension MainTabCoordinator: SearchAlertsListNavigator {
    func closeSearchAlertsList() {
        navigationController.popViewController(animated: true)
    }

    func openSearch() {
        navigationController.popToRootViewController(animated: false)
        readyToSearch()
    }
}

