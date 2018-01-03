import Foundation
import Core

struct LoginRouter {
  
  private let from: UIViewController
  
  init(from: UIViewController) {
    self.from = from
  }
  
  func route() {
    let viewController = resolver.makeLogin()
    from.navigationController?.pushViewController(viewController, animated: true)
  }
}
