protocol ListingAttributeAssembly {
    func buildListingAttribute(forItems items: [ListingAttributeGridItem]) -> UIViewController
}

enum ListingAttributeBuilder {
    case modal(UINavigationController)
}

extension ListingAttributeBuilder: ListingAttributeAssembly {
    func buildListingAttribute(forItems items: [ListingAttributeGridItem]) -> UIViewController {
        let vm = ListingAttributeTableViewModel(withItems: items)
        let vc = ListingAttributeTableViewController(withViewModel: vm)

        switch self {
        case .modal(let nc):
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = ListingDetailWireframe(nc: nc)

            return nc
        }
    }
}
