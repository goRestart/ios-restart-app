import XCTest
import Snap
@testable import Listing

final class ProductSelectorViewSpec: XCTestCase {

  func test_view_initial_state_is_valid() {
    let view = ProductSelectorView()
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
}
