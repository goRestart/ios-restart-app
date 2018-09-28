protocol AffiliationModalAssembly {
    func buildAffiliationModalView(with data: AffiliationModalData) -> UIViewController
}

enum AffiliationModalBuilder {
    case modal
}

extension AffiliationModalBuilder: AffiliationModalAssembly {
    func buildAffiliationModalView(with data: AffiliationModalData) -> UIViewController {
        let vm = AffiliationModalViewModel(data: data)
        let vc = AffiliationModalViewController(viewModel: vm)
        return vc
    }
}
