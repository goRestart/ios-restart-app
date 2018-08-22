import RxSwift
import RxCocoa

struct ProductDescriptionViewBinder {
  func bind(view: ProductDescriptionView, to viewModel: ProductDescriptionViewModelType, using bag: DisposeBag) {
    view.rx.productDescription
      .bind(to: viewModel.output.description)
      .disposed(by: bag)
  }
}
