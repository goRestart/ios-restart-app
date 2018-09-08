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
      productDraft: productDraftActions,
      productDescriptionNavigator: productDescriptionNavigator(from: viewController)
    )
  }
  
  private var viewBinder: ProductSelectorViewBinder {
    return ProductSelectorViewBinder()
  }
}

// MARK: - Navigator

extension Assembly {
  func productSelectorNavigator(from: UIViewController) -> ProductSelectorNavigator {
    return ProductSelectorNavigator(
      from: from,
      productSelectorProvider: self
    )
  }
}
