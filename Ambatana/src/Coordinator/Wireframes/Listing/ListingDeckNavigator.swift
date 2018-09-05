import LGCoreKit

protocol ListingDeckNavigator: class {
    func openFeaturedInfo()
    func openOnboarding()
    func openListingDetail(_ listing: Listing, source: EventParameterListingVisitSource)
    func close()
}

final class ListingDeckWireframe: ListingDeckNavigator {
    private let nc: UINavigationController
    private let listingAssembly: ListingAssembly
    private let featuredAssembly: FeaturedInfoAssembly
    private let onboardingAssembly: DeckOnboardingAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  featuredAssembly: FeaturedInfoBuilder.modal(nc),
                  onboardingAssembly: DeckOnboardingBuilder.modal(nc),
                  listingAssembly: ListingBuilder.standard(nc))
    }

    init(nc: UINavigationController,
         featuredAssembly: FeaturedInfoAssembly,
         onboardingAssembly: DeckOnboardingAssembly,
         listingAssembly: ListingAssembly) {
        self.nc = nc
        self.featuredAssembly = featuredAssembly
        self.onboardingAssembly = onboardingAssembly
        self.listingAssembly = listingAssembly
    }

    func openFeaturedInfo() {
        let vc = featuredAssembly.buildFeaturedInfo()
        nc.present(vc, animated: true, completion: nil)
    }

    func openOnboarding() {
        let vc = onboardingAssembly.buildDeckOnboarding()
        vc.modalPresentationStyle = .custom
        nc.present(vc, animated: true)
    }

    func openListingDetail(_ listing: Listing, source: EventParameterListingVisitSource) {
        let vc = listingAssembly.buildListingDetail(for: listing, source: source)
        nc.pushViewController(vc, animated: true)
    }

    func close() {
        nc.popViewController(animated: true)
    }
}
