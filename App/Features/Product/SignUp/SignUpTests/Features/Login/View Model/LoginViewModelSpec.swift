import XCTest
import Core
import Application
import RxSwift
import RxTest
import RxCocoa
@testable import SignUp

final class LoginViewModelSpec: XCTestCase {

  private var sut: LoginViewModelType!
  private let scheduler = TestScheduler(initialClock: 0)
  
  override func setUp() {
    super.setUp()
    sut = LoginViewModel(authenticate: Authenticate())
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func test_viewmodel_initial_state_is_correct() {
    XCTAssertEqual("", sut.output.username.value)
    XCTAssertEqual("", sut.output.password.value)
    XCTAssertEqual(.idle, sut.output.state.value)
    
    let signInEnabledObserver = scheduler.createObserver(Bool.self)
    let userInteractionDisabledObserver = scheduler.createObserver(Bool.self)

    _ = sut.output.signInEnabled.bind(to: signInEnabledObserver)
    _ = sut.output.userInteractionEnabled.bind(to: userInteractionDisabledObserver)
 
    XCTAssertEqual(signInEnabledObserver.events, [next(0, false)])
    XCTAssertEqual(userInteractionDisabledObserver.events, [next(0, true)])
  }
  
  func test_should_enable_signin_button_when_login_fields_are_correctly_filled() {
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signInEnabled.bind(to: signUpEnabledObserver)
    
    sut.output.username.value = "restart"
    sut.output.password.value = "1234567"
    
    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, true)
    ]
    XCTAssertEqual(signUpEnabledObserver.events, expectedValues)
  }
  
  func test_should_disable_signin_button_when_user_incorrectly_update_one_of_the_login_fields() {
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signInEnabled.bind(to: signUpEnabledObserver)
    
    sut.output.username.value = "restart"
    sut.output.password.value = "1234567"
    sut.output.username.value = "as"
    
    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, true),
      next(0, false)
    ]
    XCTAssertEqual(signUpEnabledObserver.events, expectedValues)
  }
  
  func test_should_re_enable_signin_button_when_login_fields_are_valid() {
    let signInEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signInEnabled.bind(to: signInEnabledObserver)
    
    sut.output.username.value = "restart"
    sut.output.password.value = "1234567"
    sut.output.username.value = "as"
    sut.output.username.value = "astro"
    
    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, true),
      next(0, false),
      next(0, true)
    ]
    XCTAssertEqual(signInEnabledObserver.events, expectedValues)
  }
}
