import RxSwift
import RxCocoa

struct ProductExtrasViewBinder {
  func bind(view: ProductExtrasView, to viewModel: ProductExtrasViewModelType, using bag: DisposeBag) {
    viewModel.output.productExtras
      .bind(to: view.rx.productExtras)
      .disposed(by: bag)
  }
}
