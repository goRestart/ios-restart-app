import RxSwift
import RxCocoa

protocol ProductPriceViewModelInput {
  func viewWillAppear()
  func onChange(price: String)
  func onNextStepPressed()
}

protocol ProductPriceViewModelOutput {
  var nextStepEnabled: Driver<Bool> { get }
  var price: Driver<String> { get }
}

protocol ProductPriceViewModelType {
  var input: ProductPriceViewModelInput { get }
  var output: ProductPriceViewModelOutput { get }
}
