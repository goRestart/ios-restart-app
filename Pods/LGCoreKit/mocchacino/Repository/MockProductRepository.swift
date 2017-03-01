import Result
import RxSwift

open class MockProductRepository: ProductRepository {
    public var eventsPublishSubject: PublishSubject<ProductEvent>
    
    public var indexResult: ProductsResult
    public var productResult: ProductResult
    public var markAsSoldVoidResult: ProductVoidResult
    public var userProductRelationResult: ProductUserRelationResult
    public var statsResult: ProductStatsResult
    public var incrementViewsResult: ProductVoidResult
    public var productBuyersResult: ProductBuyersResult

    public var markAsSoldProductId: String?
    public var markAsSoldBuyerId: String?
    

    // MARK: - Lifecycle

    public init() {
        self.eventsPublishSubject = PublishSubject<ProductEvent>()
        self.indexResult = ProductsResult(value: MockProduct.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        self.productResult = ProductResult(value: MockProduct.makeMock())
        self.markAsSoldVoidResult = ProductVoidResult(value: Void())
        self.userProductRelationResult = ProductUserRelationResult(value: MockUserProductRelation.makeMock())
        self.statsResult = ProductStatsResult(value: MockProductStats.makeMock())
        self.incrementViewsResult = ProductVoidResult(value: Void())
        self.productBuyersResult = ProductBuyersResult(value: MockUserProduct.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }


    // MARK: - ProductRepository

    public var events: Observable<ProductEvent> {
        return eventsPublishSubject.asObservable()
    }

    public func updateEventsFor(productId: String) -> Observable<Product> {
        return events.filter { $0.product?.objectId == productId }.map { $0.product! }
    }

    public func buildNewProduct(_ name: String?,
                                description: String?,
                                price: ProductPrice,
                                category: ProductCategory) -> Product? {
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
                              price: ProductPrice,
                              currency: Currency,
                              location: LGLocationCoordinates2D?,
                              postalAddress: PostalAddress?,
                              category: ProductCategory) -> Product {
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

    public func index(_ params: RetrieveProductsParams,
                      completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func index(userId: String,
                      params: RetrieveProductsParams,
                      completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexRelated(productId: String,
                             params: RetrieveProductsParams,
                             completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexDiscover(productId: String,
                              params: RetrieveProductsParams,
                              completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexFavorites(_ userId: String,
                               completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func retrieve(_ productId: String,
                         completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func create(_ product: Product,
                       images: [UIImage],
                       progress: ((Float) -> Void)?,
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func create(_ product: Product,
                       images: [File],
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func update(_ product: Product,
                       images: [UIImage],
                       progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)

    }

    public func update(_ product: Product,
                       oldImages: [File],
                       newImages: [UIImage],
                       progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func update(_ product: Product,
                       images: [File],
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func delete(_ product: Product,
                       completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func markProductAsSold(_ productId: String,
                                  buyerId: String?,
                                  completion: ProductVoidCompletion?) {
        markAsSoldProductId = productId
        markAsSoldBuyerId = buyerId
        delay(result: markAsSoldVoidResult, completion: completion)
    }

    public func markProductAsSold(_ product: Product,
                                  buyerId: String?,
                                  completion: ProductCompletion?) {
        markAsSoldProductId = product.objectId
        markAsSoldBuyerId = buyerId
        delay(result: productResult, completion: completion)
    }

    public func markProductAsUnsold(_ product: Product,
                                    completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func saveFavorite(_ product: Product,
                             completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func deleteFavorite(_ product: Product,
                               completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func updateFavoritesInfo(_ products: [Product]) -> [Product] {
        return products
    }

    public func retrieveUserProductRelation(_ productId: String,
                                            completion: ProductUserRelationCompletion?) {
        delay(result: userProductRelationResult, completion: completion)
    }

    public func saveReport(_ product: Product,
                           completion: ProductCompletion?) {
        delay(result: productResult, completion: completion)
    }

    public func indexLimbo(_ completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func indexTrending(_ params: IndexTrendingProductsParams,
                              completion: ProductsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func retrieveStats(_ product: Product,
                              completion: ProductStatsCompletion?) {
        delay(result: statsResult, completion: completion)
    }

    public func incrementViews(_ product: Product,
                               completion: ProductVoidCompletion?) {
        delay(result: incrementViewsResult, completion: completion)
    }

    public func updateProductViewCounts() {
    }

    public func possibleBuyersOf(productId: String,
                                 completion: ProductBuyersCompletion?) {
        delay(result: productBuyersResult, completion: completion)
    }
}
