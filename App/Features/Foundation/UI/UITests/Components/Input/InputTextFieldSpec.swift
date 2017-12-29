import XCTest
import Snap
@testable import UI

final class InputTextFieldSpec: XCTestCase {

  func test_input_with_normal_state_is_valid() {
    let textField = givenInput()
    expect(textField).toMatchSnapshot(named: "input_normal")
  }

  func test_input_with_placeholder_is_valid() {
    let textField = givenInput()
    textField.input.placeholder = "Restart"
    
    expect(textField).toMatchSnapshot(named: "input_placeholder")
  }
  
  func test_input_with_text_is_valid() {
    let textField = givenInput()
    textField.input.text = "Input text"
    
    expect(textField).toMatchSnapshot(named: "input_text")
  }
  
  func test_input_on_first_responder_is_valid() {
    let textField = givenInput()
    textField.input.placeholder = "Restart"
    textField.becomeFirstResponder()
    
    expect(textField).toMatchSnapshot(named: "input_on_first_responder")
  }
  
  func test_input_on_first_responder_with_text_is_valid() {
    let textField = givenInput()
    textField.input.text = "Input text"
    textField.becomeFirstResponder()
    
    expect(textField).toMatchSnapshot(named: "input_on_first_responder_with_text")
  }
  
  func test_input_with_title_is_valid() {
    let textField = givenInput()
    textField.title = "Title"
    
    expect(textField).toMatchSnapshot(named: "input_title")
  }
  
  func test_input_with_title_and_placeholder_is_valid() {
    let textField = givenInput()
    textField.title = "Title"
    textField.input.placeholder = "Restart"
    
    expect(textField).toMatchSnapshot(named: "input_title_placeholder")
  }
  
  func test_input_errored_is_valid() {
    let textField = givenInput()
    textField.title = "Title"
    textField.input.text = "Error"
    textField.error = "Error message"
    
    expect(textField).toMatchSnapshot(named: "input_errored")
  }
  
  private func givenInput() -> InputTextField {
    let input = InputTextField(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 92)))
    input.layoutIfNeeded()
    return input
  }
}
