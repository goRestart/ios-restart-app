import Foundation

struct NotLoggedViewModel: NotLoggedViewModelInput, NotLoggedViewModelType {
  
  var input: NotLoggedViewModelInput { return self }
  
  private let loginRouter: LoginRouter
  
  init(loginRouter: LoginRouter) {
    self.loginRouter = loginRouter
  }
  
  func signInButtonPressed() {
    loginRouter.route()
  }
  
  func signUpButtonPressed() {
    print("Opening sign up")
  }
}
