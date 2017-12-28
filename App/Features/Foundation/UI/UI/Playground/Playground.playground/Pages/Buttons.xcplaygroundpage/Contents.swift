import UIKit
import PlaygroundSupport
import UI
/*:
 # Full Width Button
 */
let fullWidthButton = FullWidthButton(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 56)))
fullWidthButton.setTitle("Restart".uppercased(), for: .normal)
fullWidthButton.layoutIfNeeded()

PlaygroundPage.current.liveView = fullWidthButton // Insert the button you want to interact with
