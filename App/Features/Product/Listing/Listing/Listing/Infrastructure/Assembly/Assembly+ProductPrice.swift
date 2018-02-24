import Core

extension Assembly {
  var productPrice: ProductPriceViewController {
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
