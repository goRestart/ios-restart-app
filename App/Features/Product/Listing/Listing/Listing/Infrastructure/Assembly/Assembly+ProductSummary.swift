import Core
import Application

protocol ProductSummaryProvider {
  func makeProductSummary() -> UIViewController
}

extension Assembly: ProductSummaryProvider {
  func makeProductSummary() -> UIViewController {
    let viewController = ProductSummaryViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(with: viewController)
    return viewController
  }
  
  private var viewBinder: ProductSummaryViewBinder {
    return ProductSummaryViewBinder()
  }
  
  private func viewModel(with viewController: ProductSummaryViewController) -> ProductSummaryViewModelType {
    return ProductSummaryViewModel(
      getProductDraft: productDraftActions,
      productDraftViewMapper: productDraftViewMapper,
      uploadProduct: uploadProduct,
      coordinator: productSummaryCoordinator(with: viewController)
    )
  }
  
  private func productSummaryCoordinator(with viewController: ProductSummaryViewController) -> ProductSummaryCoordinator {
    return ProductSummaryCoordinator(
      productSummary: viewController
    )
  }
  
  private var productDraftViewMapper: ProductDraftViewMapper {
    return ProductDraftViewMapper(priceFormatter: priceFormatter)
  }
  
  private var priceFormatter: PriceFormatter {
    return PriceFormatter(
      numberFormatter: numberFormatter
    )
  }
  
  private var numberFormatter: NumberFormatter {
    return NumberFormatter()
  }
  
  private var uploadProduct: UploadProduct {
    return UploadProduct()
  }
}

// MARK: - Navigator

extension Assembly {
  func productSummaryNavigator(from: UIViewController) -> ProductSummaryNavigator {
    return ProductSummaryNavigator(
      from: from,
      productSummaryProvider: self
    )
  }
}
