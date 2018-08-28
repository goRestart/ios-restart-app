import RxSwift
import RxCocoa

struct ProductPriceViewBinder {
  func bind(view: ProductPriceView, to viewModel: ProductPriceViewModelType, using bag: DisposeBag) {
    view.rx.productPrice
      .bind(to: viewModel.input.price)
      .disposed(by: bag)
    
    viewModel.input.price
      .bind(to: view.rx.productPrice)
      .disposed(by: bag)

    viewModel.output.nextStepEnabled
      .bind(to: view.rx.nextButtonIsEnabled)
      .disposed(by: bag)
    
    view.rx.nextButtonWasTapped.subscribe { _  in
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
