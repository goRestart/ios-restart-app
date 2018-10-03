import XCTest
@testable import Data

final class AuthTokenPluginSpec: XCTestCase {
  
  private var sut: AuthTokenPlugin!
  private var authTokenStorage: AuthTokenStorageMock!
  private var target: DummyTargetType!
  
  override func setUp() {
    super.setUp()
    
    authTokenStorage = AuthTokenStorageMock()
    target = DummyTargetType()
    sut = AuthTokenPlugin(
      authTokenStorage: authTokenStorage
    )
  }
  
  func test_should_add_auth_token_if_its_stored() {
    authTokenStorage.givenAuthTokenIsStored()
    
    let request = URLRequest(url: URL(string: "http://google.es")!)
    let authenthicatedRequest = sut.prepare(request, target: target)
    
    let expectedToken = "Bearer token"
    let authorizationHeader = authenthicatedRequest.value(forHTTPHeaderField: "authorization")
    
    XCTAssertEqual(authorizationHeader, expectedToken)
  }
  
  func test_should_not_add_auth_token_if_token_its_not_stored() {
    let request = URLRequest(url: URL(string: "http://google.es")!)
    let authenthicatedRequest = sut.prepare(request, target: target)

    let authorizationHeader = authenthicatedRequest.value(forHTTPHeaderField: "authorization")
    
    XCTAssertNil(authorizationHeader)
  }
}
