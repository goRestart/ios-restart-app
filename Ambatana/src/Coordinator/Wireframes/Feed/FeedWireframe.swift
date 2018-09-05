import LGCoreKit
import LGComponents

protocol FeedNavigator: class {
    func openFilters(withListingFilters listingFilters: ListingFilters,
                     filtersVMDataDelegate: FiltersViewModelDataDelegate?)
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
                      onUserSearchCallback onUserSearchCallback: ((SearchType) -> ())?)
    func openAppInvite(myUserId: String?, myUserName: String?)
    func openProFeed(navigator: MainTabNavigator?,
                     withSearchType: SearchType,
                     andFilters filters: ListingFilters)
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters)
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters,
                         shouldCloseOnRemoveAllFilters: Bool)
}

final class FeedWireframe: FeedNavigator {
    private let nc: UINavigationController
    private let deepLinkMailBox: DeepLinkMailBox
    
    init(nc: UINavigationController,
         deepLinkMailBox: DeepLinkMailBox = LGDeepLinkMailBox.sharedInstance) {
        self.nc = nc
        self.deepLinkMailBox = deepLinkMailBox
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
    
    func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate) {
        let assembly = QuickLocationFiltersBuilder.modal(nc)
        let vc = assembly.buildQuickLocationFilters(mode: .quickFilterLocation,
                                                    initialPlace: initialPlace,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: locationDelegate)
        nc.present(vc, animated: true, completion: nil)
    }
    
    func openMap(navigator: ListingsMapNavigator, requester: ListingListMultiRequester, listingFilters: ListingFilters, locationManager: LocationManager) {
        let viewModel = ListingsMapViewModel(navigator: navigator,
                                             currentFilters: listingFilters)
        let viewController = ListingsMapViewController(viewModel: viewModel)
        nc.pushViewController(viewController, animated: true)
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
                      onUserSearchCallback onUserSearchCallback: ((SearchType) -> ())?) {
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
        let (vc, vm) = FeedBuilder.standard(nc: nc).makePro(
            withSearchType: searchType,
            filters: filters,
            hideSearchBox: true,
            showFilters: false,
            showLocationEditButton: false
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
}
