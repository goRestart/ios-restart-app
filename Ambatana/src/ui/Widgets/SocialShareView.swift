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

public struct ShareType: OptionSetType {
    public let rawValue : Int
    public init(rawValue:Int){ self.rawValue = rawValue}
    
    static let Email  = ShareType(rawValue:1)
    static let Facebook  = ShareType(rawValue:2)
    static let FBMessenger = ShareType(rawValue:4)
    static let Whatsapp = ShareType(rawValue:8)
    static let Twitter = ShareType(rawValue:16)
    static let Telegram = ShareType(rawValue:32)
    static let CopyLink = ShareType(rawValue:64)
    static let SMS = ShareType(rawValue:128)
}

enum SocialShareState {
    case Completed
    case Cancelled
    case Failed
}

protocol SocialShareViewDelegate: class {
    func shareInEmail()
    func shareInEmailFinished(state: SocialShareState)
    func shareInFacebook()
    func shareInFacebookFinished(state: SocialShareState)
    func shareInFBMessenger()
    func shareInFBMessengerFinished(state: SocialShareState)
    func shareInWhatsApp()
    func shareInTwitter()
    func shareInTwitterFinished(state: SocialShareState)
    func shareInTelegram()
    func shareInSMS()
    func shareInSMSFinished(state: SocialShareState)
    func shareInCopyLink()
    func viewController() -> UIViewController?
}

enum SocialShareViewStyle {
    case Line, Grid
}

//@IBDesignable
class SocialShareView: UIView {

    static let defaultShareTypes: ShareType = [ShareType.SMS, ShareType.Facebook, ShareType.Twitter ,ShareType.FBMessenger,
                                    ShareType.Whatsapp, ShareType.Email, ShareType.CopyLink]
    
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
    weak var delegate: SocialShareViewDelegate?
    var socialMessage: SocialMessage?
    var shareTypes = SocialShareView.defaultShareTypes

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

    
    func setupWithShareTypes(shareTypes: ShareType) {
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

        let buttons = [createSMSButton(), createFacebookButton(), createTwitterButton(), createFacebookMessengerButton(),
            createWhatsappButton(), createEmailButton(), createCopyLinkButton()].flatMap{$0}
        guard !buttons.isEmpty else { return }
        switch style {
        case .Line:
            setupButtonsInLine(buttons, container: containerView)
        case .Grid:
            buttons.count <= gridColumns + 1 ? setupButtonsInLine(buttons, container: containerView) :
            setupButtonsInGrid(buttons, container: containerView)
        }
    }

    private func createSMSButton() -> UIButton? {
        guard shareTypes.contains(ShareType.SMS) else { return nil }
        // Check if i can share via SMS (not available in iPad / iPod)
        return createButton(UIImage(named: "item_share_sms")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInSMS()
            SocialHelper.shareOnSMS(socialMessage, viewController: viewController, delegate: strongSelf)
        }
    }
    
    private func createFacebookButton() -> UIButton? {
        guard shareTypes.contains(ShareType.Facebook) else { return nil }
        guard SocialHelper.canShareInFacebook() else { return nil }
        return createButton(UIImage(named: "item_share_fb")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInFacebook()
            SocialHelper.shareOnFacebook(socialMessage, viewController: viewController, delegate: strongSelf)
        }
    }

    private func createTwitterButton() -> UIButton? {
        guard shareTypes.contains(ShareType.Twitter) else { return nil }
        guard SocialHelper.canShareInTwitter() else { return nil }
        return createButton(UIImage(named: "item_share_twitter")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInTwitter()
            SocialHelper.shareOnTwitter(socialMessage, viewController: viewController, delegate: strongSelf)
        }
    }

    private func createFacebookMessengerButton() -> UIButton? {
        guard shareTypes.contains(ShareType.FBMessenger) else { return nil }
        guard SocialHelper.canShareInFBMessenger() else { return nil }
        return createButton(UIImage(named: "item_share_fb_messenger")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            strongSelf.delegate?.shareInFBMessenger()
            SocialHelper.shareOnFbMessenger(socialMessage, delegate: strongSelf)
        }
    }

    private func createWhatsappButton() -> UIButton? {
        guard shareTypes.contains(ShareType.Whatsapp) else { return nil }
        guard SocialHelper.canShareInWhatsapp() else { return nil }
        return createButton(UIImage(named: "item_share_whatsapp")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInWhatsApp()
            SocialHelper.shareOnWhatsapp(socialMessage, viewController: viewController)
        }
    }

    private func createTelegramButton() -> UIButton? {
        guard shareTypes.contains(ShareType.Telegram) else { return nil }
        guard SocialHelper.canShareInTelegram() else { return nil }
        return createButton(UIImage(named: "item_share_telegram")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInTelegram()
            SocialHelper.shareOnTelegram(socialMessage, viewController: viewController)
        }
    }

    private func createEmailButton() -> UIButton? {
        guard shareTypes.contains(ShareType.Email) else { return nil }
        guard SocialHelper.canShareInEmail() else { return nil }
        return createButton(UIImage(named: "item_share_email")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInEmail()
            SocialHelper.shareOnEmail(socialMessage, viewController: viewController, delegate: strongSelf)
        }
    }
    
    private func createCopyLinkButton() -> UIButton? {
        guard shareTypes.contains(ShareType.CopyLink) else { return nil }
        // Check if i can share via SMS (not available in iPad / iPod)
        return createButton(UIImage(named: "item_share_link")) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }
            strongSelf.delegate?.shareInCopyLink()
            SocialHelper.shareOnCopyLink(socialMessage, viewController: viewController)
        }
    }

    private func createButton(image: UIImage?, action: () -> Void) -> UIButton {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, forState: .Normal)
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


// MARK: - FBSDKSharingDelegate

extension SocialShareView: FBSDKSharingDelegate {

    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {

        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFacebookFinished(.Completed)
        case .FBMessenger:
            // Messenger always calls didCompleteWithResults, if it works,
            // will include the key "completionGesture" in the results dict
            if let _ = results["completionGesture"] {
                delegate?.shareInFBMessengerFinished(.Completed)
            } else {
                delegate?.shareInFBMessengerFinished(.Cancelled)
            }
        case .Unknown:
            break
        }
    }

    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFacebookFinished(.Failed)
        case .FBMessenger:
            delegate?.shareInFBMessengerFinished(.Failed)
        case .Unknown:
            break
        }
    }

    func sharerDidCancel(sharer: FBSDKSharing!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFacebookFinished(.Cancelled)
        case .FBMessenger:
            delegate?.shareInFBMessengerFinished(.Cancelled)
        case .Unknown:
            break
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension SocialShareView: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult
        result: MFMailComposeResult, error: NSError?) {
            var message: String? = nil
            if result.rawValue == MFMailComposeResultFailed.rawValue {
                message = LGLocalizedString.productShareEmailError
                delegate?.shareInEmailFinished(.Failed)
            } else if result.rawValue == MFMailComposeResultSent.rawValue {
                message = LGLocalizedString.productShareGenericOk
                delegate?.shareInEmailFinished(.Completed)
            } else if result.rawValue == MFMailComposeResultCancelled.rawValue {
                delegate?.shareInEmailFinished(.Cancelled)
            }

            controller.dismissViewControllerAnimated(true, completion: { [weak self] in
                guard let message = message else { return }
                self?.delegate?.viewController()?.showAutoFadingOutMessageAlert(message)
            })
    }
}


// MARK: - MFMessageComposeViewControllerDelegate

extension SocialShareView: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController,
                                      didFinishWithResult result: MessageComposeResult) {
        
        var message: String? = nil
        if result.rawValue == MessageComposeResultFailed.rawValue {
            message = LGLocalizedString.productShareSmsError
            delegate?.shareInSMSFinished(.Failed)
        } else if result.rawValue == MessageComposeResultSent.rawValue {
            message = LGLocalizedString.productShareSmsOk
            delegate?.shareInSMSFinished(.Completed)
        } else if result.rawValue == MessageComposeResultCancelled.rawValue {
            delegate?.shareInSMSFinished(.Cancelled)
        }
        
        controller.dismissViewControllerAnimated(true, completion: { [weak self] in
            guard let message = message else { return }
            self?.delegate?.viewController()?.showAutoFadingOutMessageAlert(message)
            })
    }
}


// MARK: - TwitterShareDelegate

extension SocialShareView: TwitterShareDelegate {
    
    func twitterShareCancelled() {
        delegate?.shareInTwitterFinished(.Cancelled)
    }

    func twitterShareSuccess() {
        delegate?.shareInTwitterFinished(.Completed)
    }
}

