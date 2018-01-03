import RxSwift

protocol NotLoggedViewModelInput {
  func signInButtonPressed()
  func signUpButtonPressed()
}

protocol NotLoggedViewModelType {
  var input: NotLoggedViewModelInput { get }
}
