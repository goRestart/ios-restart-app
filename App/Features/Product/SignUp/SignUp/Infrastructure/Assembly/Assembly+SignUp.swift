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
    return SignUpViewModel()
  }
  
  private var viewBinder: SignUpViewBinder {
    return SignUpViewBinder()
  }
  
  func signUpRouter(from view: UIViewController) -> SignUpRouter {
    return SignUpRouter(from: view)
  }
}
