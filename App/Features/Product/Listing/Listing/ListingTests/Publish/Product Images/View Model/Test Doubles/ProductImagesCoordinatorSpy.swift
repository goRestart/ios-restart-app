@testable import Listing

final class ProductImagesCoordinatorSpy: ProductImagesCoordinable {
  var openDescriptionWasCalled = false
  var openCameraWasCalled = false
  
  func openDescription() {
    openDescriptionWasCalled = true
  }
  
  func openCamera(with index: Int) {
    openCameraWasCalled = true
  }
}
