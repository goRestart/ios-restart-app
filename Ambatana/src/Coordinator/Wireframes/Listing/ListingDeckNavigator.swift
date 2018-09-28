import LGCoreKit

protocol ListingDeckNavigator: class {
    func openFeaturedInfo()
    func openOnboarding()
    func openListingDetail(withVM listingViewModel: ListingViewModel, source: EventParameterListingVisitSource)
    func close()
}

final class ListingDeckWireframe: ListingDeckNavigator {
    private weak var nc: UINavigationController?
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
        nc?.present(vc, animated: true, completion: nil)
    }

    func openOnboarding() {
        let vc = onboardingAssembly.buildDeckOnboarding()
        vc.modalPresentationStyle = .custom
        nc?.present(vc, animated: true)
    }

    func openListingDetail(withVM listingViewModel: ListingViewModel, source: EventParameterListingVisitSource) {
        let vc = listingAssembly.buildListingDetail(withVM: listingViewModel, source: source)
        nc?.pushViewController(vc, animated: true)
    }

    func close() {
        nc?.popViewController(animated: true)
    }
}
