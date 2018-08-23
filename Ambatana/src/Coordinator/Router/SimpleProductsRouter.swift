import Foundation

final class SimpleProductsRouter: SimpleProductsNavigator {
    private weak var navigationController: UINavigationController?
    private weak var detailNavigator: ListingDetailNavigator?

    init(navigationController: UINavigationController, detailNavigator: ListingDetailNavigator?) {
        self.navigationController = navigationController
        self.detailNavigator = detailNavigator
    }

    func closeSimpleProducts() {
        navigationController?.popViewController(animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        guard let navCtl = navigationController else { return }
        let userCoordinator = UserCoordinator(navigationController: navCtl)
        let listingCoordinator = ListingCoordinator(navigationController: navCtl, userCoordinator: userCoordinator)
        userCoordinator.listingCoordinator = listingCoordinator

        listingCoordinator.listingDetailNavigator = detailNavigator
        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
}
