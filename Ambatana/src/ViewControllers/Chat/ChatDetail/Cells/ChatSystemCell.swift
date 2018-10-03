import Foundation
import LGComponents
import LGCoreKit

final class ChatSystemCell: UITableViewCell, ReusableCell {
    
    static let topBottomInsetForShadows: CGFloat = 4
    static let bottomMargin: CGFloat = Metrics.shortMargin
    
    private enum Layout {
        static let leftInset = ChatBubbleLayout.avatarSize + ChatBubbleLayout.margin*2
        static let minimumInteritemSpacing: CGFloat = 10.0
    }
    
    private enum LocalizedKey: String {
        case acceptedExpired = "communication_offer_accepted_expired"
        case pendingExpiring = "communication_offer_pending_expiring"
        case completedExpired = "communication_offer_completed_expired"
        case acceptedExpiring = "communication_offer_accepted_expiring"
        
        var localizeValue: String {
            switch self {
            case .acceptedExpired:
                return R.Strings.communicationOfferAcceptedExpired
            case .pendingExpiring:
                return R.Strings.communicationOfferPendingExpiring
            case .completedExpired:
                return R.Strings.communicationOfferCompletedExpired
            case .acceptedExpiring:
                return R.Strings.communicationOfferAcceptedExpiring
            }
        }
    }
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.cornerRadius = LGUIKitConstants.mediumCornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .chatSystemBubbleBgColor
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bigBodyFont
        label.textColor = UIColor.blackText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
    
    // MARK: Setup
    
    private func setupUI() {
        backgroundColor = .clear
    }
    
    private func setupConstraints() {
        contentView.addSubviewForAutoLayout(bubbleView)
        bubbleView.addSubviewForAutoLayout(messageLabel)
        NSLayoutConstraint.activate([
            bubbleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: Metrics.bigMargin),
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -Metrics.bigMargin),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ChatSystemCell.bottomMargin),
            ])
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Metrics.shortMargin),
            messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: Metrics.bigMargin),
            messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -Metrics.bigMargin),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Metrics.shortMargin),
            ])
    }
    
    func set(message: ChatMessageSystem) {
        if let localizedKey = LocalizedKey(rawValue: message.localizedKey) {
            messageLabel.text = localizedKey.localizeValue
        } else {
            messageLabel.text = message.localizedText
        }
    }
    
    private func setAccessibilityIds() {
        messageLabel.set(accessibilityId: .chatCellSystemLabel)
        set(accessibilityId: .chatCellContainer(type: .system))
    }
}
