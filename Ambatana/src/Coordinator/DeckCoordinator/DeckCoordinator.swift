//
//  DeckCoordinator.swift
//  LetGo
//
//  Created by Facundo Menzella on 02/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol DeckNavigator: class {
    func openPhotoViewer(withURLs urls: [URL], quickChatViewModel: QuickChatViewModel)
    func closePhotoViewer()
    func closeDeck()
}

final class DeckCoordinator: NSObject, Coordinator, DeckNavigator {

    var child: Coordinator?
    let viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    fileprivate weak var previousNavigationDelegate: UINavigationControllerDelegate?
    fileprivate let deckViewController: ListingDeckViewController

    convenience init(listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     listingNavigator: ListingDetailNavigator) {
        self.init(listing: listing,
                  listingListRequester: listingListRequester,
                  source: source,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  listingNavigator: listingNavigator)
    }

    private init(listing: Listing,
                 listingListRequester: ListingListRequester,
                 source: EventParameterListingVisitSource,
                 bubbleNotificationManager: BubbleNotificationManager,
                 sessionManager: SessionManager,
                 listingNavigator: ListingDetailNavigator) {

        let viewModel = ListingDeckViewModel(listing: listing,
                                             listingListRequester: listingListRequester,
                                             source: source,
                                             detailNavigator: listingNavigator)
        let deckViewController = ListingDeckViewController(viewModel: viewModel)
        viewModel.delegate = deckViewController
        viewModel.navigator = listingNavigator

        self.deckViewController = deckViewController
        self.viewController = deckViewController
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        super.init()
        viewModel.deckNavigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        guard let navController = parent as? UINavigationController else { return }
        previousNavigationDelegate = navController.delegate
        navController.delegate = self
        navController.pushViewController(viewController, animated: true)
        completion?()
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        guard let navController = viewController.parent as? UINavigationController else { return }
        navController.popViewController(animated: true)
        completion?()
        navController.delegate = previousNavigationDelegate
    }

    func openPhotoViewer(withURLs urls: [URL], quickChatViewModel: QuickChatViewModel) {
        guard let navCtl = viewController.navigationController else { return }

        let photoVM = PhotoViewerViewModel(imageDownloader: ImageDownloader.sharedInstance, urls: urls)
        photoVM.navigator = self
        let photoViewer = PhotoViewerViewController(viewModel: photoVM, quickChatViewModel: quickChatViewModel)
        navCtl.pushViewController(photoViewer, animated: true)
    }

    func closeDeck() {
        closeCoordinator(animated: true, completion: nil)
    }

    func closePhotoViewer() {
        guard let navCtl = viewController.navigationController else { return }
        navCtl.popViewController(animated: true)
    }
}

extension DeckCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            guard let _ = toVC as? PhotoViewerViewController else { return nil }
            return deckViewController.animationController
        case .pop:
            guard let _ = fromVC as? PhotoViewerViewController else { return nil }
            return deckViewController.animationController
        case .none:
            return nil
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        previousNavigationDelegate?.navigationController?(navigationController,
                                                          willShow: viewController,
                                                          animated: true)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        previousNavigationDelegate?.navigationController?(navigationController,
                                                          didShow: viewController,
                                                          animated: true)
    }

}
