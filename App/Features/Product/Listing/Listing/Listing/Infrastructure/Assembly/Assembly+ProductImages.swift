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
  
  private func viewModel(for viewController: ProductImagesViewController) -> ProductImagesViewModelType {
    return ProductImagesViewModel(
      coordinator: productImagesCoordinator(with: viewController),
      productDraft: productDraftActions
    )
  }
  
  private func productImagesCoordinator(with viewController: ProductImagesViewController) -> ProductImagesCoordinable {
    let coordinator = ProductImagesCoordinator(
      productImages: viewController,
      cameraNavigator: cameraNavigator(from: viewController),
      productSelectorNavigator: productSelectorNavigator(from: viewController)
    )
    coordinator.delegate = viewController
    return coordinator
  }
  
  private func cameraNavigator(from viewController: UIViewController) -> CameraNavigator {
    return CameraNavigator(from: viewController)
  }
  
  private var viewBinder: ProductImagesViewBinder {
    return ProductImagesViewBinder()
  }
}
