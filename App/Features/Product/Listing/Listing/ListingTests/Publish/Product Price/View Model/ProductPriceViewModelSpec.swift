import XCTest
import RxSwift
import RxTest
@testable import Listing

final class ProductPriceViewModelSpec: XCTestCase {
  
  private var sut: ProductPriceViewModelType!
  private var productDraft: ProductDraftSpy!
  private var productExtrasNavigator: ProductExtrasNavigatorSpy!
  private let scheduler = TestScheduler(initialClock: 0)
  private let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    productDraft = ProductDraftSpy()
    productExtrasNavigator = ProductExtrasNavigatorSpy()
    sut = ProductPriceViewModel(
      productDraft: productDraft,
      productExtrasNavigator: productExtrasNavigator
    )
  }
  
  func test_view_model_initial_state() {
    let price = givenPrice()
    let nextStepEnabled = givenNextStepEnabled()
    
    sut.output.price
      .drive(price)
      .disposed(by: bag)
    
    sut.output.nextStepEnabled
      .drive(nextStepEnabled)
      .disposed(by: bag)
    
    XCTAssertEqual(price.events, [.next(0, "")])
    XCTAssertEqual(nextStepEnabled.events, [.next(0, false)])
  }
  
  func test_should_retrieve_stored_price_when_view_appeared() {
    let price = givenPrice()
    
    sut.output.price
      .drive(price)
      .disposed(by: bag)
    
    productDraft.givenProductDraftIsComplete()
    
    sut.input.viewWillAppear()
    
    let expectedEvents: [Recorded<Event<String>>] = [
      .next(0, ""),
      .next(0, "50.0")
    ]
    
    XCTAssertEqual(price.events, expectedEvents)
  }
  
  func test_should_update_price_when_view_changed() {
    let price = givenPrice()
    
    sut.output.price
      .drive(price)
      .disposed(by: bag)
    
    sut.input.onChange(price: "50")
    
    let expectedEvents: [Recorded<Event<String>>] = [
      .next(0, ""),
      .next(0, "50")
    ]
    
    XCTAssertEqual(price.events, expectedEvents)
  }
  
  func test_save_price_when_next_step_is_pressed() {
    sut.input.onNextStepPressed()
    
    XCTAssertTrue(productDraft.savePriceWasCalled)
  }
  
  func test_should_navigate_to_next_step_when_next_step_is_pressed() {
    sut.input.onNextStepPressed()
    
    XCTAssertTrue(productExtrasNavigator.navigateWasCalled)
  }
  
  private func givenPrice() -> TestableObserver<String> {
    return scheduler.createObserver(String.self)
  }
  
  private func givenNextStepEnabled() -> TestableObserver<Bool> {
    return scheduler.createObserver(Bool.self)
  }
}
