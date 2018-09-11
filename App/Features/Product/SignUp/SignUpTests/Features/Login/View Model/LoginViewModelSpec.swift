import XCTest
import Core
import Application
import RxSwift
import RxTest
import RxCocoa
@testable import SignUp

final class LoginViewModelSpec: XCTestCase {

  private var sut: LoginViewModelType!
  private var authenticate: AuthenticateStub!
  private let scheduler = TestScheduler(initialClock: 0)
  private let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    authenticate = AuthenticateStub()
    sut = LoginViewModel(
      authenticate: authenticate
    )
  }
  
  func test_viewModel_initial_state_is_correct() {
    let state = givenState()
    let userInteractionEnabled = givenUserInteractionEnabled()
    let signInEnabled = givenSignInEnabled()

    sut.output.state.drive(state).disposed(by: bag)
    sut.output.userInteractionEnabled.drive(userInteractionEnabled).disposed(by: bag)
    sut.output.signInEnabled.drive(signInEnabled).disposed(by: bag)
    
    XCTAssertEqual(state.events, [Recorded.next(0, .idle)])
    XCTAssertEqual(userInteractionEnabled.events, [Recorded.next(0, true)])
    XCTAssertEqual(signInEnabled.events, [Recorded.next(0, false)])
  }
  
  func test_should_enable_signIn_when_login_fields_are_filled_correctly() {
    let signInEnabled = givenSignInEnabled()

    sut.output.signInEnabled
      .drive(signInEnabled)
      .disposed(by: bag)

    sut.input.onChange(username: "skyweb07")
    sut.input.onChange(password: "password")

    let expectedEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(0, false),
      .next(0, true),
    ]
    
    XCTAssertEqual(signInEnabled.events, expectedEvents)
  }
  
  func test_should_not_enable_sign_if_username_lenght_is_incorrect() {
    let signInEnabled = givenSignInEnabled()
    
    sut.output.signInEnabled
      .drive(signInEnabled)
      .disposed(by: bag)
    
    sut.input.onChange(username: "el")
    sut.input.onChange(password: "password")
    
    let expectedEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(0, false),
      .next(0, false),
    ]
    
    XCTAssertEqual(signInEnabled.events, expectedEvents)
  }
  
  func test_should_not_enable_sign_if_password_lenght_is_incorrect() {
    let signInEnabled = givenSignInEnabled()
    
    sut.output.signInEnabled
      .drive(signInEnabled)
      .disposed(by: bag)
    
    sut.input.onChange(username: "skyweb07")
    sut.input.onChange(password: "123")
    
    let expectedEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(0, false),
      .next(0, false),
    ]
    
    XCTAssertEqual(signInEnabled.events, expectedEvents)
  }
  
  func test_should_set_loading_state_when_sign_button_is_pressed() {
    let state = givenState()
    
    sut.output.state
      .drive(state)
      .disposed(by: bag)
    
    sut.input.onChange(username: "skyweb07")
    sut.input.onChange(password: "password")
    sut.input.signUpButtonPressed()
    
    let expectedEvents: [Recorded<Event<LoginState>>] = [
      .next(0, .idle),
      .next(0, .loading),
    ]
    
    XCTAssertEqual(state.events, expectedEvents)
  }

  func test_should_set_idle_state_if_login_failed() {
    let state = givenState()
    
    sut.output.state
      .drive(state)
      .disposed(by: bag)
    
    authenticate.responseError = .invalidCredentials
    
    sut.input.onChange(username: "skyweb07")
    sut.input.onChange(password: "password")
    sut.input.signUpButtonPressed()
    
    let expectedEvents: [Recorded<Event<LoginState>>] = [
      .next(0, .idle),
      .next(0, .loading),
      .next(0, .idle)
    ]
    
    XCTAssertEqual(state.events, expectedEvents)
  }
  
  // MARK: - Observers
  
  private func givenState() -> TestableObserver<LoginState> {
    return scheduler.createObserver(LoginState.self)
  }
  
  private func givenUserInteractionEnabled() -> TestableObserver<Bool> {
    return scheduler.createObserver(Bool.self)
  }
  
  private func givenSignInEnabled() -> TestableObserver<Bool> {
    return scheduler.createObserver(Bool.self)
  }
}
