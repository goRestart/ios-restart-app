import Core

protocol ProductSummaryProvider {
  func makeProductSummary() -> UIViewController
}

extension Assembly: ProductSummaryProvider {
  func makeProductSummary() -> UIViewController {
    let viewController = ProductSummaryViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel
    return viewController
  }
  
  private var viewBinder: ProductSummaryViewBinder {
    return ProductSummaryViewBinder()
  }
  
  private var viewModel: ProductSummaryViewModelType {
    return ProductSummaryViewModel(
      getProductDraft: productDraftActions,
      productDraftViewMapper: productDraftViewMapper
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
