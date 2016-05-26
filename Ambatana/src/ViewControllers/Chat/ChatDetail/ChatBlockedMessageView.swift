//
//  ChatAlertView.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class ChatBlockedMessageView: UIView {
    private static let buttonVisibleHeight: CGFloat = 30
    private static let buttonVisibleBottom: CGFloat = -8
    private static let buttonHContentInset: CGFloat = 16

    let messageLabel: UILabel
    let button: UIButton
    var buttonHeightConstraint: NSLayoutConstraint?
    var buttonBottomConstraint: NSLayoutConstraint?

    private var buttonAction: (() -> Void)?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        messageLabel = UILabel(frame: CGRect.zero)
        button = UIButton(type: .Custom)
        button.frame = CGRect.zero
        super.init(frame: frame)

        addSubviews()
        setupConstraints()
        setupUI()
        setupRxBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.setStyle(.Primary(fontSize: .Small))
    }
}


// MARK: - Public methods

extension ChatBlockedMessageView {
    func setMessage(message: NSAttributedString) {
        messageLabel.attributedText = message
    }

    func setButton(title title: String) {
        button.setTitle(title, forState: .Normal)
    }

    func setButton(action action: (() -> Void)?) {
        buttonAction = action

        let buttonHidden = action == nil
        buttonHeightConstraint?.constant = buttonHidden ? 0 : ChatBlockedMessageView.buttonVisibleHeight
        buttonBottomConstraint?.constant = buttonHidden ? 0 : ChatBlockedMessageView.buttonVisibleBottom
        button.hidden = buttonHidden
    }
}


// MARK: - Private methods

private extension ChatBlockedMessageView {
    func addSubviews() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
    }
    func setupConstraints() {
        var views = [String: AnyObject]()
        views["m"] = messageLabel
        views["b"] = button
        let messageHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[m]-8-|", options: [],
                                                                                 metrics: nil, views: views)
        let buttonHMarginConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|->=8-[b]->=8-|", options: [],
                                                                                      metrics: nil, views: views)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[m]-8-[b]", options: [], metrics: nil,
                                                                          views: views)
        let buttonHeightConstraint = NSLayoutConstraint(item: button, attribute: .Height,
                                                        relatedBy: .Equal, toItem: nil,
                                                        attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        self.buttonHeightConstraint = buttonHeightConstraint
        let buttonWidthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .GreaterThanOrEqual,
                                                       toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
                                                       constant: 180)
        let buttonCenterConstraint = NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal,
                                                        toItem: self, attribute: .CenterX, multiplier: 1,
                                                        constant: 0)
        let buttonBottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal,
                                                        toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        self.buttonBottomConstraint = buttonBottomConstraint

        addConstraints(messageHConstraints + buttonHMarginConstraints + vConstraints +
            [buttonHeightConstraint, buttonWidthConstraint, buttonCenterConstraint, buttonBottomConstraint])
    }
    func setupUI() {
        layer.cornerRadius = StyleHelper.defaultCornerRadius
        backgroundColor = UIColor.disclaimerColor

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.textColor = StyleHelper.chatDisclaimerMessageColor
        messageLabel.font = UIFont.bodyFont
        button.setStyle(.Primary(fontSize: .Small))
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: ChatBlockedMessageView.buttonHContentInset,
                                                bottom: 0, right: ChatBlockedMessageView.buttonHContentInset)

        StyleHelper.applyDefaultShadow(layer)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    func setupRxBindings() {
        button.rx_tap.asObservable().subscribeNext { [weak self] _ in
            self?.buttonAction?()
        }.addDisposableTo(disposeBag)
    }
}
