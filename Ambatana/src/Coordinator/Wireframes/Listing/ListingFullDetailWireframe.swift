final class ListingFullDetailWireframe: ListingFullDetailNavigator {
    private weak var nc: UINavigationController?
    private let attributesAssembly: ListingAttributeAssembly

    init(nc: UINavigationController) {
        self.nc = nc
        self.attributesAssembly = ListingAttributeBuilder.modal(nc)
    }

    func openAttributesTable(for items: [ListingAttributeGridItem]) {
        let vc = attributesAssembly.buildListingAttribute(forItems: items)
        nc?.present(vc, animated: true, completion: nil)
    }

    func closeDetail() {
        nc?.popViewController(animated: true)
    }
}
