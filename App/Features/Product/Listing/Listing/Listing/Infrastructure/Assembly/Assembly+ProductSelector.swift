import Core

extension Assembly {
  var productSelector: ProductSelectorViewController {
    let viewController = ProductSelectorViewController()
    viewController.viewModel = viewModel
    return viewController
  }

  private var viewModel: ProductSelectorViewModelType {
    return ProductSelectorViewModel()
  }
}
