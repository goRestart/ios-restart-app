import Foundation
import Core

struct LoginRouter {
  
  private let from: UIViewController
  private let loginProvider: LoginProvider
  
  init(from: UIViewController,
       loginProvider: LoginProvider)
  {
    self.from = from
    self.loginProvider = loginProvider
  }
  
  func route() {
    let viewController = loginProvider.makeLogin()
    from.navigationController?.pushViewController(viewController, animated: true)
  }
}
