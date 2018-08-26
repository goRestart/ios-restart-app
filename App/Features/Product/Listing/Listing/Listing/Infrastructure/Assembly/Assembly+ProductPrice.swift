import Core

protocol ProductPriceProvider {
  func makeProductPrice() -> UIViewController
}

extension Assembly: ProductPriceProvider {
  func makeProductPrice() -> UIViewController {
    let viewController = ProductPriceViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel
    return viewController

  }
  
  private var viewBinder: ProductPriceViewBinder {
    return ProductPriceViewBinder()
  }

  private var viewModel: ProductPriceViewModelType {
    return ProductPriceViewModel()
  }
}

// MARK: - Navigator

extension Assembly {
  func productPriceNavigator(from viewController: UIViewController) -> ProductPriceNavigator {
    return ProductPriceNavigator(
      from: viewController,
      productPriceProvider: self
    )
  }
}
