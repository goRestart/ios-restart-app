import Core

extension Assembly {
  var productDescription: ProductDescriptionViewController {
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
