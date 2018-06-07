import Result
import RxSwift

open class MockListingRepository: ListingRepository {
    
    public var eventsPublishSubject = PublishSubject<ListingEvent>()
    
    public var indexResult: ListingsResult!
    public var listingResult: ListingResult!
    public var listingVoidResult: ListingVoidResult!
    public var carResult: CarResult!
    public var productResult: ProductResult!
    public var deleteListingResult: ListingVoidResult!
    public var markAsSoldResult: ListingResult!
    public var markAsUnsoldResult: ListingResult!
    public var markAsSoldVoidResult: ListingVoidResult!
    public var markAsUnsoldVoidResult: ListingVoidResult!
    public var userProductRelationResult: ListingUserRelationResult!
    public var statsResult: ListingStatsResult!
    public var incrementViewsResult: ListingVoidResult!
    public var listingBuyersResult: ListingBuyersResult!
    public var listingResultTransation: ListingResult!
    public var transactionResult: ListingTransactionResult!
    public var transactionsResult: ListingTransactionsResult!

    public var markAsSoldProductId: String?
    

    // MARK: - Lifecycle

    public required init() { }


    // MARK: - ListingRepository

    public var events: Observable<ListingEvent> {
        return eventsPublishSubject.asObservable()
    }

    public func updateEvents(for listingId: String) -> Observable<Listing> {
        return events.filter { $0.product?.objectId == listingId || $0.car?.objectId == listingId }.map { $0.listing! }
    }

    public func buildNewProduct(_ name: String?,
                                description: String?,
                                price: ListingPrice,
                                category: ListingCategory) -> Product? {
        var product = MockProduct.makeMock()
        product.name = name
        product.descr = description
        product.price = price
        product.category = category
        return product
    }

    public func updateProduct(_ product: Product,
                              name: String?,
                              description: String?,
                              price: ListingPrice,
                              currency: Currency,
                              location: LGLocationCoordinates2D?,
                              postalAddress: PostalAddress?,
                              category: ListingCategory) -> Product {
        return MockProduct(objectId: product.objectId,
                           name: name,
                           nameAuto: product.nameAuto,
                           descr: description,
                           price: price,
                           currency: currency,
                           location: location ?? LGLocationCoordinates2D.makeMock(),
                           postalAddress: postalAddress ?? PostalAddress.makeMock(),
                           languageCode: product.languageCode,
                           category: category,
                           status: product.status,
                           thumbnail: product.thumbnail,
                           thumbnailSize: product.thumbnailSize,
                           images: product.images,
                           media: product.media,
                           mediaThumbnail: product.mediaThumbnail,
                           user: product.user,
                           updatedAt: product.updatedAt,
                           createdAt: product.createdAt,
                           featured: product.featured)
    }
    
    public func index(_ params: RetrieveListingParams, relax: RelaxParam, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func index(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func indexSimilar(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func indexCustomFeed(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public  func index(userId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexRelated(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func indexRelatedRealEstate(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexDiscover(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func indexRealEstate(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func indexRealEstateRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexFavorites(userId: String, numberOfResults: Int?, resultsOffset: Int?, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func retrieve(_ listingId: String, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func retrieveRealEstate(_ listingId: String, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }

    public func create(listingParams: ListingCreationParams, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func createCar(listingParams: ListingCreationParams, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func createServices(listingParams: [ListingCreationParams], completion: ListingsCompletion?) {
        
    }

    public func create(product: Product,
                       images: [UIImage],
                       progress: ((Float) -> Void)?,
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }
    
    public func create(product: Product,
                       images: [File],
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func update(listingParams: ListingEditionParams, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func updateCar(listingParams: ListingEditionParams, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func updateService(listingParams: ListingEditionParams, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func update(product: Product,
                       images: [UIImage],
                       progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
        
    }
    
    public func update(product: Product,
                       oldImages: [File],
                       newImages: [UIImage],
                       progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }
    
    public func update(product: Product,
                       images: [File],
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }
    
    public func delete(listingId: String,
                       completion: ListingVoidCompletion?) {
        delay(result: deleteListingResult, completion: completion)
    }
    
    public func markAsSold(listing: Listing, completion: ListingCompletion?) {
        markAsSoldProductId = listing.objectId!
        delay(result: markAsSoldResult, completion: completion)
    }

    public func markAsUnsold(listing: Listing, completion: ListingCompletion?) {
        delay(result: markAsUnsoldResult, completion: completion)
    }
    
    public func markAsSold(listingId: String, completion: ListingVoidCompletion?) {
        markAsSoldProductId = listingId
        delay(result: markAsSoldVoidResult, completion: completion)
    }
    
    public func markAsUnsold(listingId: String, completion: ListingVoidCompletion?) {
        delay(result: markAsUnsoldVoidResult, completion: completion)
    }
    
    public func saveFavorite(listing: Listing, completion: ListingVoidCompletion?) {
        delay(result: listingVoidResult, completion: completion)
    }
    
    public func deleteFavorite(listing: Listing, completion: ListingVoidCompletion?) {
        delay(result: listingVoidResult, completion: completion)
    }

    public func retrieveUserListingRelation(_ listingId: String, completion: ListingUserRelationCompletion?) {
        delay(result: userProductRelationResult, completion: completion)
    }

    public func saveReport(_ listingId: String, completion: ListingVoidCompletion?) {
        delay(result: listingVoidResult, completion: completion)
    }

    public func indexLimbo(_ completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexTrending(_ params: IndexTrendingListingsParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func retrieveStats(listingId: String, completion: ListingStatsCompletion?) {
        delay(result: statsResult, completion: completion)
    }

    public func incrementViews(listingId: String, visitSource: String, visitTimestamp: Double, completion: ListingVoidCompletion?) {
        delay(result: incrementViewsResult, completion: completion)
    }

    public func updateListingViewCounts() {
    }

    public func possibleBuyersOf(listingId: String, completion: ListingBuyersCompletion?) {
        delay(result: listingBuyersResult, completion: completion)
    }
    
    public func createTransactionOf(createTransactionParams: CreateTransactionParams, completion: ListingTransactionCompletion?) {
        delay(result: transactionResult, completion: completion)
    }
    
    public func retrieveTransactionsOf(listingId: String, completion: ListingTransactionsCompletion?) {
        delay(result: transactionsResult, completion: completion)
    }
    public func indexCars(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    public func indexCarsRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    public func indexRelatedCars(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func indexServices(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    public func indexServicesRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    public func indexRelatedServices(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }
}
