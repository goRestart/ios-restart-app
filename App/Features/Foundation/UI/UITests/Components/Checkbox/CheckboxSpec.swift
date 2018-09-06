import XCTest
import Snap
@testable import UI

final class CheckboxSpec: XCTestCase {
  
  func test_checkbox_with_no_state_is_valid() {
    let checkbox = givenCheckboxWithNoState()
    expect(checkbox).toMatchSnapshot(named: "checkbox_with_no_state")
  }
  
  func test_checkbox_with_checked_state_is_valid() {
    let checkbox = givenCheckbox(checked: true)
    expect(checkbox).toMatchSnapshot(named: "checkbox_checked")
  }
  
  func test_checkbox_with_unchecked_state_is_valid() {
    let checkbox = givenCheckbox(checked: false)
    expect(checkbox).toMatchSnapshot(named: "checkbox_unchecked")
  }
  
  private func givenCheckbox(checked: Bool) -> Checkbox {
    let checkbox = Checkbox(
      frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24))
    )
    checkbox.isChecked = checked
    return checkbox
  }
  
  private func givenCheckboxWithNoState() -> Checkbox {
    return Checkbox(
      frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24))
    )
  }
}
