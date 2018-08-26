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
    viewController.viewModel = viewModel
    return viewController
  }

  private var viewBinder: ProductExtrasViewBinder {
    return ProductExtrasViewBinder()
  }
  
  private var viewModel: ProductExtrasViewModelType {
    return ProductExtrasViewModel(
      getProductExtras: getProductExtras
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
