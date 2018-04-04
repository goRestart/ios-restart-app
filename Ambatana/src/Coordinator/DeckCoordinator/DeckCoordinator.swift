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
    func openPhotoViewer(listingViewModel: ListingViewModel,
                         source: EventParameterListingVisitSource,
                         quickChatViewModel: QuickChatViewModel)
    func closePhotoViewer()
    func closeDeck()
    func showOnBoarding()
}

protocol DeckAnimator: class {
    func showDeckViewController(listing: Listing,
                                cellModels: [ListingCellModel],
                                listingListRequester: ListingListRequester,
                                source: EventParameterListingVisitSource,
                                listingNavigator: ListingDetailNavigator,
                                actionOnFirstAppear: DeckActionOnFirstAppear,
                                trackingIndex: Int?)
    func animatedTransitionings(for operation: UINavigationControllerOperation,
                                from fromVC: UIViewController,
                                to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func handlePhotoViewerEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer)
    var interactiveTransitioner: UIPercentDrivenInteractiveTransition? { get }
}

final class DeckCoordinator: DeckNavigator, ListingDeckOnBoardingNavigator, DeckAnimator {

    fileprivate weak var navigationController: UINavigationController?
    var interactiveTransitioner: UIPercentDrivenInteractiveTransition?
    
    private init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showDeckViewController(listing: Listing,
                                cellModels: [ListingCellModel],
                                listingListRequester: ListingListRequester,
                                source: EventParameterListingVisitSource,
                                listingNavigator: ListingDetailNavigator,
                                actionOnFirstAppear: DeckActionOnFirstAppear,
                                trackingIndex: Int?) {
        let viewModel = ListingDeckViewModel(listModels: cellModels,
                                             listing: listing,
                                             listingListRequester: listingListRequester,
                                             source: source,
                                             detailNavigator: listingNavigator,
                                             actionOnFirstAppear: actionOnFirstAppear,
                                             trackingIndex: trackingIndex)
        let deckViewController = ListingDeckViewController(viewModel: viewModel)
        viewModel.delegate = deckViewController
        viewModel.navigator = listingNavigator
        viewModel.deckNavigator = self

        navigationController?.pushViewController(deckViewController, animated: true)
    }

    func openPhotoViewer(listingViewModel: ListingViewModel,
                         source: EventParameterListingVisitSource,
                         quickChatViewModel: QuickChatViewModel) {
        let photoVM = PhotoViewerViewModel(with: listingViewModel, source: source)
        photoVM.navigator = self
        let photoViewer = PhotoViewerViewController(viewModel: photoVM, quickChatViewModel: quickChatViewModel)
        navigationController?.pushViewController(photoViewer, animated: true)
    }

    private func openDeckOnBoarding() {
        let viewModel = ListingDeckOnBoardingViewModel()
        viewModel.navigator = self
        let onboarding = ListingDeckOnBoardingViewController(viewModel: viewModel, animator: OnBoardingAnimator())
        onboarding.modalPresentationStyle = .custom
        navigationController?.present(onboarding, animated: true)
    }

    func closeDeck() {
        navigationController?.popViewController(animated: true)
    }

    func showOnBoarding() {
        openDeckOnBoarding()
    }

    func closePhotoViewer() {
        navigationController?.popViewController(animated: true)
    }

    func closeDeckOnboarding() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func animatedTransitionings(for operation: UINavigationControllerOperation,
                                from fromVC: UIViewController,
                                to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = toVC as? PhotoViewerViewController,
            let deckViewController = fromVC as? ListingDeckViewController {
            return deckViewController.animationController
        } else if let _ = fromVC as? PhotoViewerViewController,
            let deckViewController = toVC as? ListingDeckViewController {
            return deckViewController.animationController
        } else {
            return nil
        }
    }

    @objc func handlePhotoViewerEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let view = navigationController?.topViewController?.view else { return }
        if interactiveTransitioner == nil {
            interactiveTransitioner = UIPercentDrivenInteractiveTransition()
        }
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
            if progress < 0.7 {
                interactiveTransitioner?.update(progress)
            }
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
