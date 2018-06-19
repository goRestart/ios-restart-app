import Foundation
import LGComponents
import Lottie

class ChatInterlocutorIsTypingCell: UITableViewCell, ReusableCell {
    
    private let bubbleView = UIView()
    private let animationView = LOTAnimationView(name: "lottie_chat_typing_animation")

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = .clear
        bubbleView.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        bubbleView.layer.shouldRasterize = true
        bubbleView.layer.rasterizationScale = UIScreen.main.scale
        bubbleView.backgroundColor = UIColor.chatOthersBubbleBgColor
        contentView.addSubview(bubbleView)
        bubbleView.layout(with: contentView).leading(by: 16).top().bottom(by: -4)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(animationView)
        animationView.layout(with: bubbleView).fill()
        animationView.loopAnimation = true
        animationView.play()
    }
}
