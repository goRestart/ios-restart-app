//
//  EditLocationFiltersCoordinator.swift
//  LetGo
//
//  Created by Dídac on 29/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


class EditLocationFiltersCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager


    convenience init?(initialPlace: Place?, locationDelegate: EditLocationDelegate) {
        self.init(initialPlace: initialPlace,
                  locationDelegate: locationDelegate,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init?(initialPlace: Place?,
         locationDelegate: EditLocationDelegate,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable) {

        switch featureFlags.editLocationBubble {
        case .inactive:
            return nil
        case .map:
            // TODO: ad open map edit location
            return nil
        case .zipCode:
            let zipLocationVM = LocationFromZipCodeViewModel(initialPlace: initialPlace)
            zipLocationVM.locationDelegate = locationDelegate
            let zipLocationVC = LocationFromZipCodeViewController(viewModel: zipLocationVM)

            self.viewController = zipLocationVC
            self.bubbleNotificationManager = bubbleNotificationManager
            self.sessionManager = sessionManager
            zipLocationVM.navigator = self
        }
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}


extension EditLocationFiltersCoordinator : EditLocationFiltersNavigator {
    func editLocationFromZipDidClose() {
        closeCoordinator(animated: true, completion: nil)
    }
}
