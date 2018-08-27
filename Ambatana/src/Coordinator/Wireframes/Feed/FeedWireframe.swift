import LGCoreKit
import LGComponents

protocol FeedNavigator: class {
    func openFilters(withListingFilters listingFilters: ListingFilters,
                     filtersVMDataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func showPushPermissionsAlert(
        pushPermissionsManager: LGPushPermissionsManager,
        withPositiveAction positiveAction: @escaping (() -> Void),
        negativeAction: @escaping (() -> Void)
    )
    func openMap(navigator: ListingsMapNavigator,
                 requester: ListingListMultiRequester,
                 listingFilters: ListingFilters,
                 locationManager: LocationManager)
    func openAppInvite(myUserId: String?, myUserName: String?)
}

final class FeedWireframe: FeedNavigator {
    private let nc: UINavigationController?
    private let deepLinkMailBox: DeepLinkMailBox
    
    init(nc: UINavigationController?,
         deepLinkMailBox: DeepLinkMailBox = LGDeepLinkMailBox.sharedInstance) {
        self.nc = nc
        self.deepLinkMailBox = deepLinkMailBox
    }
    
    func openFilters(withListingFilters listingFilters: ListingFilters, filtersVMDataDelegate: FiltersViewModelDataDelegate?) {
        nc?.present(
            LGFiltersBuilder.modal.buildFilters(
                filters: listingFilters,
                dataDelegate: filtersVMDataDelegate
            ),
            animated: true,
            completion: nil
        )
    }
    
    func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate) {
        guard let strongNC = nc else { return }
        let assembly = QuickLocationFiltersBuilder.modal(strongNC)
        let vc = assembly.buildQuickLocationFilters(mode: .quickFilterLocation,
                                                    initialPlace: initialPlace,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: locationDelegate)
        strongNC.present(vc, animated: true, completion: nil)
    }
    
    func openMap(navigator: ListingsMapNavigator, requester: ListingListMultiRequester, listingFilters: ListingFilters, locationManager: LocationManager) {
        let viewModel = ListingsMapViewModel(navigator: navigator,
                                             currentFilters: listingFilters)
        let viewController = ListingsMapViewController(viewModel: viewModel)
        nc?.pushViewController(viewController, animated: true)
    }
    
    func showPushPermissionsAlert(pushPermissionsManager: LGPushPermissionsManager,
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
        nc?.showAlertWithTitle(
            R.Strings.profilePermissionsAlertTitle,
            text: R.Strings.profilePermissionsAlertMessage,
            alertType: .iconAlert(icon: R.Asset.IconsButtons.customPermissionProfile.image),
            actions: [positive, negative]
        )
    }
    
    func openAppInvite(myUserId: String?, myUserName: String?) {
        guard let myUserId = myUserId, let myUserName = myUserName else { return }
        guard let url = URL.makeInvitationDeepLink(
            withUsername: myUserName, andUserId: myUserId) else { return }
        deepLinkMailBox.push(convertible: url)
    }
}
