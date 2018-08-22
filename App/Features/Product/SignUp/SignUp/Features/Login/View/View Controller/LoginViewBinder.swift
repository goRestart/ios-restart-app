import RxCocoa
import RxSwift

struct LoginViewBinder {

  func bind(view: LoginView, to viewModel: LoginViewModelType, using bag: DisposeBag) {
    view.rx.username
      .asDriver()
      .drive(viewModel.output.username)
      .disposed(by: bag)
    
    view.rx.password
      .asDriver()
      .drive(viewModel.output.password)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.rx.userInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.signInEnabled
      .bind(to: view.rx.signInButtonEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .bind(to: view.rx.signInButtonIsLoading)
      .disposed(by: bag)

    view.rx.usernameEndEditing.subscribe { _ in
      view.onUsernameEndEditing()
    }.disposed(by: bag)
    
    view.rx.viewWasTapped.subscribe { _ in
      view.resignFirstResponder()
    }.disposed(by: bag)
    
    view.rx.signInButtonWasTapped.subscribe { _ in
      viewModel.input.signUpButtonPressed()
    }.disposed(by: bag)
  }
}
