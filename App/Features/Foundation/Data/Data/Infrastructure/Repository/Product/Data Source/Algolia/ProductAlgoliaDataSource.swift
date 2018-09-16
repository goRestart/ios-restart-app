import RxSwift
import Domain

struct ProductAlgoliaDataSource: ProductExtrasDataSource {
  
  private let getProductExtrasAlgoliaAction: GetProductExtrasAlgoliaAction
  
  init(getProductExtrasAlgoliaAction: GetProductExtrasAlgoliaAction) {
    self.getProductExtrasAlgoliaAction = getProductExtrasAlgoliaAction
  }
  
  func getProductExtras() -> Single<[Product.Extra]> {
    return getProductExtrasAlgoliaAction.getAll()
  }
}
