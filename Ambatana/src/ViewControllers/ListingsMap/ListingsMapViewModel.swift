import CoreLocation
import LGCoreKit
import RxSwift
import RxCocoa
import MapKit
import LGComponents

final class ListingsMapViewModel: BaseViewModel {
    
    typealias ListingWithTags = (listing: Listing?, tags: [String])
    
    private let disposeBag = DisposeBag()
    
    private let tracker: Tracker
    private let navigator: TabNavigator
    private let myUserRepository: MyUserRepository
    private var productFilter : ListingFilters
    private let featureFlags: FeatureFlaggeable
    private let locationManager: LocationManager
    
    let listings: Variable<[Listing]?> = Variable(nil)
    let selectedListingsIndex: Variable<Int?> = Variable(nil)
    let selectedListing: Variable<ListingWithTags> = Variable((nil, []))

    let isLoading = Variable(false)
    let errorMessage = Variable<String?>(nil)
    
    init(navigator: TabNavigator,
         tracker: Tracker,
         myUserRepository: MyUserRepository,
         locationManager: LocationManager,
         currentFilters: ListingFilters,
         featureFlags: FeatureFlaggeable) {
        self.navigator = navigator
        self.tracker = tracker
        self.locationManager = locationManager
        self.productFilter = currentFilters
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
        super.init()
        retrieve(with: currentFilters, firstTimeOpened: true)
        setupRx()
    }
    
    var location: LGLocationCoordinates2D? {
        if let filterLocation = productFilter.place?.location {
            return filterLocation
        } else if let positionCoordinate = locationManager.currentLocation?.coordinate {
            return LGLocationCoordinates2D(coordinates: positionCoordinate)
        }
        return nil
    }
    
    var accuracy: Double {
        return productFilter.selectedCategories.first?.mapAccuracy ?? Constants.nonAccurateRegionRadius
    }
    
    //  MARK: - Private
    
    private func retrieve(with filters: ListingFilters, firstTimeOpened: Bool) {
        isLoading.value = true
        let requester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                            queryString: nil,
                                                                            itemsPerPage: 50,
                                                                            carSearchActive: featureFlags.searchCarsIntoNewBackend.isActive)
        requester.retrieveFirstPage { [weak self] result in
            guard let strongSelf = self else { return }
            if let error = result.listingsResult.error {
                strongSelf.showMap(error: error)
            } else if let newListings = result.listingsResult.value {
                strongSelf.listings.value = newListings
                strongSelf.trackListingMap(isFirstTimeOpened: firstTimeOpened,
                                           returnedResults: EventParameterBoolean(bool: !newListings.isEmpty),
                                           featuredResults: newListings.featuredCount)
            }
            
            strongSelf.isLoading.value = false
        }

    }

    private func resetMap() {
        listings.value = nil
    }
    
    private func showMap(error: RepositoryError) {
        var errorString: String? = nil
            switch error {
            case .network:
                errorString = R.Strings.toastNoNetwork
            case .internalError, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError, .searchAlertError:
                errorString = R.Strings.toastErrorInternal
            case .unauthorized:
                errorString = nil
            }
        errorMessage.value = errorString
    }
    
    private func setupRx() {
        let postingFlowtype = featureFlags.postingFlowType
        selectedListingsIndex
            .asObservable()
            .subscribe(onNext: { [weak self] index in
                guard let index = index,
                    let listing = self?.listings.value?[safeAt: index] else { return }
                let tags = listing.tags(postingFlowType: postingFlowtype) ?? []
                self?.selectedListing.value = (listing: listing, tags: tags)
                self?.trackListingMapDetail(listing)
        }).disposed(by: disposeBag)
    }

    func update(with location: LGLocationCoordinates2D, radius: Int) {
        resetMap()
        var filter = productFilter
        filter.place?.location = location
        filter.distanceRadius = radius
        retrieve(with: filter, firstTimeOpened: false)
    }
    
    func open(_ listingData: ListingDetailData) {
        navigator.openListing(listingData, source: .map, actionOnFirstAppear: .nonexistent)
    }
    
    private func trackListingMapDetail(_ listing: Listing) {
        let isMine = listing.isMine(myUserRepository: myUserRepository)
        tracker.trackEvent(.listingMapOpenPreviewMap(listing,
                                                     source: .map,
                                                     userId: listing.user.objectId ?? "",
                                                     isMine: EventParameterBoolean(bool: isMine)))
    }
    
    private func trackListingMap(isFirstTimeOpened: Bool, returnedResults: EventParameterBoolean, featuredResults: Int) {
        tracker.trackEvent(.listingOpenListingMap(action: isFirstTimeOpened ? .showMap : .redo,
                                                  returnedResults: returnedResults,
                                                  featuredResults: featuredResults,
                                                  filters: productFilter))
    }
    
}
