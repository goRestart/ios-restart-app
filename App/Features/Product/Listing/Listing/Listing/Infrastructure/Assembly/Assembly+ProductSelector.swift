import Core

protocol ProductSelectorProvider {
  func makeProductSelector() -> UIViewController
}

extension Assembly: ProductSelectorProvider {
  func makeProductSelector() -> UIViewController {
    let viewController = ProductSelectorViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(for: viewController)
    return viewController
  }
  
  private func viewModel(for viewController: UIViewController) -> ProductSelectorViewModelType {
    return ProductSelectorViewModel(
      productDescriptionNavigator: productDescriptionNavigator(from: viewController)
    )
  }
  
  private var viewBinder: ProductSelectorViewBinder {
    return ProductSelectorViewBinder()
  }
}
