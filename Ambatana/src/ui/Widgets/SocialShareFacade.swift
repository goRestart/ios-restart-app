//
//  SocialShareFacade.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FBSDKShareKit
import MessageUI

protocol SocialShareFacadeDelegate: class {
    func shareIn(shareType: ShareType)
    func shareIn(shareType: ShareType, finishedWithState state: SocialShareState)
}

class SocialShareFacade: NSObject {
    weak var delegate: SocialShareFacadeDelegate?
}

// MARK: - Public methods

extension SocialShareFacade {
    func share(socialMessage: SocialMessage, shareType: ShareType, viewController: UIViewController) {
        guard shareType.canShare else {
            delegate?.shareIn(shareType, finishedWithState: .Failed)
            return
        }
        delegate?.shareIn(shareType)

        switch shareType {
        case .Email:
            SocialHelper.shareOnEmail(socialMessage, viewController: viewController, delegate: self)
        case .Facebook:
            SocialHelper.shareOnFacebook(socialMessage, viewController: viewController, delegate: self)
        case .FBMessenger:
            SocialHelper.shareOnFbMessenger(socialMessage, delegate: self)
        case .Whatsapp:
            SocialHelper.shareOnWhatsapp(socialMessage, viewController: viewController)
            delegate?.shareIn(shareType, finishedWithState: .Completed)
        case .Twitter:
            SocialHelper.shareOnTwitter(socialMessage, viewController: viewController, delegate: self)
        case .Telegram:
            SocialHelper.shareOnTelegram(socialMessage, viewController: viewController)
            delegate?.shareIn(shareType, finishedWithState: .Completed)
        case .CopyLink:
            SocialHelper.shareOnCopyLink(socialMessage, viewController: viewController)
            delegate?.shareIn(shareType, finishedWithState: .Completed)
        case .SMS:
            SocialHelper.shareOnSMS(socialMessage, viewController: viewController, delegate: self)
        case .Native:
            // TODO: !!
            break
        }
    }
}

// MARK: - FBSDKSharingDelegate

extension SocialShareFacade: FBSDKSharingDelegate {

    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        guard sharer != nil else { return }

        switch (sharer.type) {
        case .Facebook:
            delegate?.shareIn(.Facebook, finishedWithState: .Completed)
        case .FBMessenger:
            // Messenger always calls didCompleteWithResults, if it works,
            // will include the key "completionGesture" in the results dict
            if let _ = results["completionGesture"] {
                delegate?.shareIn(.FBMessenger, finishedWithState: .Completed)
            } else {
                delegate?.shareIn(.FBMessenger, finishedWithState: .Cancelled)
            }
        case .Unknown:
            break
        }
    }

    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareIn(.Facebook, finishedWithState: .Failed)
        case .FBMessenger:
            delegate?.shareIn(.FBMessenger, finishedWithState: .Failed)
        case .Unknown:
            break
        }
    }

    func sharerDidCancel(sharer: FBSDKSharing!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareIn(.Facebook, finishedWithState: .Cancelled)
        case .FBMessenger:
            delegate?.shareIn(.FBMessenger, finishedWithState: .Cancelled)
        case .Unknown:
            break
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension SocialShareFacade: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult,
                               error: NSError?) {
        var message: String? = nil
        switch result {
        case .Failed:
            message = LGLocalizedString.productShareEmailError
            delegate?.shareIn(.Email, finishedWithState: .Failed)
        case .Sent:
            message = LGLocalizedString.productShareGenericOk
            delegate?.shareIn(.Email, finishedWithState: .Completed)
        case .Cancelled:
            delegate?.shareIn(.Email, finishedWithState: .Cancelled)
        case .Saved:
            break
        }

        // TODO: !
//        controller.dismissViewControllerAnimated(true, completion: { [weak self] in
//            guard let message = message else { return }
//            self?.delegate?.viewController()?.showAutoFadingOutMessageAlert(message)
//        })
    }
}


// MARK: - MFMessageComposeViewControllerDelegate

extension SocialShareFacade: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController,
                                      didFinishWithResult result: MessageComposeResult) {
        var message: String? = nil
        switch result {
        case .Failed:
            message = LGLocalizedString.productShareSmsError
            delegate?.shareIn(.SMS, finishedWithState: .Failed)
        case .Sent:
            message = LGLocalizedString.productShareSmsOk
            delegate?.shareIn(.SMS, finishedWithState: .Completed)
        case .Cancelled:
            delegate?.shareIn(.SMS, finishedWithState: .Cancelled)
        }

        // TODO: !
//        controller.dismissViewControllerAnimated(true, completion: { [weak self] in
//            guard let message = message else { return }
//            self?.delegate?.viewController()?.showAutoFadingOutMessageAlert(message)
//            })
    }
}


// MARK: - TwitterShareDelegate

extension SocialShareFacade: TwitterShareDelegate {
    func twitterShareCancelled() {
        delegate?.shareIn(.Twitter, finishedWithState: .Cancelled)
    }

    func twitterShareSuccess() {
        delegate?.shareIn(.Twitter, finishedWithState: .Completed)
    }
}
