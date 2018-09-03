import RxCocoa
import RxSwift

struct ProductSelectorViewBinder {
  func bind(view: ProductSelectorView, to viewModel: ProductSelectorViewModelType, using bag: DisposeBag) {
    
    view.rx.state.subscribe(onNext: { (event) in
      if case let .gameSelected(title, identifier) = event {
        view.resignFirstResponder()
        viewModel.input.onGameSelected(with: title, identifier)
      }
    }).disposed(by: bag)
  }
}
