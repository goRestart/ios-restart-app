import XCTest
import RxSwift
import RxTest
@testable import Listing

final class ProductDescriptionViewModelSpec: XCTestCase {
  
  private var sut: ProductDescriptionViewModelType!
  private var productDraft: ProductDraftSpy!
  private var productPriceNavigator: ProductPriceNavigatorSpy!
  private let scheduler = TestScheduler(initialClock: 0)
  private let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    productDraft = ProductDraftSpy()
    productPriceNavigator = ProductPriceNavigatorSpy()
    sut = ProductDescriptionViewModel(
      productDraft: productDraft,
      productPriceNavigator: productPriceNavigator
    )
  }
  
  func test_view_model_initial_state() {
    let description = givenDescription()
    let nextStepEnabled = givenNextStepEnabled()
    
    sut.output.description
      .drive(description)
      .disposed(by: bag)
    
    sut.output.nextStepEnabled
      .drive(nextStepEnabled)
      .disposed(by: bag)
    
    XCTAssertEqual(description.events, [.next(0, "")])
    XCTAssertEqual(nextStepEnabled.events, [.next(0, false)])
  }
  
  func test_should_retrieve_stored_description_when_view_appeared() {
    let description = givenDescription()
    
    sut.output.description
      .drive(description)
      .disposed(by: bag)
    
    productDraft.givenProductDraftIsComplete()
    
    sut.input.viewWillAppear()
    
    let expectedEvents: [Recorded<Event<String>>] = [
      .next(0, ""),
      .next(0, "Best game")
    ]
    
    XCTAssertEqual(description.events, expectedEvents)
  }
  
  func test_should_update_description_when_view_changed() {
    let description = givenDescription()
    
    sut.output.description
      .drive(description)
      .disposed(by: bag)
    
    sut.input.onChange(description: "new description")
    
    let expectedEvents: [Recorded<Event<String>>] = [
      .next(0, ""),
      .next(0, "new description")
    ]
    
    XCTAssertEqual(description.events, expectedEvents)
  }
  
  func test_save_description_when_next_step_is_pressed() {
    sut.input.onNextStepPressed()

    XCTAssertTrue(productDraft.saveDescriptionWasCalled)
  }
  
  func test_should_navigate_to_next_step_when_next_step_is_pressed() {
    sut.input.onNextStepPressed()
    
    XCTAssertTrue(productPriceNavigator.navigateWasCalled)
  }
  
  private func givenDescription() -> TestableObserver<String> {
    return scheduler.createObserver(String.self)
  }
  
  private func givenNextStepEnabled() -> TestableObserver<Bool> {
    return scheduler.createObserver(Bool.self)
  }
}
