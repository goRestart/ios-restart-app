//
//  SocialSharer.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FBSDKShareKit
import MessageUI


protocol SocialSharerDelegate: class {
    func shareStartedIn(shareType: ShareType)
    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState)
}


class SocialSharer: NSObject {
    weak var delegate: SocialSharerDelegate?
}


// MARK: - Public methods
// MARK: > Share

extension SocialSharer {
    func share(socialMessage: SocialMessage, shareType: ShareType,
               viewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        guard SocialSharer.canShareIn(shareType) else {
            delegate?.shareStartedIn(shareType)
            delegate?.shareFinishedIn(shareType, withState: .Failed)
            return
        }

        switch shareType {
        case .Email:
            shareInEmail(socialMessage, viewController: viewController)
        case .Facebook:
            shareInFacebook(socialMessage, viewController: viewController)
        case .FBMessenger:
            shareInFBMessenger(socialMessage)
        case .Whatsapp:
            shareInWhatsapp(socialMessage)
        case .Twitter:
            shareInTwitter(socialMessage, viewController: viewController)
        case .Telegram:
            shareInTelegram(socialMessage)
        case .CopyLink:
            shareInPasteboard(socialMessage)
        case .SMS:
            shareInSMS(socialMessage, viewController: viewController, messageComposeDelegate: self)
        case .Native:
            shareInNative(socialMessage, viewController: viewController, barButtonItem: barButtonItem)
        }
    }
}


// MARK: > Share helpers

extension SocialSharer {
    static func canShareIn(shareType: ShareType) -> Bool {
        switch shareType {
        case .Email:
            return MFMailComposeViewController.canSendMail()
        case .Facebook, .Twitter, .Native, .CopyLink:
            return true
        case .FBMessenger:
            guard let url = NSURL(string: "fb-messenger-api://") else { return false }
            let application = UIApplication.sharedApplication()
            return application.canOpenURL(url)
        case .Whatsapp:
            guard let url = NSURL(string: "whatsapp://") else { return false }
            let application = UIApplication.sharedApplication()
            return application.canOpenURL(url)
        case .Telegram:
            guard let url = NSURL(string: "tg://") else { return false }
            let application = UIApplication.sharedApplication()
            return application.canOpenURL(url)
        case .SMS:
            return MFMessageComposeViewController.canSendText()
        }
    }

    static func canShareInAny(shareTypes: [ShareType]) -> Bool {
        for shareType in shareTypes {
            if canShareIn(shareType) {
                return true
            }
        }
        return false
    }
}


// MARK: - FBSDKSharingDelegate

extension SocialSharer: FBSDKSharingDelegate {
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

extension SocialSharer: MFMailComposeViewControllerDelegate {
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

extension SocialSharer: MFMessageComposeViewControllerDelegate {
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

        controller.dismissViewControllerAnimated(true, completion: { [weak self] in
            self?.delegate?.shareFinishedIn(.SMS, withState: state)
        })
    }
}


// MARK: - Private methods
// MARK: > Share

private extension SocialSharer {
    func shareInEmail(socialMessage: SocialMessage, viewController: UIViewController) {
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        emailVC.setSubject(socialMessage.emailShareSubject)
        emailVC.setMessageBody(socialMessage.emailShareBody, isHTML: socialMessage.emailShareIsHtml)
        viewController.presentViewController(emailVC, animated: true) { [weak self] in
            self?.delegate?.shareStartedIn(.Email)
        }
    }

    func shareInFacebook(socialMessage: SocialMessage, viewController: UIViewController) {
        delegate?.shareStartedIn(.Facebook)
        FBSDKShareDialog.showFromViewController(viewController, withContent: socialMessage.fbShareContent,
                                                delegate: self)
    }

    func shareInFBMessenger(socialMessage: SocialMessage) {
        delegate?.shareStartedIn(.FBMessenger)
        FBSDKMessageDialog.showWithContent(socialMessage.fbMessengerShareContent, delegate: self)
    }

    func shareInWhatsapp(socialMessage: SocialMessage) {
        shareInURL(.Whatsapp, text: socialMessage.whatsappShareText, urlScheme: Constants.whatsAppShareURL)
    }

    func shareInTwitter(socialMessage: SocialMessage, viewController: UIViewController) {
        delegate?.shareStartedIn(.Twitter)
        socialMessage.twitterComposer.showFromViewController(viewController) { [weak self] result in
            let state: SocialShareState
            switch result {
            case .Cancelled:
                state = .Cancelled
            case .Done:
                state = .Completed
            }
            self?.delegate?.shareFinishedIn(.Twitter, withState: state)
        }
    }

    func shareInTelegram(socialMessage: SocialMessage) {
        shareInURL(.Telegram, text: socialMessage.telegramShareText, urlScheme: Constants.telegramShareURL)
    }

    func shareInPasteboard(socialMessage: SocialMessage) {
        delegate?.shareStartedIn(.CopyLink)
        UIPasteboard.generalPasteboard().string = socialMessage.copyLinkText
        delegate?.shareFinishedIn(.CopyLink, withState: .Completed)
    }

    func shareInSMS(socialMessage: SocialMessage, viewController: UIViewController,
                    messageComposeDelegate: MFMessageComposeViewControllerDelegate) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = socialMessage.smsShareText
        messageVC.recipients = []
        messageVC.messageComposeDelegate = messageComposeDelegate

        viewController.presentViewController(messageVC, animated: false) { [weak self] in
            self?.delegate?.shareStartedIn(.SMS)
        }
    }

    func shareInNative(socialMessage: SocialMessage, viewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        guard let activityItems = socialMessage.nativeShareItems else {
            delegate?.shareStartedIn(.Native)
            delegate?.shareFinishedIn(.Native, withState: .Failed)
            return
        }

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

    func shareInURL(shareType: ShareType, text: String, urlScheme: String) {
        delegate?.shareStartedIn(shareType)

        guard let url = SocialSharer.generateMessageShareURL(text, withUrlScheme: urlScheme) else {
            delegate?.shareFinishedIn(shareType, withState: .Failed)
            return
        }
        if UIApplication.sharedApplication().openURL(url) {
            delegate?.shareFinishedIn(shareType, withState: .Completed)
        } else {
            delegate?.shareFinishedIn(shareType, withState: .Failed)
        }
    }
}


// MARK: > Helpers

private extension SocialSharer {
    static func generateMessageShareURL(socialMessageText: String, withUrlScheme scheme: String) -> NSURL? {
        let queryCharSet = NSMutableCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]")
        queryCharSet.invert()
        queryCharSet.formIntersectionWithCharacterSet(NSCharacterSet.URLQueryAllowedCharacterSet())
        guard let urlEncodedShareText = socialMessageText
            .stringByAddingPercentEncodingWithAllowedCharacters(queryCharSet) else { return nil }
        return NSURL(string: String(format: scheme, urlEncodedShareText))
    }
}
