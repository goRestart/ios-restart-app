import Foundation

protocol MediaViewerAssembly {
    func buildVideoPlayer(atIndex index: Int,
                          listingVM: ListingViewModel,
                          source: EventParameterListingVisitSource) -> UIViewController?
}

enum MediaViewerBuilder {
    case standard(UINavigationController)
    case modal(UIViewController)
}

extension MediaViewerBuilder: MediaViewerAssembly {
    func buildVideoPlayer(atIndex index: Int,
                          listingVM: ListingViewModel,
                          source: EventParameterListingVisitSource) -> UIViewController? {
        guard let displayable = listingVM.makeDisplayable(forMediaAt: index) else { return nil }
        let vm = PhotoViewerViewModel(with: displayable, source: source)
        let chatVM: QuickChatViewModel = QuickChatViewModel()
        chatVM.listingViewModel = listingVM
        let vc = PhotoViewerViewController(viewModel: vm, quickChatViewModel: chatVM)

        switch self {
        case .standard(let nav):
            vm.navigator = MediaViewerStandardWireframe(nc: nav)
            return vc
        case .modal(let root):
            vm.navigator = MediaViewerModalWireframe(root: root)
            return UINavigationController(rootViewController: vc)
        }
    }
}
