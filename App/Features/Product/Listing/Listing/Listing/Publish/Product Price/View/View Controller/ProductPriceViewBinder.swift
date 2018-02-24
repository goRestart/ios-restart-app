import RxSwift
import RxCocoa

struct ProductPriceViewBinder {
  func bind(view: ProductPriceView, to viewModel: ProductPriceViewModelType, using bag: DisposeBag) {
    view.inputTextField.rx.value
      .orEmpty
      .bind(to: viewModel.output.description)
      .disposed(by: bag)
  }
}
