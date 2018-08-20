import RxCocoa
import RxSwift

struct LoginViewBinder {
  
  func bind(view: LoginView, to viewModel: LoginViewModelType, using bag: DisposeBag) {
    view.usernameInput.rx.value
      .orEmpty
      .bind(to: viewModel.output.username)
      .disposed(by: bag)
    
    view.passwordInput.rx.value
      .orEmpty
      .bind(to: viewModel.output.password)
      .disposed(by: bag)
    
    view.usernameInput.rx
      .controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { _ in
        view.passwordInput.becomeFirstResponder()
      })
      .disposed(by: bag)
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    view.addGestureRecognizer(tapGestureRecognizer)
    
    tapGestureRecognizer.rx.event
      .subscribe(onNext: { _ in
        view.resignFirstResponder()
      })
      .disposed(by: bag)

    viewModel.output.userInteractionEnabled
      .bind(to: view.usernameInput.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.passwordInput.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .asObservable()
      .map { $0 == .loading }
      .bind(to: view.signInButton.rx.isLoading)
      .disposed(by: bag)
    
    viewModel.output.signInEnabled
      .asObservable()
      .bind(to: view.signInButton.rx.isEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: view.signInButton.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    view.signInButton.rx.tap
      .subscribe(onNext: { _ in
        viewModel.input.signUpButtonPressed()
      })
      .disposed(by: bag)
  }
}
