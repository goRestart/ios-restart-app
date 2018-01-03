import Core

extension Assembly {
  public func makeNotLogged() -> UINavigationController {
    let viewController = NotLoggedViewController()
    viewController.viewModel = viewModel(for: viewController)
    
    let navigationController = UINavigationController(
      rootViewController: viewController
    )
    return navigationController
  }
  
  private func viewModel(for view: UIViewController) -> NotLoggedViewModelType {
    let loginRouter = self.loginRouter(from: view)
    return NotLoggedViewModel(
      loginRouter: loginRouter
    )
  }
}
