import RxSwift
import RxCocoa

struct ProductDescriptionViewBinder {
  func bind(view: ProductDescriptionView, to viewModel: ProductDescriptionViewModelType, using bag: DisposeBag) {
    
    view.rx.productDescription
      .bind(to: viewModel.output.description)
      .disposed(by: bag)
    
    viewModel.output.description
      .bind(to: view.rx.productDescription)
      .disposed(by: bag)
    
    viewModel.output.nextStepEnabled
      .bind(to: view.rx.nextButtonIsEnabled)
      .disposed(by: bag)

    view.rx.nextButtonWasTapped.subscribe { _ in
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
