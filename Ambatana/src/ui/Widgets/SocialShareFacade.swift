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
    func shareStartedIn(shareType: ShareType)
    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState)
}

class SocialShareFacade: NSObject {
    weak var delegate: SocialShareFacadeDelegate?
}

// MARK: - Public methods

extension SocialShareFacade {
    func share(socialMessage: SocialMessage, shareType: ShareType,
               viewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        guard shareType.canShare else {
            delegate?.shareFinishedIn(shareType, withState: .Failed)
            return
        }
        delegate?.shareStartedIn(shareType)

        switch shareType {
        case .Email:
            SocialHelper.shareOnEmail(socialMessage, viewController: viewController, delegate: self)
        case .Facebook:
            SocialHelper.shareOnFacebook(socialMessage, viewController: viewController, delegate: self)
        case .FBMessenger:
            SocialHelper.shareOnFbMessenger(socialMessage, delegate: self)
        case .Whatsapp:
            SocialHelper.shareOnWhatsapp(socialMessage, viewController: viewController)
            delegate?.shareFinishedIn(shareType, withState: .Completed)
        case .Twitter:
            SocialHelper.shareOnTwitter(socialMessage, viewController: viewController, delegate: self)
        case .Telegram:
            SocialHelper.shareOnTelegram(socialMessage, viewController: viewController)
            delegate?.shareFinishedIn(shareType, withState: .Completed)
        case .CopyLink:
            SocialHelper.shareOnCopyLink(socialMessage, viewController: viewController)
            delegate?.shareFinishedIn(shareType, withState: .Completed)
        case .SMS:
            SocialHelper.shareOnSMS(socialMessage, viewController: viewController, delegate: self)
        case .Native:
            shareNative(socialMessage, viewController: viewController, barButtonItem: barButtonItem)
        }
    }
}

// MARK: - FBSDKSharingDelegate

extension SocialShareFacade: FBSDKSharingDelegate {
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        guard sharer != nil else { return }

        switch sharer.type {
        case .Facebook:
            delegate?.shareFinishedIn(.Facebook, withState: .Completed)
        case .FBMessenger:
            // Messenger always calls didCompleteWithResults, if it works,
            // will include the key "completionGesture" in the results dict
            if let results = results, _ = results["completionGesture"] {
                delegate?.shareFinishedIn(.FBMessenger, withState: .Completed)
            } else {
                delegate?.shareFinishedIn(.FBMessenger, withState: .Cancelled)
            }
        case .Unknown:
            break
        }
    }

    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        guard sharer != nil else { return }

        switch sharer.type {
        case .Facebook:
            delegate?.shareFinishedIn(.Facebook, withState: .Failed)
        case .FBMessenger:
            delegate?.shareFinishedIn(.FBMessenger, withState: .Failed)
        case .Unknown:
            break
        }
    }

    func sharerDidCancel(sharer: FBSDKSharing!) {
        guard sharer != nil else { return }

        switch sharer.type {
        case .Facebook:
            delegate?.shareFinishedIn(.Facebook, withState: .Cancelled)
        case .FBMessenger:
            delegate?.shareFinishedIn(.FBMessenger, withState: .Cancelled)
        case .Unknown:
            break
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension SocialShareFacade: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult,
                               error: NSError?) {
        let state: SocialShareState
        switch result {
        case .Failed:
            state = .Failed
        case .Sent:
            state = .Completed
        case .Cancelled, .Saved:
            state = .Cancelled
        }

        controller.dismissViewControllerAnimated(true, completion: { [weak self] in
            self?.delegate?.shareFinishedIn(.Email, withState: state)
        })
    }
}


// MARK: - MFMessageComposeViewControllerDelegate

extension SocialShareFacade: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController,
                                      didFinishWithResult result: MessageComposeResult) {
        let state: SocialShareState
        switch result {
        case .Failed:
            state = .Failed
        case .Sent:
            state = .Completed
        case .Cancelled:
            state = .Cancelled
        }
        delegate?.shareFinishedIn(.SMS, withState: state)
    }
}


// MARK: - TwitterShareDelegate

extension SocialShareFacade: TwitterShareDelegate {
    func twitterShareCancelled() {
        delegate?.shareFinishedIn(.Twitter, withState: .Cancelled)
    }

    func twitterShareSuccess() {
        delegate?.shareFinishedIn(.Twitter, withState: .Completed)
    }
}


// MARK: - Private methods

private extension SocialShareFacade {
    func shareNative(socialMessage: SocialMessage, viewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        guard let activityItems = socialMessage.nativeShareItems else { return }
        let shareVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
        if shareVC.respondsToSelector(Selector("popoverPresentationController")) {
            let presentationController = shareVC.popoverPresentationController
            if let item = barButtonItem {
                presentationController?.barButtonItem = item
            } else {
                presentationController?.sourceView = viewController.view
            }
        }

        shareVC.completionWithItemsHandler = { [weak self] (activity, success, items, error) in
            guard let strongSelf = self else { return }
            let shareType: ShareType
            if let activity = activity {
                switch activity {
                case UIActivityTypePostToFacebook:
                    shareType = .Facebook
                case UIActivityTypePostToTwitter:
                    shareType = .Twitter
                case UIActivityTypeMail:
                    shareType = .Email
                case UIActivityTypeCopyToPasteboard:
                    shareType = .CopyLink
                default:
                    if let _ = activity.rangeOfString("whatsapp") {
                        shareType = .Whatsapp
                    } else {
                        shareType = .Native
                    }
                }
            } else {
                shareType = .Native
            }

            // Comment left here as a clue to manage future activities
            /*   SAMPLES OF SHARING RESULTS VIA ACTIVITY VC

             println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")

             Activity: com.apple.UIKit.activity.PostToFacebook Success: true Items: nil Error: nil
             Activity: net.whatsapp.WhatsApp.ShareExtension Success: true Items: nil Error: nil
             Activity: com.apple.UIKit.activity.Mail Success: true Items: nil Error: nil
             Activity: com.apple.UIKit.activity.PostToTwitter Success: true Items: nil Error: nil
             */
            if success {
                strongSelf.delegate?.shareFinishedIn(shareType, withState: .Completed)
            } else if let _  = error {
                strongSelf.delegate?.shareFinishedIn(shareType, withState: .Failed)
            } else {
                strongSelf.delegate?.shareFinishedIn(shareType, withState: .Cancelled)
            }
        }
        viewController.presentViewController(shareVC, animated: true) { [weak self] in
            self?.delegate?.shareStartedIn(.Native)
        }
    }
}
