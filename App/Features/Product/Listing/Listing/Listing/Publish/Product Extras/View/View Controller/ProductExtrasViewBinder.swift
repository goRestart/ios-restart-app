import RxSwift
import RxCocoa

struct ProductExtrasViewBinder {
  func bind(view: ProductExtrasView, to viewModel: ProductExtrasViewModelType, using bag: DisposeBag) {
    viewModel.output.productExtras
      .bind(to: view.rx.productExtras)
      .disposed(by: bag)
    
    view.rx.state.subscribe(onNext: { state in
      switch state {
      case .selectExtra(let extraId):
        viewModel.input.didSelectProductExtra(with: extraId)
      case .unselectExtra(let extraId):
        viewModel.input.didUnSelectProductExtra(with: extraId)
      }
    }).disposed(by: bag)
    
    view.rx.nextButtonTapped.subscribe { _ in
      viewModel.input.didTapNextButton()
    }.disposed(by: bag)
  }
}
