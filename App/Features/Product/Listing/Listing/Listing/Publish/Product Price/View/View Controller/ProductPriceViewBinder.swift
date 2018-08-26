import RxSwift
import RxCocoa

struct ProductPriceViewBinder {
  func bind(view: ProductPriceView, to viewModel: ProductPriceViewModelType, using bag: DisposeBag) {
    view.rx.productPrice
      .bind(to: viewModel.output.price)
      .disposed(by: bag)
    
    viewModel.output.nextStepEnabled
      .bind(to: view.rx.nextButtonIsEnabled)
      .disposed(by: bag)
    
    view.rx.nextButtonWasTapped.subscribe { _  in
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
