import XCTest
import Moya
import OHHTTPStubs
import RxSwift
import RxBlocking
import Domain
@testable import Data

final class UserApiDataSourceSpec: XCTestCase {
  
  private var sut: UserApiDataSource!
  private var provider: MoyaProvider<UserService>!
  
  override func setUp() {
    super.setUp()
    provider = MoyaProvider()
    sut = UserApiDataSource(
      provider: provider,
      errorAdapter: RegisterUserErrorAdapter()
    )
  }
  
  override func tearDown() {
    provider = nil
    sut = nil
    OHHTTPStubs.removeAllStubs()
    super.tearDown()
  }
  
  func test_should_register_user_if_credentials_are_correct() throws {
    givenEndpointResponseWithUserCreated()
    
    XCTAssertNoThrow(sut.register(with: credentials).toBlocking())
  }
  
  func test_should_throw_error_if_username_is_already_registered() throws {
    givenEndpointResponse(with: .usernameIsAlreadyRegistered)

    XCTAssertThrowsError(try sut.register(with: credentials).toBlocking().single(), "") { error in
      XCTAssertEqual(.usernameIsAlreadyRegistered, error as? RegisterUserError)
    }
  }
  
  func test_should_throw_error_if_username_is_invalid() throws {
    givenEndpointResponse(with: .invalidUsername)
    
    XCTAssertThrowsError(try sut.register(with: credentials).toBlocking().single(), "") { error in
      XCTAssertEqual(.invalidUsername, error as? RegisterUserError)
    }
  }
  
  func test_should_throw_error_if_email_is_already_registered() throws {
    givenEndpointResponse(with: .emailIsAlreadyRegistered)
    
    XCTAssertThrowsError(try sut.register(with: credentials).toBlocking().single(), "") { error in
      XCTAssertEqual(.emailIsAlreadyRegistered, error as? RegisterUserError)
    }
  }
  
  func test_should_throw_error_if_email_is_invalid() throws {
    givenEndpointResponse(with: .invalidEmail)
    
    XCTAssertThrowsError(try sut.register(with: credentials).toBlocking().single(), "") { error in
      XCTAssertEqual(.invalidEmail, error as? RegisterUserError)
    }
  }
  
  func test_should_throw_error_if_password_is_invalid() throws {
    givenEndpointResponse(with: .invalidPassword)
    
    XCTAssertThrowsError(try sut.register(with: credentials).toBlocking().single(), "") { error in
      XCTAssertEqual(.invalidPassword, error as? RegisterUserError)
    }
  }
}

// MARK: - Helpers

extension UserApiDataSourceSpec {
  private var credentials: UserCredentials {
    return UserCredentials(
      username: "username",
      email: "test@test.com",
      password: "password"
    )
  }

  private func givenEndpointResponse(with error: RegisterUserError) {
    stub(condition: isPath("/")) { request in
      return OHHTTPStubsResponse(jsonObject: self.json(for: error), statusCode: 409, headers: nil)
    }
  }
 
  private func json(for error: RegisterUserError) -> Any {
    switch error {
    case .invalidUsername:
      return Fixture.load("register.invalid_username.conflict")
    case .invalidPassword:
      return Fixture.load("register.invalid_password.conflict")
    case .invalidEmail:
      return Fixture.load("register.invalid_email.conflict")
    case .usernameIsAlreadyRegistered:
      return Fixture.load("register.username_already_registered.conflict")
    case .emailIsAlreadyRegistered:
      return Fixture.load("register.email_already_registered.conflict")
    }
  }

  private func givenEndpointResponseWithUserCreated() {
    stub(condition: isPath("/")) { request in
      return OHHTTPStubsResponse(jsonObject: Fixture.load("register.ok"), statusCode: 201, headers: nil)
    }
  }
}


