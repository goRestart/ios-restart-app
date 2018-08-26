import Core

protocol ProductDescriptionProvider {
  func makeProductDescription() -> UIViewController
}

extension Assembly: ProductDescriptionProvider {
  func makeProductDescription() -> UIViewController {
    let viewController = ProductDescriptionViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(from: viewController)
    return viewController
  }
  
  private var viewBinder: ProductDescriptionViewBinder {
    return ProductDescriptionViewBinder()
  }

  private func viewModel(from viewController: UIViewController) -> ProductDescriptionViewModelType {
    return ProductDescriptionViewModel(
      productPriceNavigator: productPriceNavigator(from: viewController)
    )
  }
}

// MARK: - Navigator

extension Assembly {
  func productDescriptionNavigator(from viewController: UIViewController) -> ProductDescriptionNavigator {
    return ProductDescriptionNavigator(
      from: viewController,
      productDescriptionProvider: self
    )
  }
 }
