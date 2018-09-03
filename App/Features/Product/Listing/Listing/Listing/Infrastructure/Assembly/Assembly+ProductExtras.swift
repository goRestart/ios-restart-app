import Core
import Application

protocol ProductExtrasProvider {
  func makeProductExtras() -> UIViewController
}

extension Assembly: ProductExtrasProvider {
  func makeProductExtras() -> UIViewController {
    let viewController = ProductExtrasViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(from: viewController)
    return viewController
  }

  private var viewBinder: ProductExtrasViewBinder {
    return ProductExtrasViewBinder()
  }
  
  private func viewModel(from viewController: UIViewController) -> ProductExtrasViewModelType {
    return ProductExtrasViewModel(
      productDraft: productDraftActions,
      getProductExtras: getProductExtras,
      productSummaryNavigator: productSummaryNavigator(from: viewController)
    )
  }
  
  private var getProductExtras: GetProductExtras {
    return GetProductExtras()
  }
}

// MARK: - Navigator

extension Assembly {
  func productExtrasNavigator(from viewController: UIViewController ) -> ProductExtrasNavigator {
    return ProductExtrasNavigator(
      from: viewController,
      productExtrasProvider: self
    )
  }
}
