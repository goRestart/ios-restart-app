import RxSwift
import RxCocoa

final class ProductImagesViewModel: ProductImagesViewModelType, ProductImagesViewModelInput, ProductImagesViewModelOutput {
  var input: ProductImagesViewModelInput { return self }
  var output: ProductImagesViewModelOutput { return self }
  
  private var images = [UIImage]()
  
  // MARK: - Output
  
  var nextStepEnabled: Driver<Bool> {
    return Observable.just(images.count > 0)
      .asDriver(onErrorJustReturn: false)
  }
  
  // MARK: - Input
  
  func onAdd(image: UIImage) {
    images.append(image)
  }
  
  func onRemove(image: UIImage) {
    images.removeAll { $0 == image }
  }
  
  func onNextStepPressed() {
    
  }
}
