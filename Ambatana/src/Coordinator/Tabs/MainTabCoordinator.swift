//
//  MainTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class MainTabCoordinator: TabCoordinator {

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
        let viewModel = MainListingsViewModel(searchType: nil, tabNavigator: nil)
        let rootViewController = MainListingsViewController(viewModel: viewModel)
        self.init(listingRepository: listingRepository, userRepository: userRepository,
                  chatRepository: chatRepository, myUserRepository: myUserRepository,
                  installationRepository: installationRepository, bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage, tracker: tracker, rootViewController: rootViewController,
                  featureFlags: featureFlags, sessionManager: sessionManager)

        viewModel.navigator = self
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
        let vm = MainListingsViewModel(searchType: searchType, filters: listingFilters)
        vm.navigator = self
        let vc = MainListingsViewController(viewModel: vm)
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

    func openSearchAlertsList() {
        let vm = SearchAlertsListViewModel()
        vm.navigator = self
        let vc = SearchAlertsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openMap(with listingFilters: ListingFilters, locationManager: LocationManager) {
        let viewModel = ListingsMapViewModel(navigator: self,
                                             locationManager: locationManager,
                                             currentFilters: listingFilters,
                                             featureFlags: featureFlags)
        let viewController = ListingsMapViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension MainTabCoordinator: ListingsMapNavigator {
    func closeMap() {
        navigationController.popViewController(animated: true)
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

