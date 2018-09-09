import Foundation

struct ProductSelectorNavigator {
  
  private weak var from: UIViewController?
  private let productSelectorProvider: ProductSelectorProvider
  
  init(from: UIViewController,
       productSelectorProvider: ProductSelectorProvider)
  {
    self.from = from
    self.productSelectorProvider = productSelectorProvider
  }
  
  func navigate() {
    let productSelector = productSelectorProvider.makeProductSelector()
    from?.navigationController?.pushViewController(productSelector, animated: true)
  }
}
