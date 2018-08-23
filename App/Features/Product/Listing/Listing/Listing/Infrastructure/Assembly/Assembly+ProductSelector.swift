import Core

extension Assembly {
  var productSelector: ProductSelectorViewController {
    let viewController = ProductSelectorViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel
    return viewController
  }

  private var viewModel: ProductSelectorViewModelType {
    return ProductSelectorViewModel()
  }
  
  private var viewBinder: ProductSelectorViewBinder {
    return ProductSelectorViewBinder()
  }
}
