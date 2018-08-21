import Core
import Application
import Domain

protocol SignUpProvider {
  func makeSignUp() -> UIViewController
}

extension Assembly: SignUpProvider {
  func makeSignUp() -> UIViewController {
    let viewController = SignUpViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel
    return viewController
  }
  
  private var viewModel: SignUpViewModelType {
    return SignUpViewModel(
      emailValidator: emailValidator,
      registerUser: registerUser
    )
  }
  
  private var viewBinder: SignUpViewBinder {
    return SignUpViewBinder()
  }
  
  private var emailValidator: EmailValidator {
    return EmailValidator()
  }
  
  private var registerUser: RegisterUserUseCase {
    return RegisterUser()
  }
  
  func signUpRouter(from view: UIViewController) -> SignUpRouter {
    return SignUpRouter(
      from: view,
      signUpProvider: self
    )
  }
}
