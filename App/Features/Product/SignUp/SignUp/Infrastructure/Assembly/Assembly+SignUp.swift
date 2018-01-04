import Core
import Application

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
      emailValidator: emailValidator
    )
  }
  
  private var viewBinder: SignUpViewBinder {
    return SignUpViewBinder()
  }
  
  private var emailValidator: EmailValidator {
    return EmailValidator()
  }
  
  func signUpRouter(from view: UIViewController) -> SignUpRouter {
    return SignUpRouter(from: view)
  }
}
