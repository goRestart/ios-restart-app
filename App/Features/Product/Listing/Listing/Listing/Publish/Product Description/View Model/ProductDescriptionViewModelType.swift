import RxSwift
import RxCocoa

protocol ProductDescriptionViewModelInput {
  func viewWillAppear()
  func onChange(description: String)
  func onNextStepPressed()
}

protocol ProductDescriptionViewModelOutput {
  var description: Driver<String> { get }
  var nextStepEnabled: Driver<Bool> { get }
}

protocol ProductDescriptionViewModelType {
  var input: ProductDescriptionViewModelInput { get }
  var output: ProductDescriptionViewModelOutput { get }
}
