import RxCocoa
import RxSwift

struct SignUpViewBinder {
  func bind(view: SignUpView, to viewModel: SignUpViewModelType, using bag: DisposeBag) {
    view.rx.username
      .asDriver()
      .drive(viewModel.output.username)
      .disposed(by: bag)

    view.rx.email
      .asDriver()
      .drive(viewModel.output.email)
      .disposed(by: bag)
    
    view.rx.password
      .asDriver()
      .drive(viewModel.output.password)
      .disposed(by: bag)

    viewModel.output.userInteractionEnabled
      .bind(to: view.rx.userInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .bind(to: view.rx.signUpButtonIsLoading)
      .disposed(by: bag)
    
    viewModel.output.error
      .bind(to: view.rx.error)
      .disposed(by: bag)
    
    viewModel.output.signUpEnabled
      .bind(to: view.rx.signUpButtonEnabled)
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
