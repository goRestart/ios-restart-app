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
    func bubbleNotificationSwiped(_ notification: BubbleNotification)
    func bubbleNotificationTimedOut(_ notification: BubbleNotification)
    func bubbleNotificationActionPressed(_ notification: BubbleNotification)
}

class BubbleNotification: UIView {

    static let initialHeight: CGFloat = 80

    static let buttonHeight: CGFloat = 30
    static let buttonMaxWidth: CGFloat = 150
    static let bubbleMargin: CGFloat = 10
    static let bubbleContentMargin: CGFloat = 14
    static let bubbleInternalMargins: CGFloat = 8
    static let statusBarHeight: CGFloat = 20
    static let iconDiameter: CGFloat = 46

    static let showAnimationTime: TimeInterval = 0.3
    static let closeAnimationTime: TimeInterval = 0.5

    weak var delegate: BubbleNotificationDelegate?

    private var containerView = UIView()
    private var leftIcon = UIImageView()
    private var textlabel = UILabel()
    private var infoTextLabel = UILabel()
    private var actionButton = UIButton(type: .custom)

    private var autoDismissTimer: Timer?

    var bottomConstraint = NSLayoutConstraint()

    let data: BubbleNotificationData


    // - Lifecycle

    init(frame: CGRect, data: BubbleNotificationData) {
        self.data = data
        super.init(frame: frame)
        setupConstraints()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setupOnView(parentView: UIView) {
        // bubble constraints
        let bubbleLeftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal,
                                                      toItem: parentView, attribute: .left, multiplier: 1,
                                                      constant: BubbleNotification.bubbleMargin)
        let bubbleRightConstraint = NSLayoutConstraint(item: parentView, attribute: .right, relatedBy: .equal,
                                                       toItem: self, attribute: .right, multiplier: 1,
                                                       constant: BubbleNotification.bubbleMargin)
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
                                                     toItem: parentView, attribute: .top, multiplier: 1, constant: 0)
        parentView.addConstraints([bubbleLeftConstraint, bubbleRightConstraint, bottomConstraint])
    }

    func showBubble() {
        self.showBubble(autoDismissTime: nil)
    }
    func showBubble(autoDismissTime time: TimeInterval?) {
        // delay to let the setup build the view properly
        delay(0.1) { [weak self] in
            self?.bottomConstraint.constant = (self?.height ?? 0) + BubbleNotification.statusBarHeight
            UIView.animate(withDuration: BubbleNotification.showAnimationTime) { self?.layoutIfNeeded() }
        }

        if let dismissTime = time, dismissTime > 0 {
            let totalTime = BubbleNotification.showAnimationTime + dismissTime
            autoDismissTimer = Timer.scheduledTimer(timeInterval: totalTime, target: self,
                                                   selector: #selector(autoDismiss), userInfo: nil, repeats: false)
        }
    }

    func closeBubble() {
        guard superview != nil else { return } // Already closed
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: BubbleNotification.closeAnimationTime, animations: { [weak self] in
            self?.layoutIfNeeded()
        }, completion: { [weak self ] _ in
            self?.removeBubble()
        }) 
    }


    // MARK : - Private methods

    private func setupUI() {
        backgroundColor = UIColor.white
        layer.cornerRadius = LGUIKitConstants.containerCornerRadius
        applyDefaultShadow()

        if data.hasIcon {
            leftIcon.clipsToBounds = true
            leftIcon.layer.cornerRadius = BubbleNotification.iconDiameter/2
        }
        if let iconImage = data.iconImage {
            leftIcon.image = iconImage
        }
        if let iconURL = data.iconURL {
            leftIcon.lg_setImageWithURL(iconURL)
        }

        textlabel.numberOfLines = 2
        textlabel.lineBreakMode = .byTruncatingTail
        textlabel.textColor = UIColor.blackText
        textlabel.font = UIFont.mediumBodyFont
        textlabel.text = data.text

        if let infoText = data.infoText {
            infoTextLabel.numberOfLines = 2
            infoTextLabel.lineBreakMode = .byTruncatingTail
            infoTextLabel.textColor = UIColor.darkGrayText
            infoTextLabel.font = UIFont.smallBodyFont
            infoTextLabel.text = infoText
        }

        if let action = data.action {
            actionButton.setStyle(.secondary(fontSize: .small, withBorder: true))
            actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
            actionButton.titleLabel?.minimumScaleFactor = 0.8
            actionButton.setTitle(action.text, for: UIControlState())
            actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            actionButton.accessibilityId =  action.accessibilityId
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeGesture.direction = .up
        self.addGestureRecognizer(swipeGesture)
    }

    private func setupConstraints() {

        let textsContainer = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textsContainer.translatesAutoresizingMaskIntoConstraints = false
        leftIcon.translatesAutoresizingMaskIntoConstraints = false
        textlabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(leftIcon)
        containerView.addSubview(textsContainer)
        textsContainer.addSubview(textlabel)
        textsContainer.addSubview(infoTextLabel)
        containerView.addSubview(actionButton)

        var views = [String: Any]()
        views["container"] = containerView
        views["textsContainer"] = textsContainer
        views["icon"] = leftIcon
        views["label"] = textlabel
        views["infoLabel"] = infoTextLabel
        views["button"] = actionButton

        var metrics = [String: Any]()
        metrics["margin"] = BubbleNotification.bubbleContentMargin
        metrics["buttonWidth"] = CGFloat(data.action != nil ? BubbleNotification.buttonMaxWidth : 0)
        metrics["iconDiameter"] = CGFloat(data.hasIcon ? BubbleNotification.iconDiameter : 0)
        metrics["iconMargin"] = CGFloat(data.hasIcon ? BubbleNotification.bubbleInternalMargins : 0)
        metrics["infoLabelMargin"] = CGFloat(data.hasInfo ? 2 : 0)

        // container view
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[container]-margin-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[container]-margin-|",
            options: [], metrics: metrics, views: views))

        // image text label and button
        actionButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=0-[textsContainer]->=0-|",
            options: [], metrics: metrics, views: views))
        leftIcon.addConstraint(NSLayoutConstraint(item: leftIcon, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BubbleNotification.iconDiameter))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon(iconDiameter)]-iconMargin-[textsContainer]-[button(<=buttonWidth)]-0-|",
            options: [.alignAllCenterY], metrics: metrics, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=0-[icon(iconDiameter)]->=0-|",
            options: [], metrics: metrics, views: views))
        actionButton.addConstraint(NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BubbleNotification.buttonHeight))
        textsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]-infoLabelMargin-[infoLabel]|",
            options: [], metrics: metrics, views: views))
        textsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|",
            options: [], metrics: metrics, views: views))
        textsContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[infoLabel]|",
            options: [], metrics: metrics, views: views))

        layoutIfNeeded()
    }

    dynamic private func buttonTapped() {
        autoDismissTimer?.invalidate()
        delegate?.bubbleNotificationActionPressed(self)
    }

    dynamic private func swiped() {
        autoDismissTimer?.invalidate()
        delegate?.bubbleNotificationSwiped(self)
    }

    dynamic private func autoDismiss() {
        delegate?.bubbleNotificationTimedOut(self)
    }

    private func removeBubble() {
        self.removeFromSuperview()
    }
}
