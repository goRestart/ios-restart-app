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

final class DeckCoordinator: NSObject, Coordinator, DeckNavigator, ListingDeckOnBoardingNavigator {

    var child: Coordinator?
    let viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    fileprivate weak var previousNavigationDelegate: UINavigationControllerDelegate?
    fileprivate let deckViewController: ListingDeckViewController

    fileprivate var interactiveTransitioner: UIPercentDrivenInteractiveTransition?
    fileprivate var navigationController: UINavigationController? { return deckViewController.navigationController }

    fileprivate var shouldShowDeckOnBoarding: Bool { return !keyValueStorage[.didShowDeckOnBoarding] }
    fileprivate let keyValueStorage: KeyValueStorageable

    convenience init(listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     listingNavigator: ListingDetailNavigator) {
        self.init(listing: listing,
                  listingListRequester: listingListRequester,
                  source: source,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  listingNavigator: listingNavigator,
                  keyValueStorage: KeyValueStorage.sharedInstance)
    }

    private init(listing: Listing,
                 listingListRequester: ListingListRequester,
                 source: EventParameterListingVisitSource,
                 bubbleNotificationManager: BubbleNotificationManager,
                 sessionManager: SessionManager,
                 listingNavigator: ListingDetailNavigator,
                 keyValueStorage: KeyValueStorageable) {

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
        self.keyValueStorage = keyValueStorage
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
        guard let navController = navigationController else { return }

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

    private func openDeckOnBoarding() {
        let viewModel = ListingDeckOnBoardingViewModel()
        viewModel.navigator = self
        let onboarding = ListingDeckOnBoardingViewController(viewModel: viewModel, animator: OnBoardingAnimator())
        onboarding.modalPresentationStyle = .custom

        navigationController?.present(onboarding, animated: true, completion: nil)
        didOpenDeckOnBoarding()
    }

    func closeDeck() {
        if shouldShowDeckOnBoarding {
            openDeckOnBoarding()
        } else {
            closeCoordinator(animated: true, completion: nil)
        }
    }

    private func didOpenDeckOnBoarding() {
        keyValueStorage[.didShowDeckOnBoarding] = true
    }

    func closePhotoViewer() {
        guard let navCtl = viewController.navigationController else { return }
        navCtl.popViewController(animated: true)
    }

    func closeDeckOnboarding() {
        navigationController?.dismiss(animated: true, completion: nil)
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
        if let photoViewer = viewController as? PhotoViewerViewController {
            let leftGesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                               action: #selector(handleEdgeGesture))
            leftGesture.edges = .left
            let topGesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                               action: #selector(handleEdgeGesture))
            topGesture.edges = .top
            photoViewer.addEdgeGesture([leftGesture, topGesture])
        }

        previousNavigationDelegate?.navigationController?(navigationController,
                                                          didShow: viewController,
                                                          animated: true)
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animationController as? PhotoViewerTransitionAnimator, animator.isInteractive else { return nil }
        return interactiveTransitioner
    }

    @objc fileprivate func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if interactiveTransitioner == nil {
            interactiveTransitioner = UIPercentDrivenInteractiveTransition()
        }


        guard let view = navigationController?.view else { return }
        let translation = gesture.translation(in: view)

        let progress: CGFloat
        if gesture.edges.contains(.top) {
            guard view.height > 0 else { return }
            progress = min(1.0, (translation.y / view.height))
        } else {
            guard view.width > 0 else { return }
            progress = min(1.0, (translation.x / view.width))
        }

        switch gesture.state {
        case .began:
            navigationController?.popViewController(animated: true)
        case .changed:
            interactiveTransitioner?.update(progress)
        case .cancelled:
            fallthrough
        case .ended:
            progress > 0.5 ? interactiveTransitioner?.finish() : interactiveTransitioner?.cancel()
            interactiveTransitioner = nil
        default:
            break
            // do nothing, know nothing
        }
    }

}
