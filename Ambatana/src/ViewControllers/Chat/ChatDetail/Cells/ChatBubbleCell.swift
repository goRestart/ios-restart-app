import Foundation
import LGComponents

class ChatBubbleCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
        setAccessibilityIds()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatBubbleCell.menuControllerWillHide(_:)),
            name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    func setupUI() {
        bubbleView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        messageLabel.font = UIFont.bigBodyFont
        dateLabel.font = UIFont.smallBodyFontLight
        
        messageLabel.textColor = UIColor.blackText
        dateLabel.textColor = UIColor.darkGrayText
        
        bubbleView.layer.shouldRasterize = true
        bubbleView.layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = .clear
    }
    
    func set(text: String) {
        switch text.emojiOnlyCount {
        case 1:
            messageLabel.font = UIFont.systemRegularFont(size: 49)
        case 2:
            messageLabel.font = UIFont.systemRegularFont(size: 37)
        case 3:
            messageLabel.font = UIFont.systemRegularFont(size: 27)
        default:
            messageLabel.font = UIFont.bigBodyFont
        }
        messageLabel.text = text
    }
    
    @objc func menuControllerWillHide(_ notification: Notification) {
        setSelected(false, animated: true)
    }
    
    func resetUI() {}
    
    func setAccessibilityIds() {
        messageLabel.set(accessibilityId: .chatCellMessageLabel)
        dateLabel.set(accessibilityId: .chatCellDateLabel)
    }
}
