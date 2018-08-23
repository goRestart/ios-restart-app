import Foundation
import LGCoreKit
import LGComponents

protocol DeckNavigator: class {
    func openPhotoViewer(listingViewModel: ListingViewModel,
                         source: EventParameterListingVisitSource,
                         quickChatViewModel: QuickChatViewModel)
    func openPhotoViewer(listingViewModel: ListingViewModel,
                         atIndex index: Int,
                         source: EventParameterListingVisitSource,
                         quickChatViewModel: QuickChatViewModel)
    func closeDeck()
    func showOnBoarding()

    func showListingDetail(listing: Listing, visitSource: EventParameterListingVisitSource)
    func closeDetail()
}

typealias DeckWithPhotoViewerNavigator = DeckNavigator & PhotoViewerNavigator

protocol DeckAnimator: class {
    func setupWith(viewModel: ListingDeckViewModel)
    func animatedTransitionings(for operation: UINavigationControllerOperation,
                                from fromVC: UIViewController,
                                to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func handlePhotoViewerEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer)
    var interactiveTransitioner: UIPercentDrivenInteractiveTransition? { get }
}

final class DeckCoordinator: DeckWithPhotoViewerNavigator, ListingDeckOnBoardingNavigator, DeckAnimator {

    fileprivate weak var navigationController: UINavigationController?
    weak var listingDetailNavigator: ListingDetailNavigator?

    var interactiveTransitioner: UIPercentDrivenInteractiveTransition?
    
    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func setupWith(viewModel: ListingDeckViewModel) {
        viewModel.deckNavigator = self
    }

    func showListingDetail(listing: Listing, visitSource: EventParameterListingVisitSource) {
        let vm = ListingDetailViewModel(withListing: listing, visitSource: visitSource)
        vm.navigator = self
        vm.listingViewModel.navigator = listingDetailNavigator
        let vc = ListingDetailViewController(viewModel: vm)

        navigationController?.pushViewController(vc, animated: true)
    }

    func closeDetail() {
        navigationController?.popViewController(animated: true)
    }

    func openPhotoViewer(listingViewModel: ListingViewModel,
                         source: EventParameterListingVisitSource,
                         quickChatViewModel: QuickChatViewModel) {
        let displayable = listingViewModel.makeDisplayable()
        let photoVM = PhotoViewerViewModel(with: displayable, source: source)
        photoVM.navigator = self
        let photoViewer = PhotoViewerViewController(viewModel: photoVM, quickChatViewModel: quickChatViewModel)
        navigationController?.pushViewController(photoViewer, animated: true)
    }

    func openPhotoViewer(listingViewModel: ListingViewModel,
                         atIndex index: Int,
                         source: EventParameterListingVisitSource,
                         quickChatViewModel: QuickChatViewModel) {
        let displayable = listingViewModel.makeDisplayable()
        let photoVM = PhotoViewerViewModel(with: displayable, source: source)
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
