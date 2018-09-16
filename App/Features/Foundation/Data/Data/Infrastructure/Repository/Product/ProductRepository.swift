import Domain
import RxSwift

public struct ProductRepository {
  
  private let algoliaDataSource: ProductExtrasDataSource
  private let apiDataSource: ProductDataSource
  
  init(algoliaDataSource: ProductExtrasDataSource,
       apiDataSource: ProductDataSource)
  {
    self.algoliaDataSource = algoliaDataSource
    self.apiDataSource = apiDataSource
  }
  
  public func getProductExtras() -> Single<[Product.Extra]> {
    return algoliaDataSource.getProductExtras()
  }
  
  public func publish(with request: PublishProductRequest) -> Completable {
    return apiDataSource.publish(with: request)
  }
}
