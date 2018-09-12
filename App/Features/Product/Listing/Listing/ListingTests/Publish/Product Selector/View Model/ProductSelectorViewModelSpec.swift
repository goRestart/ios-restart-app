import XCTest
import Domain
@testable import Listing

final class ProductSelectorViewModelSpec: XCTestCase {
  
  private var sut: ProductSelectorViewModelType!
  private var productDraft: ProductDraftSpy!
  private var productDescriptionNavigator: ProductDescriptionNavigatorSpy!
  
  override func setUp() {
    super.setUp()
    productDraft = ProductDraftSpy()
    productDescriptionNavigator = ProductDescriptionNavigatorSpy()
    sut = ProductSelectorViewModel(
      productDraft: productDraft,
      productDescriptionNavigator: productDescriptionNavigator
    )
  }

  func test_should_navigate_to_next_step_when_game_is_selected() {
    sut.input.onGameSelected(with: "mario", Identifier.make())
    
    XCTAssertTrue(productDescriptionNavigator.navigateWasCalled)
  }
  
  func test_should_save_product_selection_when_game_is_selected() {
    sut.input.onGameSelected(with: "mario", Identifier.make())
    
    XCTAssertTrue(productDraft.saveTitleWasCalled)
  }
}
