import RxSwift
import RxCocoa

protocol ProductImagesViewModelInput {
  func onAdd(image: UIImage)
  func onRemove(image: UIImage)
  func onNextStepPressed()
}

protocol ProductImagesViewModelOutput {
  var nextStepEnabled: Driver<Bool> { get }
}

protocol ProductImagesViewModelType {
  var input: ProductImagesViewModelInput { get }
  var output: ProductImagesViewModelOutput { get }
}
