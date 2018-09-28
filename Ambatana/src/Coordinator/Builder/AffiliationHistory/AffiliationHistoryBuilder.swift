import LGComponents

protocol AffiliationVouchersAssembly {
    func buildAffiliationVouchers() -> AffiliationVouchersViewController
}

enum AffiliationVouchersBuilder: AffiliationVouchersAssembly {
    case standard(UINavigationController)

    func buildAffiliationVouchers() -> AffiliationVouchersViewController {
        switch self {
        case .standard(_):
            let vm = AffiliationVouchersViewModel()
            return AffiliationVouchersViewController(viewModel: vm)
        }
    }
}
