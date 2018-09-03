import XCTest
import Snap
@testable import UI

final class LargeButtonSpec: XCTestCase {
 
  func test_button_with_normal_state_is_valid() {
    let button = givenButton(named: "normal", for: .normal)
    expect(button).toMatchSnapshot(named: "normal_button")
  }
  
  func test_button_with_highlighted_state_is_valid() {
    let button = givenButton(named: "highlighted", for: .highlighted)
    expect(button).toMatchSnapshot(named: "highlighted_button")
  }
  
  func test_button_with_normal_state_type_alt_is_valid() {
    let button = givenButton(named: "normal alt", type: .alt, for: .normal)
    expect(button).toMatchSnapshot(named: "normal_alt_button")
  }
  
  func test_button_with_highlighted_state_alt_is_valid() {
    let button = givenButton(named: "highlighted alt", type: .alt, for: .highlighted)
    expect(button).toMatchSnapshot(named: "highlighted_alt_button")
  }
 
  private func givenButton(named: String, type: LargeButtonType = .normal, for state: UIControl.State) -> LargeButton {
    let button = LargeButton(frame: CGRect(origin: .zero, size: CGSize(width: 280, height: 48)))
    button.type = type
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

