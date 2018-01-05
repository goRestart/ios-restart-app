import Foundation
import Core

struct SignUpRouter {
  
  private let from: UIViewController
  
  init(from: UIViewController) {
    self.from = from
  }
  
  func route() {
    let viewController = resolver.makeSignUp()
    from.navigationController?.pushViewController(viewController, animated: true)
  }
}
