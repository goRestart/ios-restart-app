import Foundation

struct ProductPriceNavigator {
  
  private weak var from: UIViewController?
  private let productPriceProvider: ProductPriceProvider
  
  init(from: UIViewController,
       productPriceProvider: ProductPriceProvider)
  {
    self.from = from
    self.productPriceProvider = productPriceProvider
  }
  
  func navigate() {
    let productPrice = productPriceProvider.makeProductPrice()
    from?.navigationController?.pushViewController(productPrice, animated: true)
  }
}
