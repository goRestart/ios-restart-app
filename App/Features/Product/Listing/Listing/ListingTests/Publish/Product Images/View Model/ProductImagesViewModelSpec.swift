import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import Listing

final class ProductImagesViewModelSpec: XCTestCase {
  
  private var sut: ProductImagesViewModelType!
  private let scheduler = TestScheduler(initialClock: 0)
  private let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    sut = ProductImagesViewModel()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func test_viewModel_initial_state_is_correct() {
    let nextStepIsEnabled = givenNextStepIsEnabled()
    
    sut.output.nextStepEnabled.drive(nextStepIsEnabled).disposed(by: bag)
    
    XCTAssertEqual(nextStepIsEnabled.events, [Recorded.next(0, false)])
  }
  
  func test_should_enable_next_step_if_there_are_at_least_one_image_added() {
    let nextStepIsEnabled = givenNextStepIsEnabled()
    
    sut.output.nextStepEnabled.drive(nextStepIsEnabled).disposed(by: bag)
    
    let image = UIImage()
    sut.input.onAdd(image: image)
    
    let expectedEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(0, true)
    ]
    
    XCTAssertEqual(nextStepIsEnabled.events, expectedEvents)
  }
  
  func test_should_disable_next_step_if_all_images_are_removed() {
    let nextStepIsEnabled = givenNextStepIsEnabled()
    
    sut.output.nextStepEnabled.drive(nextStepIsEnabled).disposed(by: bag)
    
    let image = UIImage()
    sut.input.onAdd(image: image)
    sut.input.onRemove(image: image)
    
    let expectedEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(0, true),
      .next(0, false)
    ]
    
    XCTAssertEqual(nextStepIsEnabled.events, expectedEvents)
  }
  
  // MARK: - Observers

  private func givenNextStepIsEnabled() -> TestableObserver<Bool> {
    return scheduler.createObserver(Bool.self)
  }
}
