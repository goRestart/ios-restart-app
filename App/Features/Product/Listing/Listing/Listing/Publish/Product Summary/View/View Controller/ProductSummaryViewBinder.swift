import RxSwift
import RxCocoa

struct ProductSummaryViewBinder {
  func bind(view: ProductSummaryView, to viewModel: ProductSummaryViewModelType, using bag: DisposeBag) {
    viewModel.output.productDraft
      .bind(to: view.rx.productDraft)
      .disposed(by: bag)
  }
}
