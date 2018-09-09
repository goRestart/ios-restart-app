import RxSwift
import RxCocoa

protocol ProductImagesViewModelInput {
  func onImageSelected(with index: Int)
  func onAdd(image: UIImage, with index: Int)
  func onRemoveImage(with index: Int)
  func onNextStepPressed()
  func onCloseButtonPressed()
}

protocol ProductImagesViewModelOutput {
  var nextStepEnabled: Driver<Bool> { get }
  var imageIndexShouldBeRemoved: Driver<Int> { get }
}

protocol ProductImagesViewModelType {
  var input: ProductImagesViewModelInput { get }
  var output: ProductImagesViewModelOutput { get }
}
