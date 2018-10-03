import XCTest
@testable import Data

final class AuthTokenKeychainStorageSpec: XCTestCase {
  
  private var sut: AuthTokenKeychainStorage!
  private var keychain: KeychainMock!
  
  override func setUp() {
    super.setUp()
 
    keychain = KeychainMock()
    sut = AuthTokenKeychainStorage(
      keychain: keychain
    )
  }
  
  func test_should_store_token_in_keychain() throws {
    givenTokenIsStored()
    
    XCTAssertEqual("token", keychain.setValue)
  }
  
  func test_should_get_token_if_its_stored_in_keychain() throws {
    givenTokenIsStored()
    
    XCTAssertNotNil(sut.get())
  }
  
  func test_should_clear_token() throws {
    givenTokenIsStored()
    
    sut.clear()
    
    XCTAssertTrue(keychain.removeWasCalled)
  }
  
  private func givenAuthToken() -> AuthToken {
    return AuthToken(token: "token")
  }
  
  private func givenTokenIsStored() {
    let token = givenAuthToken()
    try? sut.store(token)
  }
}
