@testable import Listing

final class ProductExtrasNavigatorSpy: ProductExtrasNavigable {
  var navigateWasCalled = false
  
  func navigate() {
    navigateWasCalled = true
  }
}
