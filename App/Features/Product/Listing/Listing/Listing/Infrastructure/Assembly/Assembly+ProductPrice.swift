import Core

protocol ProductPriceProvider {
  func makeProductPrice() -> UIViewController
}

extension Assembly: ProductPriceProvider {
  func makeProductPrice() -> UIViewController {
    let viewController = ProductPriceViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(from: viewController)
    return viewController

  }
  
  private var viewBinder: ProductPriceViewBinder {
    return ProductPriceViewBinder()
  }

  private func viewModel(from viewController: UIViewController) -> ProductPriceViewModelType {
    return ProductPriceViewModel(
      productExtrasNavigator: productExtrasNavigator(from: viewController)
    )
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
