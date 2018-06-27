import UIKit
import LGComponents

class ChatAskPhoneNumberCell: ChatBubbleCell, ReusableCell {

    var buttonAction: (() -> Void)?
    @IBOutlet weak var leavePhoneNumberButton: LetgoButton!

    @IBAction func leavePhoneNumberPressed() {
        buttonAction?()
    }
    
    override func setAccessibilityIds() {
        super.setAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .askPhoneNumber))
    }
}
