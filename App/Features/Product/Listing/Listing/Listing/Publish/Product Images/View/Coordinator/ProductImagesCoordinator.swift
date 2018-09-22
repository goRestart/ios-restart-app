import Foundation

protocol ProductImagesCoordinatorIndex: class {
  func didSelectImage(_ image: UIImage, with index: Int)
}

final class ProductImagesCoordinator: ProductImagesCoordinable {

  private weak var productImages: UIViewController?
  private let cameraNavigator: CameraNavigator
  private let productSelectorNavigator: ProductSelectorNavigator
  private var index: Int?
  
  weak var delegate: ProductImagesCoordinatorIndex?
  
  init(productImages: UIViewController,
       cameraNavigator: CameraNavigator,
       productSelectorNavigator: ProductSelectorNavigator)
  {
    self.productImages = productImages
    self.cameraNavigator = cameraNavigator
    self.productSelectorNavigator = productSelectorNavigator
  }
  
  func openCamera(with index: Int) {
    self.index = index
    
    cameraNavigator.delegate = self
    cameraNavigator.navigate()
  }
  
  func openDescription() {
    productSelectorNavigator.navigate()
  }
}

// MARK: - CameraNavigatorDelegate

extension ProductImagesCoordinator: CameraNavigatorDelegate {
  func didSelectImage(_ image: UIImage) {
    guard let index = index else { return }
    delegate?.didSelectImage(image, with: index)
  }
  
  func close() {
    productImages?.dismiss(animated: true)
  }
}
