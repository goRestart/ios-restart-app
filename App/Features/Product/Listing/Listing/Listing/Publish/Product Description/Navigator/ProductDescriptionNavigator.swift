import Foundation

struct ProductDescriptionNavigator {
  
  private weak var from: UIViewController?
  private let productDescriptionProvider: ProductDescriptionProvider
  
  init(from: UIViewController,
       productDescriptionProvider: ProductDescriptionProvider)
  {
    self.from = from
    self.productDescriptionProvider = productDescriptionProvider
  }
  
  func navigate() {
    let productDescription = productDescriptionProvider.makeProductDescription()
    from?.navigationController?.pushViewController(productDescription, animated: true)
  }
}
