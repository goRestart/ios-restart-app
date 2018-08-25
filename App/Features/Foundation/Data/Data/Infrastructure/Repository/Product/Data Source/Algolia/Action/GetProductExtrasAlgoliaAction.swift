import Domain
import RxSwift
import InstantSearchClient

struct GetProductExtrasAlgoliaAction {
  
  private let productExtrasIndex: InstantSearchClient.Index
  private let productExtraMapper: ProductExtraMapper
  
  init(productExtrasIndex: InstantSearchClient.Index,
       productExtraMapper: ProductExtraMapper)
  {
    self.productExtrasIndex = productExtrasIndex
    self.productExtraMapper = productExtraMapper
  }
  
  func getAll() -> Single<[Product.Extra]> {
    return productExtrasIndex.rx
      .getAll()
      .map(
        productExtraMapper.map
    )
  }
}
