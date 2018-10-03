@testable import Data

final class AuthTokenStorageMock: AuthTokenStorage {
  var storeWasCalled = false
  var getWasCalled = false
  var clearWasCalled = false
  
  var authToken: AuthToken?
  
  func store(_ authToken: AuthToken) throws {
    storeWasCalled = true
  }
  
  func get() -> AuthToken? {
    getWasCalled = true
    return authToken
  }
  
  func clear() {
    clearWasCalled = true
  }
}

// MARK: - Helpers

extension AuthTokenStorageMock {
  func givenAuthTokenIsStored() {
    authToken = AuthToken(
      token: "token"
    )
  }
}
