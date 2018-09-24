import RxSwift
import RxCocoa

struct ProductSummaryViewBinder {
  func bind(view: ProductSummaryView, to viewModel: ProductSummaryViewModelType, using bag: DisposeBag) {
    viewModel.output.productDraft
      .drive(view.rx.productDraft)
      .disposed(by: bag)
    
    viewModel.output.state
      .drive(view.rx.state)
      .disposed(by: bag)
    
    view.rx.publishButtonWasTapped.subscribe { _ in
      viewModel.input.publishButtonPressed()
    }.disposed(by: bag)
  }
}
