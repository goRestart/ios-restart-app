import RxSwift

protocol ProductPriceViewModelInput {
  var price: BehaviorSubject<String> { get }
  
  func onNextStepPressed()
}

protocol ProductPriceViewModelOutput {
  var nextStepEnabled: Observable<Bool> { get }
}

protocol ProductPriceViewModelType {
  var input: ProductPriceViewModelInput { get }
  var output: ProductPriceViewModelOutput { get }
}
