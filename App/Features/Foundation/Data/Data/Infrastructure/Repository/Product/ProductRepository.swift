import Domain
import RxSwift

public struct ProductRepository {
  
  private let algoliaDataSource: ProductDataSource
  
  init(algoliaDataSource: ProductDataSource) {
    self.algoliaDataSource = algoliaDataSource
  }
  
  public func getProductExtras() -> Single<[Product.Extra]> {
    return algoliaDataSource.getProductExtras()
  }
}
