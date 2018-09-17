final class ListingFullDetailWireframe: ListingFullDetailNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeDetail() {
        nc.popViewController(animated: true)
    }
}
