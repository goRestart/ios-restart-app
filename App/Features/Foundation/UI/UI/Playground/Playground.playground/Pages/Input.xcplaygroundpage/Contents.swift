import UIKit
import PlaygroundSupport
import UI
/*:
 # InputTextField
 */
let textField = InputTextField(frame: CGRect(origin: .zero, size: CGSize(width: 343, height: 100)))
textField.backgroundColor = .white

textField.input.placeholder = "Restart"
textField.layoutIfNeeded()

PlaygroundPage.current.liveView = textField // Insert the input you want to interact with
