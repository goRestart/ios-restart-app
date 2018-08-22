import RxCocoa
import RxSwift

struct NotLoggedViewBinder {
  func bind(view: NotLoggedView, to viewModel: NotLoggedViewModelType, using bag: DisposeBag) {
    view.rx.signInButtonWasTapped.subscribe { _ in
      viewModel.input.signInButtonPressed()
    }.disposed(by: bag)
    
    view.rx.signUpButtonWasTapped.subscribe { _ in
      viewModel.input.signUpButtonPressed()
    }.disposed(by: bag)
  }
}
