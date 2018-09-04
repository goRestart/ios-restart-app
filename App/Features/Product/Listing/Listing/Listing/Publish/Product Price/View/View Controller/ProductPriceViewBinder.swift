import RxSwift
import RxCocoa

struct ProductPriceViewBinder {
  func bind(view: ProductPriceView, to viewModel: ProductPriceViewModelType, using bag: DisposeBag) {
    view.rx.productPrice
      .subscribe(onNext: { price in
        viewModel.input.onChange(price: price)
      }).disposed(by: bag)
    
    viewModel.output.price
      .drive(view.rx.productPrice)
      .disposed(by: bag)

    viewModel.output.nextStepEnabled
      .drive(view.rx.nextButtonIsEnabled)
      .disposed(by: bag)
    
    view.rx.nextButtonWasTapped.subscribe { _  in
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
