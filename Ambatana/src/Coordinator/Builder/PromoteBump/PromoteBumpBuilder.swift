protocol PromoteBumpAssembly {
    func buildPromoteBump(listingId: String,
                          bumpUpProductData: BumpUpProductData,
                          maxCountdown: TimeInterval,
                          typePage: EventParameterTypePage?,
                          sellAction: SellAction?) -> UIViewController
}

enum PromoteBumpBuilder {
    case modal(UIViewController)
}

extension PromoteBumpBuilder: PromoteBumpAssembly {
    func buildPromoteBump(listingId: String,
                          bumpUpProductData: BumpUpProductData,
                          maxCountdown: TimeInterval,
                          typePage: EventParameterTypePage?,
                          sellAction action: SellAction?) -> UIViewController {
        let vm = PromoteBumpViewModel(listingId: listingId,
                                      bumpUpProductData: bumpUpProductData,
                                      maxCountdown: maxCountdown,
                                      typePage: typePage)
        let vc = PromoteBumpViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            vm.navigator = PromoteBumpModalWireframe(root: root, sellAction: action)
        }
        return vc
    }
}
