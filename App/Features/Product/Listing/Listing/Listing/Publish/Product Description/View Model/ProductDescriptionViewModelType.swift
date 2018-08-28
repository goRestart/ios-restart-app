import RxSwift

protocol ProductDescriptionViewModelInput {
  func viewWillAppear()
  func onNextStepPressed()
}

protocol ProductDescriptionViewModelOutput {
  var description: BehaviorSubject<String> { get }
  var nextStepEnabled: Observable<Bool> { get }
}

protocol ProductDescriptionViewModelType {
  var input: ProductDescriptionViewModelInput { get }
  var output: ProductDescriptionViewModelOutput { get }
}
