import RxSwift
import RxCocoa

struct ProductSummaryViewBinder {
  func bind(view: ProductSummaryView, to viewModel: ProductSummaryViewModelType, using bag: DisposeBag) {
    viewModel.output.productDraft
      .drive(view.rx.productDraft)
      .disposed(by: bag)
    
    view.rx.publishButtonWasTapped.subscribe { _ in
      viewModel.input.publishButtonPressed()
    }.disposed(by: bag)
  }
}
