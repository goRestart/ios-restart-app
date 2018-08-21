import Core

public protocol NotLoggedProvider {
  func makeNotLogged() -> UIViewController
}

extension Assembly: NotLoggedProvider {
  public func makeNotLogged() -> UIViewController {
    let viewController = NotLoggedViewController()
    viewController.viewModel = viewModel(for: viewController)
    
    let navigationController = UINavigationController(
      rootViewController: viewController
    )
    navigationController.navigationBar.prefersLargeTitles = true
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
}
