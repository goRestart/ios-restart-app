import Core
import Application

extension Assembly {
  public func makeLogin() -> LoginViewController {
    let viewController = LoginViewController()
    viewController.viewModel = viewModel
    return viewController
  }
  
  private var viewModel: LoginViewModel {
    return LoginViewModel(
      authenticate: authenticate
    )
  }
  
  private var authenticate: Authenticate {
    return Authenticate()
  }
}
