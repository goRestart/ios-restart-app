import RxCocoa

enum ProductSummaryState {
  case idle
  case publishing
}

protocol ProductSummaryViewModelInput {
  func viewDidLoad()
  func publishButtonPressed()
}

protocol ProductSummaryViewModelOutput {
  var state: Driver<ProductSummaryState> { get }
  var productDraft: Driver<ProductDraftUIModel?> { get }
}

protocol ProductSummaryViewModelType {
  var input: ProductSummaryViewModelInput { get }
  var output: ProductSummaryViewModelOutput { get }
}
