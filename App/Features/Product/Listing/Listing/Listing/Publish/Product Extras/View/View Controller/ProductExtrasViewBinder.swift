import RxSwift
import RxCocoa

struct ProductExtrasViewBinder {
  func bind(view: ProductExtrasView, to viewModel: ProductExtrasViewModelType, using bag: DisposeBag) {
    viewModel.output.productExtras
      .drive(view.rx.productExtras)
      .disposed(by: bag)
    
    view.rx.state.subscribe(onNext: { state in
      switch state {
      case .selectExtra(let extraId):
        viewModel.input.onSelectProductExtra(with: extraId)
      case .unselectExtra(let extraId):
        viewModel.input.onUnSelectProductExtra(with: extraId)
      }
    }).disposed(by: bag)
    
    view.rx.nextButtonTapped.subscribe { _ in
      viewModel.input.nextButtonPressed()
    }.disposed(by: bag)
  }
}
