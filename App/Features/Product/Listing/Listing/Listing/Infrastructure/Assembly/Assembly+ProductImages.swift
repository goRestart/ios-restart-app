import Core

protocol ProductImagesProvider {
  func makeProductImages() -> UIViewController
}

extension Assembly: ProductImagesProvider {
  func makeProductImages() -> UIViewController {
    let viewController = ProductImagesViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(for: viewController)
    return viewController
  }
  
  private func viewModel(for viewController: UIViewController) -> ProductImagesViewModelType {
    return ProductImagesViewModel()
  }
  
  private var viewBinder: ProductImagesViewBinder {
    return ProductImagesViewBinder()
  }
}
