@testable import Listing

final class ProductPriceNavigatorSpy: ProductPriceNavigable {
  var navigateWasCalled = false
  
  func navigate() {
    navigateWasCalled = true 
  }
}
