import RxCocoa

protocol ProductSummaryViewModelInput {
  func viewDidLoad()
  func publishButtonPressed()
}

protocol ProductSummaryViewModelOutput {
  var productDraft: Driver<ProductDraftUIModel?> { get }
}

protocol ProductSummaryViewModelType {
  var input: ProductSummaryViewModelInput { get }
  var output: ProductSummaryViewModelOutput { get }
}
