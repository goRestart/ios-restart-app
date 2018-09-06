import XCTest
import Snap
@testable import SignUp

final class SignUpViewSpec: XCTestCase {

  func test_view_initial_state_is_valid() {
    let view = SignUpView()
    view.rx.signUpButtonEnabled.onNext(false)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_view_when_username_is_invalid() {
    let view = SignUpView()
    view.rx.error.onNext(.invalidUsername)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_view_when_password_is_invalid() {
    let view = SignUpView()
    view.rx.error.onNext(.invalidPassword)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_view_when_email_is_invalid() {
    let view = SignUpView()
    view.rx.error.onNext(.invalidEmail)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_view_when_username_is_already_registered() {
    let view = SignUpView()
    view.rx.error.onNext(.usernameIsAlreadyRegistered)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_view_when_email_is_already_registered() {
    let view = SignUpView()
    view.rx.error.onNext(.emailIsAlreadyRegistered)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
}

