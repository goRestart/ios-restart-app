import Core

protocol ProductImagesProvider {
  func makeProductImages() -> UIViewController
}

extension Assembly: ProductImagesProvider {
  func makeProductImages() -> UIViewController {
    let viewController = ProductImagesViewController()
//    viewController.viewModel = viewModel(for: viewController)
    return viewController
  }
  
//  private func viewModel(for viewController: UIViewController) -> ProductSelectorViewModelType {
//    return ProductSelectorViewModel(
//      productDraft: productDraftActions,
//      productDescriptionNavigator: productDescriptionNavigator(from: viewController)
//    )
//  }
  
//  private var viewBinder: ProductSelectorViewBinder {
//    return ProductSelectorViewBinder()
//  }
}
