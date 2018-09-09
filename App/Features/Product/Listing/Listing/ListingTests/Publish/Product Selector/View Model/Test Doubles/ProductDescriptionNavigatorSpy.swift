@testable import Listing

final class ProductDescriptionNavigatorSpy: ProductDescriptionNavigable {
  var navigateWasCalled = false
  
  func navigate() {
    navigateWasCalled = true
  }
}
