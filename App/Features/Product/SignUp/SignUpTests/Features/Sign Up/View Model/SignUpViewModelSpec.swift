import XCTest
import Core
import Application
import RxSwift
import RxTest
import RxCocoa
import Domain
@testable import SignUp

final class SignUpViewModelSpec: XCTestCase {
  
  private var sut: SignUpViewModelType!
  private let emailValidator = EmailValidator()
  private var registerUser: RegisterUserStub!
  private let scheduler = TestScheduler(initialClock: 0)
  
  override func setUp() {
    super.setUp()
    registerUser = RegisterUserStub()
    sut = SignUpViewModel(
      emailValidator: emailValidator,
      registerUser: registerUser
    )
  }
  
  override func tearDown() {
    registerUser = nil
    sut = nil
    super.tearDown()
  }
  
  func test_viewmodel_initial_state_is_correct() throws {
    XCTAssertEqual("", try sut.output.username.value())
    XCTAssertEqual("", try sut.output.email.value())
    XCTAssertEqual("", try sut.output.password.value())
    XCTAssertEqual(.idle, try sut.output.state.value())
    
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    let userInteractionDisabledObserver = scheduler.createObserver(Bool.self)
    
    _ = sut.output.signUpEnabled.bind(to: signUpEnabledObserver)
    _ = sut.output.userInteractionEnabled.bind(to: userInteractionDisabledObserver)
    
    XCTAssertEqual(signUpEnabledObserver.events, [next(0, false)])
    XCTAssertEqual(userInteractionDisabledObserver.events, [next(0, true)])
  }
  
  func test_should_disable_signup_button_when_email_is_invalid() {
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signUpEnabled.bind(to: signUpEnabledObserver)
    
    sut.output.username.onNext("restart")
    sut.output.email.onNext("invalid@.com")
    sut.output.password.onNext("1234567")
    
    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, false),
      next(0, false)
    ]
    
    XCTAssertEqual(signUpEnabledObserver.events, expectedValues)
  }
  
  func test_should_enable_signup_button_when_register_fields_are_correctly_filled() {
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signUpEnabled.bind(to: signUpEnabledObserver)
    
    sut.output.username.onNext("restart")
    sut.output.email.onNext("test@test.com")
    sut.output.password.onNext("1234567")

    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, false),
      next(0, true)
    ]
    
    XCTAssertEqual(signUpEnabledObserver.events, expectedValues)
  }
  
  func test_should_disable_signup_button_when_user_incorrectly_update_one_of_the_register_fields() {
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signUpEnabled.bind(to: signUpEnabledObserver)
    
    sut.output.username.onNext("restart")
    sut.output.email.onNext("test@test.com")
    sut.output.password.onNext("1234567")
    sut.output.username.onNext("as")
    
    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, false),
      next(0, true),
      next(0, false)
    ]
    
    XCTAssertEqual(signUpEnabledObserver.events, expectedValues)
  }
  
  func test_should_re_enable_signup_button_when_register_fields_are_valid() {
    let signUpEnabledObserver = scheduler.createObserver(Bool.self)
    _ = sut.output.signUpEnabled.bind(to: signUpEnabledObserver)
    
    sut.output.username.onNext("restart")
    sut.output.email.onNext("test@test.com")
    sut.output.password.onNext("1234567")
    sut.output.username.onNext("as")
    sut.output.username.onNext("astro")
    
    let expectedValues = [
      next(0, false),
      next(0, false),
      next(0, false),
      next(0, true),
      next(0, false),
      next(0, true)
    ]
    
    XCTAssertEqual(signUpEnabledObserver.events, expectedValues)
  }
  
  func test_should_set_correct_signup_state_if_signup_fails() {
    let signUpState = scheduler.createObserver(SignUpState.self)
    _ = sut.output.state.asObservable().bind(to: signUpState)
  
    sut.output.username.onNext("restart")
    sut.output.email.onNext("test@test.com")
    sut.output.password.onNext("1234567")
    
    registerUser.responseError = .invalidUsername
    
    sut.input.signInButtonPressed()

    let expectedStateValues = [
      next(0, SignUpState.idle),
      next(0, SignUpState.loading),
      next(0, SignUpState.idle),
    ]

    XCTAssertEqual(signUpState.events, expectedStateValues)
  }
}
