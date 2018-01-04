import Foundation

struct NotLoggedViewModel: NotLoggedViewModelInput, NotLoggedViewModelType {
  
  var input: NotLoggedViewModelInput { return self }
  
  private let loginRouter: LoginRouter
  private let signUpRouter: SignUpRouter
  
  init(loginRouter: LoginRouter,
       signUpRouter: SignUpRouter)
  {
    self.loginRouter = loginRouter
    self.signUpRouter = signUpRouter
  }
  
  func signInButtonPressed() {
    loginRouter.route()
  }
  
  func signUpButtonPressed() {
    signUpRouter.route()
  }
}
