import XCTest
import Snap
@testable import UI

final class AddPhotoButtonSpec: XCTestCase {

  func test_add_photo_button_with_normal_state_is_valid() {
    let button = givenButton()
    expect(button).toMatchSnapshot(named: "add_photo_button_notmal_state")
  }

  private func givenButton() -> AddPhotoButton {
    let button = AddPhotoButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 80)))
    return button
  }
}

