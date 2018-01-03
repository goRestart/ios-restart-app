import Core

extension Assembly {
  public func makeNotLogged() -> NotLoggedViewController {
    let viewController = NotLoggedViewController()
    viewController.viewModel = viewModel
    return viewController
  }
  
  private var viewModel: NotLoggedViewModelType {
    return NotLoggedViewModel()
  }
}
