import RxSwift

protocol ProductSummaryViewModelInput {
  func viewDidLoad()
  func publishButtonPressed()
}

protocol ProductSummaryViewModelOutput {
  var productDraft: Observable<ProductDraftUIModel> { get }
}

protocol ProductSummaryViewModelType {
  var input: ProductSummaryViewModelInput { get }
  var output: ProductSummaryViewModelOutput { get }
}
