//
//  SocialShareView.swift
//  LetGo
//
//  Created by Eli Kohen on 15/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI
import RxSwift
import RxCocoa

enum SocialShareState {
    case Completed
    case Cancelled
    case Failed
}

protocol SocialShareViewDelegate: class {
    func viewController() -> UIViewController?
}

enum SocialShareViewStyle {
    case Line, Grid
}


class SocialShareView: UIView {

    static let defaultShareTypes: [ShareType] = [.SMS, .Facebook, .Twitter ,.FBMessenger, .Whatsapp, .Email, .CopyLink]
    
    var buttonsSide: CGFloat = 56 {
        didSet {
            setAvailableButtons()
        }
    }

    var style = SocialShareViewStyle.Line {
        didSet {
            setAvailableButtons()
        }
    }
    var gridColumns = 3 {
        didSet {
            setAvailableButtons()
        }
    }

    // buttons configuration vars
    var specificCountry: String?
    var maxButtons: Int?
    var mustShowMoreOptions: Bool?

    weak var delegate: SocialShareViewDelegate?
    var socialMessage: SocialMessage?
    var shareTypes = SocialShareView.defaultShareTypes

    var socialSharer: SocialSharer?

    private let containerView = UIView()
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContainer()
        setAvailableButtons()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContainer()
        setAvailableButtons()
    }

    
    func setupWithShareTypes(shareTypes: [ShareType]) {
        self.shareTypes = shareTypes
        setAvailableButtons()
    }

    // MARK: - Private methods

    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.setContentHuggingPriority(500, forAxis: .Horizontal)
        containerView.setContentCompressionResistancePriority(501, forAxis: .Horizontal)
        addSubview(containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal,
            toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .GreaterThanOrEqual,
            toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .GreaterThanOrEqual,
            toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }

    private func setAvailableButtons() {
        containerView.removeConstraints(constraints)
        containerView.subviews.forEach { $0.removeFromSuperview() }

        let buttons = buttonListForShareTypes(shareTypes)
        guard !buttons.isEmpty else { return }
        switch style {
        case .Line:
            setupButtonsInLine(buttons, container: containerView)
        case .Grid:
            buttons.count <= gridColumns + 1 ? setupButtonsInLine(buttons, container: containerView) :
            setupButtonsInGrid(buttons, container: containerView)
        }
    }

    private func buttonListForShareTypes(shareTypes: [ShareType]) -> [UIButton] {

        var buttons: [UIButton] = []

        for type in shareTypes {
            switch type {
            case .Email:
                guard let button = createEmailButton() else { break }
                buttons.append(button)
            case .Facebook:
                guard let button = createFacebookButton() else { break }
                buttons.append(button)
            case .Twitter:
                guard let button = createTwitterButton() else { break }
                buttons.append(button)
            case .Native:
                guard let button = createNativeShareButton() else { break }
                buttons.append(button)
            case .CopyLink:
                guard let button = createCopyLinkButton() else { break }
                buttons.append(button)
            case .FBMessenger:
                guard let button = createFacebookMessengerButton() else { break }
                buttons.append(button)
            case .Whatsapp:
                guard let button = createWhatsappButton() else { break }
                buttons.append(button)
            case .Telegram:
                guard let button = createTelegramButton() else { break }
                buttons.append(button)
            case .SMS:
                guard let button = createSMSButton() else { break }
                buttons.append(button)
            }
        }
        return buttons
    }

    private func createSMSButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_sms"), accesibilityId: .SocialShareSMS) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .SMS, viewController: viewController)
        }
    }
    
    private func createFacebookButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_fb"), accesibilityId: .SocialShareFacebook) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .Facebook, viewController: viewController)
        }
    }

    private func createTwitterButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_twitter"), accesibilityId: .SocialShareTwitter) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .Twitter, viewController: viewController)
        }
    }

    private func createFacebookMessengerButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_fb_messenger"), accesibilityId: .SocialShareFBMessenger) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .FBMessenger, viewController: viewController)
        }
    }

    private func createWhatsappButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_whatsapp"), accesibilityId: .SocialShareWhatsapp) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .Whatsapp, viewController: viewController)
        }
    }

    private func createTelegramButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_telegram"), accesibilityId: .SocialShareTelegram) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .Telegram, viewController: viewController)
        }
    }

    private func createEmailButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_email"), accesibilityId: .SocialShareEmail) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .Email, viewController: viewController)
        }
    }
    
    private func createCopyLinkButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_link"), accesibilityId: .SocialShareCopyLink) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .CopyLink, viewController: viewController)
        }
    }

    private func createNativeShareButton() -> UIButton? {
        return createButton(UIImage(named: "item_share_more"), accesibilityId: .SocialShareMore) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: .Native, viewController: viewController)
        }
    }

    private func createButton(image: UIImage?, accesibilityId: AccessibilityId, action: () -> Void) -> UIButton {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, forState: .Normal)
        button.accessibilityId = accessibilityId
        button.rx_tap.subscribeNext(action).addDisposableTo(disposeBag)
        let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil,
                                    attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsSide)
        let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                    attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsSide)
        button.addConstraints([width, height])
        return button
    }

    private func setupButtonsInLine(buttons: [UIButton], container: UIView) {
        buttons.forEach { container.addSubview($0) }
        var previous: UIButton? = nil
        for (index, button) in buttons.enumerate() {
            if let previous = previous {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: previous, attribute: .Right, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: container, attribute: .Left, multiplier: 1.0, constant: 0))
            }
            container.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                toItem: container, attribute: .Top, multiplier: 1.0, constant: 0))
            container.addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal,
                toItem: container, attribute: .Bottom, multiplier: 1.0, constant: 0))
            if index == buttons.count - 1 {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal,
                    toItem: container, attribute: .Right, multiplier: 1.0, constant: 0))
            }
            previous = button
        }
    }

    private func setupButtonsInGrid(buttons: [UIButton], container: UIView) {
        buttons.forEach { container.addSubview($0) }
        let maxRow = floor(CGFloat(buttons.count-1) / CGFloat(gridColumns))
        var previous: UIButton? = nil
        var top: UIButton? = nil
        for (index, button) in buttons.enumerate() {
            if let previous = previous {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: previous, attribute: .Right, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: container, attribute: .Left, multiplier: 1.0, constant: 0))
            }

            if let top = top {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                    toItem: top, attribute: .Bottom, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                    toItem: container, attribute: .Top, multiplier: 1.0, constant: 0))
            }

            let currentRow = floor(CGFloat(index) / CGFloat(gridColumns))
            if currentRow == maxRow {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal,
                    toItem: container, attribute: .Bottom, multiplier: 1.0, constant: 0))
            }

            if index % gridColumns == gridColumns - 1 {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal,
                    toItem: container, attribute: .Right, multiplier: 1.0, constant: 0))
                top = button
                previous = nil
            } else {
                previous = button
            }
        }
    }
}
