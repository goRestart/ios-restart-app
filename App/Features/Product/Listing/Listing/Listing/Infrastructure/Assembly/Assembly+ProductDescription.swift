import Core

protocol ProductDescriptionProvider {
  func makeProductDescription() -> UIViewController
}

extension Assembly: ProductDescriptionProvider {
  func makeProductDescription() -> UIViewController {
    let viewController = ProductDescriptionViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel
    return viewController
  }
  
  private var viewBinder: ProductDescriptionViewBinder {
    return ProductDescriptionViewBinder()
  }

  private var viewModel: ProductDescriptionViewModelType {
    return ProductDescriptionViewModel()
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
