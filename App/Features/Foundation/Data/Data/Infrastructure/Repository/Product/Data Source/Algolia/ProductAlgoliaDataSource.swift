import RxSwift
import Domain

struct ProductAlgoliaDataSource: ProductDataSource {
  
  private let getProductExtrasAlgoliaAction: GetProductExtrasAlgoliaAction
  
  init(getProductExtrasAlgoliaAction: GetProductExtrasAlgoliaAction) {
    self.getProductExtrasAlgoliaAction = getProductExtrasAlgoliaAction
  }
  
  func getProductExtras() -> Single<[Product.Extra]> {
    return getProductExtrasAlgoliaAction.getAll()
  }
}
