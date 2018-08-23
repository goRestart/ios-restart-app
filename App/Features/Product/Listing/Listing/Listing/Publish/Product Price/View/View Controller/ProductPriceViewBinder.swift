import RxSwift
import RxCocoa

struct ProductPriceViewBinder {
  func bind(view: ProductPriceView, to viewModel: ProductPriceViewModelType, using bag: DisposeBag) {
    
    view.rx.productPrice
      .bind(to: viewModel.output.price)
      .disposed(by: bag)
    }
}
