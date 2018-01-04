import RxCocoa
import RxSwift

struct SignUpViewBinder {
  
  func bind(view: SignUpView, to viewModel: SignUpViewModelType, using bag: DisposeBag)
  {
    view.usernameTextField.input.rx.value
      .orEmpty
      .bind(to: viewModel.output.username)
      .disposed(by: bag)
    
    view.emailTextField.input.rx.value
      .orEmpty
      .bind(to: viewModel.output.email)
      .disposed(by: bag)
    
    view.passwordTextField.input.rx.value
      .orEmpty
      .bind(to: viewModel.output.password)
      .disposed(by: bag)
    
    view.usernameTextField.input.rx
      .controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { _ in
        view.emailTextField.becomeFirstResponder()
      })
      .disposed(by: bag)
    
    view.emailTextField.input.rx
      .controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { _ in
        view.passwordTextField.becomeFirstResponder()
      })
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.usernameTextField.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.emailTextField.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.passwordTextField.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .asObservable()
      .map { $0 == .loading}
      .bind(to: view.signUpButton.rx.isLoading)
      .disposed(by: bag)
    
    viewModel.output.signUpEnabled
      .asObservable()
      .bind(to: view.signUpButton.rx.isEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.signUpButton.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    view.signUpButton.rx.tap
      .debounce(0.2, scheduler: MainScheduler.instance)
      .subscribe(onNext: { _ in
        viewModel.input.signInButtonPressed()
      })
      .disposed(by: bag)
    
    viewModel.output.error
      .asObservable()
      .subscribe(onNext: { error in
        view.set(error)
      })
      .disposed(by: bag)
  }
}
