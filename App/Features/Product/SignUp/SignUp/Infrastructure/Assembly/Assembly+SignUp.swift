import Core
import Application

extension Assembly {
  public func makeSignUp() -> SignUpViewController {
    let viewController = SignUpViewController()
    return viewController
  }
  
  func signUpRouter(from view: UIViewController) -> SignUpRouter {
    return SignUpRouter(from: view)
  }
}
