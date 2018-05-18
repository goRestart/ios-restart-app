//
//  EditListingCoordinator.swift
//  LetGo
//
//  Created by Facundo Menzella on 16/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol EditListingCoordinatorDelegate: class {
    func editListingCoordinatorDidCancel(_ coordinator: EditListingCoordinator)
    func editListingCoordinator(_ coordinator: EditListingCoordinator,
                                didFinishWithListing listing: Listing,
                                bumpUpProductData: BumpUpProductData?,
                                timeSinceLastBump: TimeInterval?,
                                maxCountdown: TimeInterval)
}

final class EditListingCoordinator: Coordinator, EditListingNavigator {

    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController {
        return navigationController
    }
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager
    fileprivate let navigationController: UINavigationController
    
    weak var delegate: EditListingCoordinatorDelegate?

    convenience init(listing: Listing,
                     bumpUpProductData: BumpUpProductData?,
                     pageType: EventParameterTypePage?,
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval) {
        self.init(listing: listing,
                  bumpUpProductData: bumpUpProductData,
                  pageType: pageType,
                  listingCanBeBoosted: listingCanBeBoosted,
                  timeSinceLastBump: timeSinceLastBump,
                  maxCountdown: maxCountdown,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(listing: Listing,
         bumpUpProductData: BumpUpProductData?,
         pageType: EventParameterTypePage?,
         listingCanBeBoosted: Bool,
         timeSinceLastBump: TimeInterval?,
         maxCountdown: TimeInterval,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        let editVM = EditListingViewModel(listing: listing,
                                          pageType: pageType,
                                          bumpUpProductData: bumpUpProductData,
                                          listingCanBeBoosted: listingCanBeBoosted,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
        let editVC = EditListingViewController(viewModel: editVM)
        let navCtl = UINavigationController(rootViewController: editVC)
        self.navigationController = navCtl
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        editVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }

    // MARK: EditingListingNavigator

    func editingListingDidCancel() {
        closeCoordinator(animated: false) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.editListingCoordinatorDidCancel(strongSelf)
        }
    }

    func editingListingDidFinish(_ editedListing: Listing,
                                 bumpUpProductData: BumpUpProductData?,
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval) {
        closeCoordinator(animated: false) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.editListingCoordinator(strongSelf,
                                                        didFinishWithListing: editedListing,
                                                        bumpUpProductData: bumpUpProductData,
                                                        timeSinceLastBump: timeSinceLastBump,
                                                        maxCountdown: maxCountdown)
        }
    }
    
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
}
