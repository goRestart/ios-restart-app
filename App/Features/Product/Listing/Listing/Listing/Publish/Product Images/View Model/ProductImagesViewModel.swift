import RxSwift
import RxCocoa

private enum ImageStatus {
  case filled(UIImage)
}

final class ProductImagesViewModel: ProductImagesViewModelType, ProductImagesViewModelInput, ProductImagesViewModelOutput {
  var input: ProductImagesViewModelInput { return self }
  var output: ProductImagesViewModelOutput { return self }
  
  private var imagesStatus = [Int: ImageStatus]()
  
  private let productImagesCoordinator: ProductImagesCoordinator
  
  init(productImagesCoordinator: ProductImagesCoordinator) {
    self.productImagesCoordinator = productImagesCoordinator
  }
  
  // MARK: - Output
  
  private let addedImagesRelay = BehaviorRelay<Bool>(value: false)
  var nextStepEnabled: Driver<Bool> {
    return addedImagesRelay.asDriver()
  }
  
  private let imageIndexRemovalRelay = PublishRelay<Int>()
  var imageIndexShouldBeRemoved: Driver<Int> {
    return imageIndexRemovalRelay.asDriver(onErrorJustReturn: -1)
  }
  
  // MARK: - Input

  func onSelectButton(with index: Int) {
    let imageIsAlreadyFilled = imagesStatus[index] != nil
    guard imageIsAlreadyFilled else {
      productImagesCoordinator.openCamera(with: index)
      return
    }
    imageIndexRemovalRelay.accept(index)
  }
  
  func onAdd(image: UIImage, with index: Int) {
    imagesStatus[index] = .filled(image)
    addedImagesRelay.accept(true)
  }
  
  func onRemoveImage(with index: Int) {
    imagesStatus[index] = nil
    
    let thereAreImagesAdded = imagesStatus.count > 0
    addedImagesRelay.accept(thereAreImagesAdded)
  }

  func onNextStepPressed() {
    productImagesCoordinator.openDescription()
  }
}
