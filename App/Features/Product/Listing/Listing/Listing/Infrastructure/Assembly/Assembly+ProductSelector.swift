import Core

extension Assembly {
  var productSelector: ProductSelectorViewController {
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
