final class AffiliationStoreWireframe: AffiliationStoreNavigator {
    private let nc: UINavigationController
    private let editEmailAssembly: EditEmailAssembly
    private let vouchersAssembly: AffiliationVouchersAssembly
    
    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  vouchersAssembly: AffiliationVouchersBuilder.standard(nc),
                  editEmailAssembly: EditEmailBuilder.standard(nc))
    }
    
    init(nc: UINavigationController,
         vouchersAssembly: AffiliationVouchersAssembly,
         editEmailAssembly: EditEmailAssembly) {
        self.nc = nc
        self.vouchersAssembly = vouchersAssembly
        self.editEmailAssembly = editEmailAssembly
    }

    func closeAffiliationStore() {
        nc.popViewController(animated: true)
    }

    func openHistory() {
        let vc = vouchersAssembly.buildAffiliationVouchers()
        nc.pushViewController(vc, animated: true)
    }
    
    func openEditEmail() {
        let vc = editEmailAssembly.buildEditEmail()
        nc.pushViewController(vc, animated: true)
    }
}
