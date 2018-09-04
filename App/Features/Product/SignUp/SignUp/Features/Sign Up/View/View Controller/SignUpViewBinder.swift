import RxCocoa
import RxSwift

struct SignUpViewBinder {
  func bind(view: SignUpView, to viewModel: SignUpViewModelType, using bag: DisposeBag) {
    view.rx.username.subscribe(onNext: { username in
      viewModel.input.onChange(username: username)
    }).disposed(by: bag)

    view.rx.email.subscribe(onNext: { email in
      viewModel.input.onChange(email: email)
    }).disposed(by: bag)
    
    view.rx.password.subscribe(onNext: { password in
      viewModel.input.onChange(password: password)
    }).disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .drive(view.rx.userInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .drive(view.rx.signUpButtonIsLoading)
      .disposed(by: bag)
    
    viewModel.output.error
      .drive(view.rx.error)
      .disposed(by: bag)
    
    viewModel.output.signUpEnabled
      .drive(view.rx.signUpButtonEnabled)
      .disposed(by: bag)

    view.rx.usernameEndEditing.subscribe { _ in
      view.onUsernameEndEditing()
    }.disposed(by: bag)
    
    view.rx.emailEndEditing.subscribe { _ in
      view.onEmailEndEditing()
    }.disposed(by: bag)
    
    view.rx.viewWasTapped.subscribe { _ in
      view.resignFirstResponder()
    }.disposed(by: bag)
    
    view.rx.signUpButtonWasTapped.subscribe { _ in
      viewModel.input.signInButtonPressed()
    }.disposed(by: bag)
  }
}
