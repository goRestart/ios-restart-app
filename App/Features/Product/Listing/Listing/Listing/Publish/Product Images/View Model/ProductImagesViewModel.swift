import RxSwift
import RxCocoa

final class ProductImagesViewModel: ProductImagesViewModelType, ProductImagesViewModelInput, ProductImagesViewModelOutput {
  var input: ProductImagesViewModelInput { return self }
  var output: ProductImagesViewModelOutput { return self }
  
  private var images = [UIImage]()
  
  // MARK: - Output
  
  private let addedImagesRelay = BehaviorRelay<Bool>(value: false)
  var nextStepEnabled: Driver<Bool> {
    return addedImagesRelay.asDriver()
  }
  
  // MARK: - Input
  
  func onAdd(image: UIImage) {
    images.append(image)
    addedImagesRelay.accept(true)
  }
  
  func onRemove(image: UIImage) {
    images.removeAll { $0 == image }
    
    let thereAreImagesAdded = images.count > 0
    addedImagesRelay.accept(thereAreImagesAdded)
  }
  
  func onNextStepPressed() {
    
  }
}
