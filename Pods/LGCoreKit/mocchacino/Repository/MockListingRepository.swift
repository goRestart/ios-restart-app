import Result
import RxSwift

open class MockListingRepository: ListingRepository {

    public var eventsPublishSubject = PublishSubject<ListingEvent>()
    
    public var indexResult: ListingsResult!
    public var listingResult: ListingResult!
    public var listingVoidResult: ListingVoidResult!
    public var carResult: CarResult!
    public var productResult: ProductResult!
    public var deleteProductResult: ListingVoidResult!
    public var markAsSoldResult: ListingResult!
    public var markAsUnsoldResult: ListingResult!
    public var markAsSoldVoidResult: ListingVoidResult!
    public var markAsUnsoldVoidResult: ListingVoidResult!
    public var userProductRelationResult: ListingUserRelationResult!
    public var statsResult: ListingStatsResult!
    public var incrementViewsResult: ListingVoidResult!
    public var listingBuyersResult: ListingBuyersResult!

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
                           user: product.user,
                           updatedAt: product.updatedAt,
                           createdAt: product.createdAt,
                           featured: product.featured,
                           favorite: product.favorite)
    }

    public func index(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public  func index(userId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexRelated(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexDiscover(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexFavorites(_ userId: String, completion: ListingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func retrieve(_ listingId: String, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }

    public func create(productParams: ProductCreationParams, completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }
    
    public func create(carParams: CarCreationParams, completion: CarCompletion?) {
        delay(result: carResult, completion: completion)
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

    public func update(productParams: ProductEditionParams, completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }
    
    public func update(carParams: CarEditionParams, completion: CarCompletion?) {
        delay(result: carResult, completion: completion)
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
        delay(result: deleteProductResult, completion: completion)
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
    
    public func saveFavorite(listing: Listing, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
    }
    
    public func deleteFavorite(listing: Listing, completion: ListingCompletion?) {
        delay(result: listingResult, completion: completion)
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

    public func incrementViews(listingId: String, visitSource: String, completion: ListingVoidCompletion?) {
        delay(result: incrementViewsResult, completion: completion)
    }

    public func updateListingViewCounts() {
    }

    public func possibleBuyersOf(listingId: String, completion: ListingBuyersCompletion?) {
        delay(result: listingBuyersResult, completion: completion)
    }
}
