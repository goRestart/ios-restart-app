final class AffiliationStoreWireframe: AffiliationStoreNavigator {
    private let nc: UINavigationController
    private let vouchersAssembly: AffiliationVouchersAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, vouchersAssembly: AffiliationVouchersBuilder.standard(nc))
    }

    init(nc: UINavigationController, vouchersAssembly: AffiliationVouchersAssembly) {
        self.nc = nc
        self.vouchersAssembly = vouchersAssembly
    }

    func openHistory() {
        let vc = vouchersAssembly.buildAffiliationVouchers()
        nc.pushViewController(vc, animated: true)
    }
}
