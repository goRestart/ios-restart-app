import RxSwift

protocol ProductPriceViewModelTypeInput {
  func onNextStepPressed()
}

protocol ProductPriceViewModelTypeOutput {
  var description: BehaviorSubject<String> { get }
  var nextStepEnabled: BehaviorSubject<Bool> { get }
}

protocol ProductPriceViewModelType {
  var input: ProductPriceViewModelTypeInput { get }
  var output: ProductPriceViewModelTypeOutput { get }
}
