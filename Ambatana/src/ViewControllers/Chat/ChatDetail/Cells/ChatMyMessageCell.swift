import UIKit
import LGComponents

final class ChatMyMessageCell: ChatBubbleCell, ReusableCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var disclosureImageView: UIImageView!
    @IBOutlet var marginRightConstraints: [NSLayoutConstraint]!
 
    override func setupUI() {
        super.setupUI()
        checkImageView.image = R.Asset.IconsButtons.icCheckSent.image
        disclosureImageView.image = R.Asset.IconsButtons.icDisclosureChat.image
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleView.backgroundColor = selected ? UIColor.chatMyBubbleBgColorSelected : UIColor.chatMyBubbleBgColor
    }
    
    override func setAccessibilityIds() {
        super.setAccessibilityIds()
        set(accessibilityId: .chatCellContainer(type: .myMessage))
    }
}
