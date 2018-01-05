import XCTest
import Snap
import Domain
@testable import SignUp

final class SignUpViewSpec: XCTestCase {
 
  func test_view_initial_state_is_valid() {
    let view = SignUpView()
    view.signUpButton.isEnabled = false
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8])
  }
  
  func test_view_when_username_is_invalid() {
    let view = SignUpView()
    view.set(.invalidUsername)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8])
  }
  
  func test_view_when_password_is_invalid() {
    let view = SignUpView()
    view.set(.invalidPassword)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8])
  }
  
  func test_view_when_email_is_invalid() {
    let view = SignUpView()
    view.set(.invalidEmail)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8])
  }
  
  func test_view_when_username_is_already_registered() {
    let view = SignUpView()
    view.set(.usernameIsAlreadyRegistered)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8])
  }
  
  func test_view_when_email_is_already_registered() {
    let view = SignUpView()
    view.set(.emailIsAlreadyRegistered)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8])
  }
}
