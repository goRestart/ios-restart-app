import Core

protocol ProductSummaryProvider {
  func makeProductSummary() -> UIViewController
}

extension Assembly: ProductSummaryProvider {
  func makeProductSummary() -> UIViewController {
    let viewController = ProductSummaryViewController()
    return viewController
  }
}

// MARK: - Navigator

extension Assembly {
  func productSummaryNavigator(from: UIViewController) -> ProductSummaryNavigator {
    return ProductSummaryNavigator(
      from: from,
      productSummaryProvider: self
    )
  }
}
