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
    func editListingCoordinator(_ coordinator: EditListingCoordinator, didFinishWithListing listing: Listing)
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

    convenience init(listing: Listing, pageType: EventParameterTypePage?) {
        self.init(listing: listing,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager, pageType: pageType)
    }

    init(listing: Listing, bubbleNotificationManager: BubbleNotificationManager, sessionManager: SessionManager, pageType: EventParameterTypePage?) {
        let editVM = EditListingViewModel(listing: listing, pageType: pageType)
        let editVC = EditListingViewController(viewModel: editVM)
        let navCtl = UINavigationController(rootViewController: editVC)
        self.navigationController = navCtl
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        
        editVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        viewController.modalPresentationStyle = .overFullScreen
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

    func editingListingDidFinish(_ editedListing: Listing) {
        closeCoordinator(animated: false) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.editListingCoordinator(strongSelf, didFinishWithListing: editedListing)
        }
    }
    
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
}
