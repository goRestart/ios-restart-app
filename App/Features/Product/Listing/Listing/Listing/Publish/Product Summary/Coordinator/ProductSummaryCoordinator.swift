import Foundation

final class ProductSummaryCoordinator {
  
  private weak var productSummary: UIViewController?
  
  init(productSummary: UIViewController) {
    self.productSummary = productSummary
  }
  
  func close() {
    productSummary?.dismiss(animated: true)
  }
}
