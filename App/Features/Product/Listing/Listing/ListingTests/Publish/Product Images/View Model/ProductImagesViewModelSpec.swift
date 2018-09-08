import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import Listing

final class ProductImagesViewModelSpec: XCTestCase {
  
  private var sut: ProductImagesViewModelType!
  private var productImagesCoordinator: ProductImagesCoordinatorSpy!
  private let scheduler = TestScheduler(initialClock: 0)
  private let bag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    productImagesCoordinator = ProductImagesCoordinatorSpy()
    sut = ProductImagesViewModel(
      productImagesCoordinator: productImagesCoordinator
    )
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
    sut.input.onAdd(image: image, with: 1)
    
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
    sut.input.onAdd(image: image, with: 1)
    sut.input.onRemoveImage(with: 1)
    
    let expectedEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(0, true),
      .next(0, false)
    ]
    
    XCTAssertEqual(nextStepIsEnabled.events, expectedEvents)
  }
  
  func test_should_open_camera_if_image_is_empty() {
    sut.input.onSelectButton(with: 1)
    
    XCTAssertTrue(productImagesCoordinator.openCameraWasCalled)
  }
  
  func test_should_send_image_removal_event_if_image_is_already_selected() {
    let imageIndexRemovalRelay = givenImageIndexRemovalRelay()
    
    sut.output.imageIndexShouldBeRemoved
      .drive(imageIndexRemovalRelay)
      .disposed(by: bag)
    
    let image = UIImage()
    
    sut.input.onAdd(image: image, with: 1)
    sut.input.onSelectButton(with: 1)
    
    let expectedEvents: [Recorded<Event<Int>>] = [
      .next(0, 1)
    ]
    
    XCTAssertEqual(imageIndexRemovalRelay.events, expectedEvents)
  }
  
  func test_should_open_description_if_next_button_is_pressed() {
    sut.input.onNextStepPressed()
    
    XCTAssertTrue(productImagesCoordinator.openDescriptionWasCalled)
  }
  
  // MARK: - Observers

  private func givenNextStepIsEnabled() -> TestableObserver<Bool> {
    return scheduler.createObserver(Bool.self)
  }
  
  private func givenImageIndexRemovalRelay() -> TestableObserver<Int> {
    return scheduler.createObserver(Int.self)
  }
}
