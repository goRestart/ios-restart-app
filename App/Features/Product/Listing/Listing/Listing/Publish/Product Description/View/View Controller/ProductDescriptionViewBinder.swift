import RxSwift
import RxCocoa

struct ProductDescriptionViewBinder {
  func bind(view: ProductDescriptionView, to viewModel: ProductDescriptionViewModelType, using bag: DisposeBag) {
    view.rx.productDescription
      .subscribe(onNext: { description in
        viewModel.input.onChange(description: description)
      })
      .disposed(by: bag)
    
    viewModel.output.description
      .drive(view.rx.productDescription)
      .disposed(by: bag)
    
    viewModel.output.nextStepEnabled
      .drive(view.rx.nextButtonIsEnabled)
      .disposed(by: bag)

    view.rx.nextButtonWasTapped.subscribe { _ in
      view.resignFirstResponder()
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
