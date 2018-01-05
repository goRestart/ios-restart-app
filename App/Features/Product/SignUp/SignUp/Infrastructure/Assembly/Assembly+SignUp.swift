import Core
import Application
import Domain

extension Assembly {
  public func makeSignUp() -> SignUpViewController {
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
    return SignUpRouter(from: view)
  }
}
