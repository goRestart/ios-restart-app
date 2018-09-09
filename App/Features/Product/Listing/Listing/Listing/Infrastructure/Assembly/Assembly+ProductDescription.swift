import Core
import Application

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
      productDraft: productDraftActions,
      productPriceNavigator: productPriceNavigator(from: viewController)
    )
  }
}

// MARK: - Navigator

extension Assembly {
  func productDescriptionNavigator(from viewController: UIViewController) -> ProductDescriptionNavigable {
    return ProductDescriptionNavigator(
      from: viewController,
      productDescriptionProvider: self
    )
  }
 }
