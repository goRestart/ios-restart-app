//
//  QuickLocationFiltersCoordinator.swift
//  LetGo
//
//  Created by Dídac on 29/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


class QuickLocationFiltersCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager


    convenience init?(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate) {
        self.init(initialPlace: initialPlace,
                  distanceRadius: distanceRadius,
                  locationDelegate: locationDelegate,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init?(initialPlace: Place?,
          distanceRadius: Int?,
          locationDelegate: EditLocationDelegate,
          bubbleNotificationManager: BubbleNotificationManager,
          sessionManager: SessionManager,
          featureFlags: FeatureFlaggeable) {
        let vm = EditLocationViewModel(mode: .quickFilterLocation,
                                       initialPlace: initialPlace,
                                       distanceRadius: distanceRadius)
        vm.locationDelegate = locationDelegate
        let vc =  UINavigationController(rootViewController: EditLocationViewController(viewModel: vm))
        self.viewController = vc
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        vm.quickLocationFiltersNavigator = self
    }
    
    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}


extension QuickLocationFiltersCoordinator : QuickLocationFiltersNavigator {
    func closeQuickLocationFilters() {
        closeCoordinator(animated: true, completion: nil)
    }

    func editLocationFromMapDidClose() {
        closeCoordinator(animated: true, completion: nil)
    }
}
