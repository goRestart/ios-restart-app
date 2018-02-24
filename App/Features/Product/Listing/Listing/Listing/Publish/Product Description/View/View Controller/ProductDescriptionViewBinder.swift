import RxSwift
import RxCocoa

struct ProductDescriptionViewBinder {
  func bind(view: ProductDescriptionView, to viewModel: ProductDescriptionViewModelType, using bag: DisposeBag) {
    view.inputTextField.rx.value
      .orEmpty
      .bind(to: viewModel.output.description)
      .disposed(by: bag)
  }
}
