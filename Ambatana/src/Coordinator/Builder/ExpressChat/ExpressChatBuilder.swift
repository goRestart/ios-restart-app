import LGCoreKit

protocol ExpressChatAssembly {
    func buildExpressChat(listings: [Listing],
                          sourceProductId: String,
                          manualOpen: Bool) -> ExpressChatViewController
}

enum ExpressChatBuilder {
    case modal(UIViewController)
}

extension ExpressChatBuilder: ExpressChatAssembly {
    func buildExpressChat(listings: [Listing],
                          sourceProductId: String,
                          manualOpen: Bool) -> ExpressChatViewController {
        let vm = ExpressChatViewModel(listings: listings, sourceProductId: sourceProductId, manualOpen: manualOpen)
        let vc = ExpressChatViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            vm.navigator = ExpressChatWireframe(root: root)
        }
        return vc
    }
}

