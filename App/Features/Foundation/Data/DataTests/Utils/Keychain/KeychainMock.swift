@testable import Data

final class KeychainMock: Keychaneable {
  var getWasCalled = false
  var setWasCalled = false
  var removeWasCalled = false
  
  var getString: String? = nil

  func get(_ key: String) throws -> String? {
    getWasCalled = true
    return getString
  }
  
  func set(_ value: String, key: String) throws {
    setWasCalled = true
  }
  
  func remove(_ key: String) throws {
    removeWasCalled = true
  }
}
