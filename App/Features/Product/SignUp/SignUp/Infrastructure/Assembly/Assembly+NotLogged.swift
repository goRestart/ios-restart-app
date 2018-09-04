import Core
import UI

public protocol NotLoggedProvider {
  func makeNotLogged() -> UIViewController
}

extension Assembly: NotLoggedProvider {
  public func makeNotLogged() -> UIViewController {
    let viewController = NotLoggedViewController(
      viewBinder: viewBinder
    )
    viewController.viewModel = viewModel(for: viewController)
    
    let navigationController = NavigationController(
      rootViewController: viewController
    )
    return navigationController
  }
  
  private func viewModel(for view: UIViewController) -> NotLoggedViewModelType {
    let loginRouter = self.loginRouter(from: view)
    let signUpRouter = self.signUpRouter(from: view)
    return NotLoggedViewModel(
      loginRouter: loginRouter,
      signUpRouter: signUpRouter
    )
  }
  
  private var viewBinder: NotLoggedViewBinder {
    return NotLoggedViewBinder()
  }
}
