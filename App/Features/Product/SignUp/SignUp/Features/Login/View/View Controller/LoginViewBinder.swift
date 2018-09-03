import RxCocoa
import RxSwift

struct LoginViewBinder {
  func bind(view: LoginView, to viewModel: LoginViewModelType, using bag: DisposeBag) {
    
    view.rx.username.subscribe(onNext: { username in
      viewModel.input.onChange(username: username)
    }).disposed(by: bag)
    
    view.rx.password.subscribe(onNext: { password in
      viewModel.input.onChange(password: password)
    }).disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .drive(view.rx.userInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.signInEnabled
      .drive(view.rx.signInButtonEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .drive(view.rx.signInButtonIsLoading)
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
