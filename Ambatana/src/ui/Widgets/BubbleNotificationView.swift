//
//  BubbleNotification.swift
//  LetGo
//
//  Created by Dídac on 18/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct BubbleNotificationData {
    let tagGroup: String?
    let text: String
    let infoText: String?
    let action: UIAction?
    let iconURL: URL?
    let iconImage: UIImage?

    var hasIcon: Bool {
        return iconURL != nil || iconImage != nil
    }
    var hasInfo: Bool {
        guard let infoText = infoText else { return false }
        return !infoText.isEmpty
    }

    init(tagGroup: String? = nil, text: String, infoText: String? = nil, action: UIAction?,
         iconURL: URL? = nil, iconImage: UIImage? = nil) {
        self.tagGroup = tagGroup
        self.text = text
        self.infoText = infoText
        self.action = action
        self.iconURL = iconURL
        self.iconImage = iconImage
    }
}

protocol BubbleNotificationDelegate: class {
    func bubbleNotificationSwiped(_ notification: BubbleNotificationView)
    func bubbleNotificationTimedOut(_ notification: BubbleNotificationView)
    func bubbleNotificationActionPressed(_ notification: BubbleNotificationView)
}

final class BubbleNotificationView: UIView {

    enum Style {
        case dark
        case light
    }
    
    enum Alignment: Equatable {
        case top(offset: CGFloat)
        case bottom

        var initialBottomConstraintConstant: CGFloat {
            switch self {
            case .top:
                return 0
            case .bottom:
                return Metrics.screenHeight + BubbleNotificationView.initialHeight
            }
        }
        
        func getBottomConstraintConstant(height: CGFloat) -> CGFloat {
            switch self {
            case let .top(offset):
                return offset + height
            case .bottom:
                return BubbleNotificationView.statusBarHeight + height
            }
        }
        
        static func ==(lhs: BubbleNotificationView.Alignment, rhs: BubbleNotificationView.Alignment) -> Bool {
            switch (lhs, rhs) {
            case (.top(let lhs), .top(let rhs)):
                return lhs == rhs
            case (.bottom, .bottom):
                return true
            default:
                return false
            }
        }
    }
    
    static let initialHeight: CGFloat = 80

    static let buttonHeight: CGFloat = 30
    static let buttonMaxWidth: CGFloat = 150
    static let bubbleMargin: CGFloat = 10
    static let bubbleContentMargin: CGFloat = 15
    static let bubbleInternalMargins: CGFloat = 8
    static let statusBarHeight: CGFloat = 20
    static let iconDiameter: CGFloat = 46

    static let showAnimationTime: TimeInterval = 0.3
    static let closeAnimationTime: TimeInterval = 0.5

    weak var delegate: BubbleNotificationDelegate?

    private let containerView = UIView()
    private let leftIcon = UIImageView()
    private let textLabel = UILabel()
    private let infoTextLabel = UILabel()
    private let actionButton = LetgoButton()

    private var autoDismissTimer: Timer?

    var bottomConstraint = NSLayoutConstraint()

    let data: BubbleNotificationData
    private let style: Style
    private let alignment: Alignment
    
    var isBottomAligned: Bool {
        return alignment == .bottom
    }
    
    
    // - Lifecycle

    init(frame: CGRect,
         data: BubbleNotificationData,
         alignment: Alignment,
         style: Style) {
        self.data = data
        self.style = style
        self.alignment = alignment
        super.init(frame: frame)
        setupConstraints()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setupOnView(parentView: UIView) {
        bottomConstraint = bottomAnchor.constraint(equalTo: parentView.topAnchor, constant: alignment.initialBottomConstraintConstant)
        let constraints = [
            leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: BubbleNotificationView.bubbleMargin),
            rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -BubbleNotificationView.bubbleMargin),
            bottomConstraint
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func showBubble() {
        self.showBubble(autoDismissTime: nil)
    }
    
    func showBubble(autoDismissTime time: TimeInterval?) {
        // delay to let the setup build the view properly
        delay(0.1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bottomConstraint.constant = strongSelf.alignment.getBottomConstraintConstant(height: strongSelf.height)
            UIView.animate(withDuration: BubbleNotificationView.showAnimationTime) { strongSelf.superview?.layoutIfNeeded() }
        }

        if let dismissTime = time, dismissTime > 0 {
            let totalTime = BubbleNotificationView.showAnimationTime + dismissTime
            autoDismissTimer = Timer.scheduledTimer(timeInterval: totalTime, target: self,
                                                   selector: #selector(autoDismiss), userInfo: nil, repeats: false)
        }
    }

    func closeBubble() {
        guard superview != nil else { return } // Already closed
        bottomConstraint.constant = alignment.initialBottomConstraintConstant
        UIView.animate(withDuration: BubbleNotificationView.closeAnimationTime, animations: { [weak self] in
            self?.superview?.layoutIfNeeded()
        }, completion: { [weak self ] _ in
            self?.removeBubble()
        }) 
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if data.hasIcon {
            leftIcon.setRoundedCorners()
        }
    }


    // MARK : - Private methods

    private func setupUI() {
        cornerRadius = LGUIKitConstants.bigCornerRadius
        applyDefaultShadow()

        if data.hasIcon {
            leftIcon.clipsToBounds = true
            leftIcon.cornerRadius = BubbleNotificationView.iconDiameter/2
        }
        if let iconImage = data.iconImage {
            leftIcon.image = iconImage
        }
        if let iconURL = data.iconURL {
            leftIcon.lg_setImageWithURL(iconURL)
        }

        textLabel.numberOfLines = 2
        textLabel.minimumScaleFactor = 0.5
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.font = UIFont.mediumBodyFont
        textLabel.text = data.text

        if let infoText = data.infoText {
            infoTextLabel.numberOfLines = 2
            infoTextLabel.minimumScaleFactor = 0.5
            infoTextLabel.lineBreakMode = .byTruncatingTail
            infoTextLabel.textColor = UIColor.darkGrayText
            infoTextLabel.font = UIFont.smallBodyFont
            infoTextLabel.text = infoText
        }

        if let action = data.action {
            actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
            actionButton.titleLabel?.minimumScaleFactor = 0.6
            actionButton.setTitle(action.text, for: .normal)
            actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            actionButton.set(accessibilityId:  action.accessibilityId)
        }
        
        switch style {
        case .light:
            backgroundColor = .white
            textLabel.textColor = .blackText
            infoTextLabel.textColor = .darkGrayText
            actionButton.setStyle(.secondary(fontSize: .small, withBorder: true))
        case .dark:
            backgroundColor = .black
            textLabel.textColor = .white
            infoTextLabel.textColor = .white
            actionButton.setStyle(.pinkish(fontSize: .small, withBorder: true))
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeGesture.direction = .up
        self.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        self.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {

        let textsContainer = UIView()

        addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([leftIcon, textsContainer, actionButton])
        textsContainer.addSubviewsForAutoLayout([textLabel, infoTextLabel])

        var views = [String: Any]()
        views["container"] = containerView
        views["textsContainer"] = textsContainer
        views["icon"] = leftIcon
        views["label"] = textLabel
        views["infoLabel"] = infoTextLabel
        views["button"] = actionButton

        var metrics = [String: Any]()
        metrics["margin"] = BubbleNotificationView.bubbleContentMargin
        metrics["buttonWidth"] = CGFloat(data.action != nil ? BubbleNotificationView.buttonMaxWidth : 0)
        metrics["iconDiameter"] = CGFloat(data.hasIcon ? BubbleNotificationView.iconDiameter : 0)
        metrics["iconMargin"] = CGFloat(data.hasIcon ? BubbleNotificationView.bubbleInternalMargins : 0)
        metrics["infoLabelMargin"] = CGFloat(data.hasInfo ? 2 : 0)

        // container view
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[container]-margin-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[container]-margin-|",
            options: [], metrics: metrics, views: views))

        // image text label and button
        actionButton.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=0-[textsContainer]->=0-|",
            options: [], metrics: metrics, views: views))
        leftIcon.addConstraint(NSLayoutConstraint(item: leftIcon, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BubbleNotificationView.iconDiameter))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon(iconDiameter)]-iconMargin-[textsContainer]-[button(<=buttonWidth)]-0-|",
            options: [.alignAllCenterY], metrics: metrics, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=0-[icon(iconDiameter)]->=0-|",
            options: [], metrics: metrics, views: views))
        actionButton.addConstraint(NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BubbleNotificationView.buttonHeight))
        textsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]-infoLabelMargin-[infoLabel]|",
            options: [], metrics: metrics, views: views))
        textsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|",
            options: [], metrics: metrics, views: views))
        textsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[infoLabel]|",
            options: [], metrics: metrics, views: views))

        layoutIfNeeded()
    }

    @objc private func buttonTapped() {
        autoDismissTimer?.invalidate()
        delegate?.bubbleNotificationActionPressed(self)
    }

    @objc private func swiped() {
        autoDismissTimer?.invalidate()
        delegate?.bubbleNotificationSwiped(self)
    }

    @objc private func autoDismiss() {
        delegate?.bubbleNotificationTimedOut(self)
    }

    private func removeBubble() {
        self.removeFromSuperview()
    }
}
