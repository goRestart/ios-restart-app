import XCTest
import Snap
@testable import UI

final class FullWidthButtonSpec: XCTestCase {

  func test_button_with_normal_state_is_valid() {
    let button = givenButton(named: "normal", for: .normal)
    expect(button).toMatchSnapshot(named: "normal_button")
  }

  func test_button_with_highlighted_state_is_valid() {
    let button = givenButton(named: "highlighted", for: .highlighted)
    expect(button).toMatchSnapshot(named: "highlighted_button")
  }
  
  func test_button_with_disabled_state_is_valid() {
    let button = givenButton(named: "disabled", for: .disabled)
    expect(button).toMatchSnapshot(named: "disabled_button")
  }
  
  private func givenButton(named: String, for state: UIControl.State) -> FullWidthButton {
    let button = FullWidthButton(frame: CGRect(origin: .zero, size: CGSize(width: 375, height: 56)))
    button.setTitle(named.uppercased(), for: state)
    switch state {
    case .highlighted:
      button.isHighlighted = true
    case .disabled:
      button.isEnabled = false
    default: break
    }
    button.layoutIfNeeded()
    return button
  }
}
