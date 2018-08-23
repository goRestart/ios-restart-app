import RxCocoa
import RxSwift

struct ProductSelectorViewBinder {
  func bind(view: ProductSelectorView, to viewModel: ProductSelectorViewModelType, using bag: DisposeBag) {
    
    view.rx.state.subscribe(onNext: { (event) in
      if case let .gameSelected(identifier) = event {
        viewModel.input.onGameSelected(with: identifier)
      }
    }).disposed(by: bag)
  }
}
