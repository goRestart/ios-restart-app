import Core
import Application

extension Assembly {
  var productExtras: ProductExtrasViewController {
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
