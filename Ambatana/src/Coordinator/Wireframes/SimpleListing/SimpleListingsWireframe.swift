import Foundation

final class SimpleListingsWireframe: SimpleProductsNavigator {
    private let nc: UINavigationController
    private let listingRouter: ListingWireframe

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, listingRouter: ListingWireframe(nc: nc))
    }

    init(nc: UINavigationController, listingRouter: ListingWireframe) {
        self.nc = nc
        self.listingRouter = listingRouter
    }

    func closeSimpleProducts() {
        nc.popViewController(animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingRouter.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
}
