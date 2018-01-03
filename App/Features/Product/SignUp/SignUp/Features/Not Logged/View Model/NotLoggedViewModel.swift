import Foundation

struct NotLoggedViewModel: NotLoggedViewModelInput, NotLoggedViewModelType {
  
  var input: NotLoggedViewModelInput { return self }
  
  func signInButtonPressed() {
    print("Opening sign in")
  }
  
  func signUpButtonPressed() {
    print("Opening sign up")
  }
}
