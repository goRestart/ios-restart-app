import Foundation

struct ProductSummaryNavigator {
  
  private weak var from: UIViewController?
  private let productSummaryProvider: ProductSummaryProvider
  
  init(from: UIViewController,
       productSummaryProvider: ProductSummaryProvider)
  {
    self.from = from
    self.productSummaryProvider = productSummaryProvider
  }
  
  func navigate() {
    let productSummary = productSummaryProvider.makeProductSummary()
    from?.navigationController?.pushViewController(productSummary, animated: true)
  }
}
