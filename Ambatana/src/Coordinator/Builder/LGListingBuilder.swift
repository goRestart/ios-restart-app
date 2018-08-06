import Foundation
import LGCoreKit

protocol ListingBuilder {
    func buildEditView(listing: Listing,
                       pageType: EventParameterTypePage?,
                       bumpUpProductData: BumpUpProductData?,
                       listingCanBeBoosted: Bool,
                       timeSinceLastBump: TimeInterval?,
                       maxCountdown: TimeInterval,
                       onEditAction: OnEditAction?) -> EditListingViewController
    func buildVideoPlayer(into navCtl: UINavigationController,
                          atIndex index: Int,
                          listingVM: ListingViewModel,
                          source: EventParameterListingVisitSource) -> PhotoViewerViewController?
}

enum LGListingBuilder {
    case standard(navigationController: UINavigationController)
}

extension LGListingBuilder: ListingBuilder {
    func buildEditView(listing: Listing,
                       pageType: EventParameterTypePage?,
                       bumpUpProductData: BumpUpProductData?,
                       listingCanBeBoosted: Bool,
                       timeSinceLastBump: TimeInterval?,
                       maxCountdown: TimeInterval,
                       onEditAction: OnEditAction?) -> EditListingViewController {
        switch self {
        case .standard(let nav):
            let vm = EditListingViewModel(listing: listing,
                                          pageType: pageType,
                                          bumpUpProductData: bumpUpProductData,
                                          listingCanBeBoosted: listingCanBeBoosted,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
            vm.navigator = EditListingRouter(navigationController: nav, onEditAction: onEditAction)
            let vc = EditListingViewController(viewModel: vm)
            return vc
        }
    }
    func buildVideoPlayer(into navCtl: UINavigationController,
                          atIndex index: Int,
                          listingVM: ListingViewModel,
                          source: EventParameterListingVisitSource) -> PhotoViewerViewController? {
        switch self {
        case .standard(let nav):
            guard let displayable = listingVM.makeDisplayable(forMediaAt: index) else { return nil }

            let vm = PhotoViewerViewModel(with: displayable, source: source)
            vm.navigator = PhotoViewerRouter(root: nav)

            let chatVM: QuickChatViewModel = QuickChatViewModel()
            chatVM.listingViewModel = listingVM

            let vc = PhotoViewerViewController(viewModel: vm, quickChatViewModel: chatVM)
            navCtl.viewControllers = [vc]
            return vc
        }
    }
}




