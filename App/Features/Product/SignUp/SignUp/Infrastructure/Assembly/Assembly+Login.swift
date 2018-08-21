import Core
import Application

protocol LoginProvider {
  func makeLogin() -> UIViewController
}

extension Assembly: LoginProvider {
  func makeLogin() -> UIViewController {
    let viewController = LoginViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel
    return viewController
  }
  
  private var viewModel: LoginViewModelType {
    return LoginViewModel(
      authenticate: authenticate
    )
  }
  
  private var viewBinder: LoginViewBinder {
    return LoginViewBinder()
  }
  
  private var authenticate: Authenticate {
    return Authenticate()
  }
  
  func loginRouter(from view: UIViewController) -> LoginRouter {
    return LoginRouter(
      from: view,
      loginProvider: self
    )
  }
}
