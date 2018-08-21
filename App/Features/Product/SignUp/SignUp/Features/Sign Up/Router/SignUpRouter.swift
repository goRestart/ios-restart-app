import Foundation
import Core

struct SignUpRouter {
  
  private let from: UIViewController
  private let signUpProvider: SignUpProvider
  
  init(from: UIViewController,
       signUpProvider: SignUpProvider)
  {
    self.from = from
    self.signUpProvider = signUpProvider
  }
  
  func route() {
    let viewController = signUpProvider.makeSignUp()
    from.navigationController?.pushViewController(viewController, animated: true)
  }
}
