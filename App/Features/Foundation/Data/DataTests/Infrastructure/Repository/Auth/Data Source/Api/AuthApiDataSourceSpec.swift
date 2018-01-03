import XCTest
import Moya
import OHHTTPStubs
import RxSwift
import RxBlocking
import Domain
@testable import Data

final class AuthApiDataSourceSpec: XCTestCase {
  
  private var sut: AuthApiDataSource!
  private var provider: MoyaProvider<AuthService>!
  
  override func setUp() {
    super.setUp()
    provider = MoyaProvider()
    sut = AuthApiDataSource(
      provider: provider,
      errorAdapter: AuthenticateErrorAdapter()
    )
  }
  
  override func tearDown() {
    provider = nil
    sut = nil
    OHHTTPStubs.removeAllStubs()
    super.tearDown()
  }
  
  func test_should_authenticate_if_credentials_are_correct() throws {
    givenEndpointResponseWithValidCredentials()
    
    XCTAssertNoThrow(try sut.authenticate(with: credentials).toBlocking().single())
  }
  
  func test_should_throw_error_if_credentials_are_invalid() throws {
    givenEndpointResponseWithInvalidCredentials()
    
    XCTAssertThrowsError(try sut.authenticate(with: credentials).toBlocking().single(), "") { error in
      XCTAssertEqual(.invalidCredentials, error as? AuthError)
    }
  }
}

// MARK: - Helpers

extension AuthApiDataSourceSpec {
  private var credentials: BasicCredentials {
    return BasicCredentials(
      username: "username",
      password: "password"
    )
  }
  
  private func givenEndpointResponseWithInvalidCredentials() {
    stub(condition: isPath("/login")) { request in
      return OHHTTPStubsResponse(jsonObject: Fixture.load("auth.unauthorized"), statusCode: 401, headers: nil)
    }
  }
  
  private func givenEndpointResponseWithValidCredentials() {
    stub(condition: isPath("/login")) { request in
      return OHHTTPStubsResponse(jsonObject: Fixture.load("auth.ok"), statusCode: 200, headers: nil)
    }
  }
}
