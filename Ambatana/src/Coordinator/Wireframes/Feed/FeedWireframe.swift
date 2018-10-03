import LGCoreKit
import LGComponents

protocol FeedNavigator: class {
    func openFilters(withListingFilters listingFilters: ListingFilters,
                     filtersVMDataDelegate: FiltersViewModelDataDelegate?)
    func openAffiliationChallenges()
    func openLoginIfNeededFromFeed(from: EventParameterLoginSourceValue,
                                   loggedInAction: @escaping (() -> Void))
    func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func showPushPermissionsAlert(
        pushPermissionsManager: PushPermissionsManager,
        withPositiveAction positiveAction: @escaping (() -> Void),
        negativeAction: @escaping (() -> Void)
    )
    func openMap(navigator: ListingsMapNavigator,
                 requester: ListingListMultiRequester,
                 listingFilters: ListingFilters,
                 locationManager: LocationManager)
    func openSearches(withSearchType searchType: SearchType?,
                      onUserSearchCallback: ((SearchType) -> ())?)
    func openAppInvite(myUserId: String?, myUserName: String?)
    func openProFeed(navigator: MainTabNavigator?,
                     withSearchType: SearchType,
                     andFilters filters: ListingFilters)
    func openProFeed(navigator: MainTabNavigator?,
                     withSearchType: SearchType,
                     andFilters filters: ListingFilters,
                     andComingSectionPosition: UInt?,
                     andComingSectionIdentifier: String?)
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters)
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters,
                         shouldCloseOnRemoveAllFilters: Bool)
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters,
                         shouldCloseOnRemoveAllFilters: Bool,
                         tagsDelegate: MainListingsTagsDelegate?)
}

final class FeedWireframe: FeedNavigator {
    private let nc: UINavigationController
    private let deepLinkMailBox: DeepLinkMailBox
    private let listingsMapAssembly: ListingsMapAssembly
    private let sessionManager: SessionManager
    private let loginAssembly: LoginAssembly
    private lazy var affiliationChallengesAssembly = AffiliationChallengesBuilder.standard(nc)


    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  deepLinkMailBox: LGDeepLinkMailBox.sharedInstance,
                  listingsMapAssembly: ListingsMapBuilder.standard(nc),
                  loginAssembly: LoginBuilder.standard(context: nc),
                  sessionManager: Core.sessionManager)
    }

    init(nc: UINavigationController,
         deepLinkMailBox: DeepLinkMailBox,
         listingsMapAssembly: ListingsMapAssembly,
         loginAssembly: LoginAssembly,
         sessionManager: SessionManager) {
        self.nc = nc
        self.listingsMapAssembly = listingsMapAssembly
        self.deepLinkMailBox = deepLinkMailBox
        self.loginAssembly = loginAssembly
        self.sessionManager = sessionManager
    }
    
    func openFilters(withListingFilters listingFilters: ListingFilters, filtersVMDataDelegate: FiltersViewModelDataDelegate?) {
        nc.present(
            LGFiltersBuilder.modal.buildFilters(
                filters: listingFilters,
                dataDelegate: filtersVMDataDelegate
            ),
            animated: true,
            completion: nil
        )
    }
    
    func openAffiliationChallenges() {
        let vc = affiliationChallengesAssembly.buildAffiliationChallenges(source: .feed(.icon))
        nc.pushViewController(vc, animated: true)
    }
    
    func openLoginIfNeededFromFeed(from: EventParameterLoginSourceValue,
                                   loggedInAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }
        
        let vc = LoginBuilder.modal.buildMainSignIn(
            withSource: from,
            loginAction: loggedInAction,
            cancelAction: nil)
        let nav = UINavigationController(rootViewController: vc)
        nc.present(nav, animated: true, completion: nil)
    }

    func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate) {
        let assembly = QuickLocationFiltersBuilder.modal(nc)
        let vc = assembly.buildQuickLocationFilters(mode: .quickFilterLocation,
                                                    initialPlace: initialPlace,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: locationDelegate)
        nc.present(vc, animated: true, completion: nil)
    }
    
    func openMap(navigator: ListingsMapNavigator,
                 requester: ListingListMultiRequester,
                 listingFilters: ListingFilters,
                 locationManager: LocationManager) {
        let vc = listingsMapAssembly.buildListingsMap(filters: listingFilters)
        nc.pushViewController(vc, animated: true)
    }
    
    func showPushPermissionsAlert(pushPermissionsManager: PushPermissionsManager,
                                  withPositiveAction positiveAction: @escaping (() -> Void),
                                  negativeAction: @escaping (() -> Void)) {
        let positive: UIAction = UIAction(
            interface: .styledText(R.Strings.profilePermissionsAlertOk, .standard),
            action: {
                positiveAction()
                pushPermissionsManager.showPushPermissionsAlert(
                    prePermissionType: .listingListBanner)
            },
            accessibility: AccessibilityId.userPushPermissionOK)
        let negative: UIAction = UIAction(
            interface: .styledText(R.Strings.profilePermissionsAlertCancel, .cancel),
            action: negativeAction,
            accessibility: AccessibilityId.userPushPermissionCancel
        )
        nc.showAlertWithTitle(
            R.Strings.profilePermissionsAlertTitle,
            text: R.Strings.profilePermissionsAlertMessage,
            alertType: .iconAlert(icon: R.Asset.IconsButtons.customPermissionProfile.image),
            actions: [positive, negative]
        )
    }
    
    func openSearches(withSearchType searchType: SearchType?,
                      onUserSearchCallback: ((SearchType) -> ())?) {
        nc.present(
            UINavigationController(rootViewController:
                SearchBuilder.modal(root: nc).buildSearch(
                    withSearchType: searchType,
                    onUserSearchCallback: onUserSearchCallback)),
            animated: true,
            completion: nil)
    }
    
    func openAppInvite(myUserId: String?, myUserName: String?) {
        guard let myUserId = myUserId, let myUserName = myUserName else { return }
        guard let url = URL.makeInvitationDeepLink(
            withUsername: myUserName, andUserId: myUserId) else { return }
        deepLinkMailBox.push(convertible: url)
    }
    
    func openProFeed(navigator: MainTabNavigator?,
                     withSearchType searchType: SearchType,
                     andFilters filters: ListingFilters) {
       openProFeed(navigator: navigator,
                   withSearchType: searchType,
                   andFilters: filters,
                   andComingSectionPosition: nil,
                   andComingSectionIdentifier: nil)
    }
    
    func openProFeed(navigator: MainTabNavigator?,
                     withSearchType searchType: SearchType,
                     andFilters filters: ListingFilters,
                     andComingSectionPosition position: UInt?,
                     andComingSectionIdentifier identifier: String?) {
        let (vc, vm) = FeedBuilder.standard(nc: nc).makePro(
            withSearchType: searchType,
            filters: filters,
            hideSearchBox: true,
            showRightNavBarButtons: false,
            showLocationEditButton: false,
            comingSectionPosition: position,
            comingSectionIdentifier: identifier
        )
        vm.navigator = navigator
        nc.pushViewController(vc, animated: true)
    }
    
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType? = nil,
                         listingFilters: ListingFilters) {
        let (vc, vm) = FeedBuilder.standard(nc: nc).makeClassic(
            withSearchType: searchType,
            filters: listingFilters,
            shouldCloseOnRemoveAllFilters: false
        )
        vm.navigator = navigator
        nc.pushViewController(vc, animated: true)
    }
    
    /// In a near future the navigator should be deleted, it is necesary because
    /// the VM needs it to handle just 2 method but that 2 methos have lots of
    /// dependencies over the coordinator. If the coordinator is migrated
    /// the navigator reference could be deleted.
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType? = nil,
                         listingFilters: ListingFilters,
                         shouldCloseOnRemoveAllFilters: Bool = false) {
        let (vc, vm) = FeedBuilder.standard(nc: nc).makeClassic(
                withSearchType: searchType,
                filters: listingFilters,
                shouldCloseOnRemoveAllFilters: shouldCloseOnRemoveAllFilters
        )
        vm.navigator = navigator
        nc.pushViewController(vc, animated: true)
    }
    
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType? = nil,
                         listingFilters: ListingFilters,
                         shouldCloseOnRemoveAllFilters: Bool = false,
                         tagsDelegate: MainListingsTagsDelegate? = nil) {
        let (vc, vm) = FeedBuilder.standard(nc: nc).makeClassic(
            withSearchType: searchType,
            filters: listingFilters,
            shouldCloseOnRemoveAllFilters: shouldCloseOnRemoveAllFilters,
            tagsDelegate: tagsDelegate
        )
        vm.navigator = navigator
        nc.pushViewController(vc, animated: true)
    }
}
