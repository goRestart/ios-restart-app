final class ListingFullDetailWireframe: ListingFullDetailNavigator {
    private weak var nc: UINavigationController?

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeDetail() {
        nc?.popViewController(animated: true)
    }
}
