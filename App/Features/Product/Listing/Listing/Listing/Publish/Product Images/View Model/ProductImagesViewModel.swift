import Domain
import RxSwift
import RxCocoa

final class ProductImagesViewModel: ProductImagesViewModelType, ProductImagesViewModelInput, ProductImagesViewModelOutput {
  var input: ProductImagesViewModelInput { return self }
  var output: ProductImagesViewModelOutput { return self }
  
  private var imagesStatus = [Int: UIImage]()
  private var images: [UIImage] {
    return imagesStatus.sorted { $0.key < $1.key }.map { $0.value }
  }
  private let coordinator: ProductImagesCoordinable
  private let productDraft: ProductDraftUseCase
  
  init(coordinator: ProductImagesCoordinable,
       productDraft: ProductDraftUseCase)
  {
    self.coordinator = coordinator
    self.productDraft = productDraft
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

  func onImageSelected(with index: Int) {
    let imageIsAlreadyFilled = imagesStatus[index] != nil
    guard imageIsAlreadyFilled else {
      coordinator.openCamera(with: index)
      return
    }
    imageIndexRemovalRelay.accept(index)
  }
  
  func onAdd(image: UIImage, with index: Int) {
    imagesStatus[index] = image
    addedImagesRelay.accept(true)
  }
  
  func onRemoveImage(with index: Int) {
    imagesStatus[index] = nil
    
    let thereAreImagesAdded = imagesStatus.count > 0
    addedImagesRelay.accept(thereAreImagesAdded)
  }

  func onNextStepPressed() {
    productDraft.save(images: images)
    coordinator.openDescription()
  }
  
  func onCloseButtonPressed() {
    productDraft.clear()
    coordinator.close()
  }
}
