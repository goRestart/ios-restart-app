import UIKit
import LGComponents

private enum Layout {
    static let bigMargin: CGFloat = 12
    static let verticalMargin: CGFloat = 8
    static let horizontalMargin: CGFloat = 8
    static let iconsMargin: CGFloat = 8
    static let iconsHeight: CGFloat = 14
    static let verifyIconsWidth: CGFloat = 20
}

final class ChatOtherInfoCell: UITableViewCell, ReusableCell {
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = ChatBubbleLayout.cornerRadius
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.backgroundColor = .chatOthersBubbleBgColorWhite
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.verticalMargin
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackText
        label.font = .systemRegularFont(size: 16)
        return label
    }()
    
    private let ratingView = RatingView(layout: .mini)
    
    private let verificationView: ChatOtherInfoVerificationView = {
        let verificationView = ChatOtherInfoVerificationView()
        verificationView.isHidden = true
        return verificationView
    }()
    
    private let locationView: ChatOtherInfoLocationView = {
        let locationView = ChatOtherInfoLocationView()
        locationView.isHidden = true
        return locationView
    }()
    
    private let assistantView: ChatOtherInfoAssistantView = {
        let assistantView = ChatOtherInfoAssistantView()
        assistantView.isHidden = true
        return assistantView
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Public

    func set(name: String?) {
        nameLabel.text = name
    }

    func set(rating: Float?) {
        ratingView.setupValue(rating: rating ?? 0)
    }
    
    func setupVerifiedInfo(facebook: Bool, google: Bool, email: Bool) {
        let shouldShowVerification = facebook || google || email
        
        guard shouldShowVerification else {
            verificationView.isHidden = true
            return
        }
        verificationView.configure(with: facebook, google: google, email: email)
        verificationView.isHidden = false
    }

    func setupLocation(_ location: String?) {
        guard let location = location, !location.isEmpty else { return }
        locationView.isHidden = false
        locationView.location = location
    }
    
    func setupLetgoAssistantInfo() {
        ratingView.isHidden = true
        verificationView.isHidden = true
        
        if !stackView.subviews.contains(assistantView) {
            stackView.insertArrangedSubview(assistantView, at: 1)
        }
        assistantView.isHidden = false
    }

    func set(bubbleBackgroundColor: UIColor?) {
        bubbleView.backgroundColor = bubbleBackgroundColor
    }
}

// MARK: - Private

fileprivate extension ChatOtherInfoCell {
    fileprivate func setupUI() {
        addSubviewsForAutoLayout([bubbleView])
        bubbleView.addSubviewForAutoLayout(stackView)
    
        let ratingStackView = UIStackView(arrangedSubviews: [ratingView, UIView()])
  
        stackView.addArrangedSubviews([
            nameLabel, ratingStackView, verificationView, locationView
        ])
    }
 
    fileprivate func setupConstraints() {
        let bubbleViewConstraints = [
            bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ChatBubbleLayout.margin),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -ChatBubbleLayout.margin),
            bubbleView.topAnchor.constraint(equalTo: topAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ChatBubbleLayout.margin),
        ]
        bubbleViewConstraints.activate()
        
        let stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: ChatBubbleLayout.bigMargin),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -ChatBubbleLayout.margin),
            stackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: ChatBubbleLayout.margin),
            stackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ChatBubbleLayout.margin)
        ]
        stackViewConstraints.activate()
    }
    
    fileprivate func setAccessibilityIds() {
        set(accessibilityId: .chatOtherInfoCellContainer)
        nameLabel.set(accessibilityId: .chatOtherInfoCellNameLabel)
    }
}
