protocol AffiliationStoreAssembly {
    func buildAffiliationStore() -> UIViewController
}

enum AffiliationStoreBuilder {
    case standard(UINavigationController)
}

extension AffiliationStoreBuilder: AffiliationStoreAssembly {
    func buildAffiliationStore() -> UIViewController {
        let vm = AffiliationStoreViewModel()
        let vc = AffiliationStoreViewController(viewModel: vm)
        switch self {
        case .standard(let nc):
            vm.navigator = AffiliationStoreWireframe(nc: nc)
            return vc
        }
    }
}
