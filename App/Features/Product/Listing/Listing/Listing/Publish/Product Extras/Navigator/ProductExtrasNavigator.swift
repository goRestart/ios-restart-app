import Foundation

struct ProductExtrasNavigator: ProductExtrasNavigable {
  
  private weak var from: UIViewController?
  private let productExtrasProvider: ProductExtrasProvider
  
  init(from: UIViewController,
       productExtrasProvider: ProductExtrasProvider)
  {
    self.from = from
    self.productExtrasProvider = productExtrasProvider
  }
  
  func navigate() {
    let productExtras = productExtrasProvider.makeProductExtras()
    from?.navigationController?.pushViewController(productExtras, animated: true)
  }
}
