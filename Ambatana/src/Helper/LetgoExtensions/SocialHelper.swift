//
//  SocialHelper.swift
//  LetGo
//
//  Created by AHL on 16/8/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import TwitterKit
import LGCoreKit
import MessageUI
import Branch


enum ShareType {
    case Email, Facebook, FBMessenger, Whatsapp, Twitter, Telegram, CopyLink, SMS, Native

    private static var otherCountriesTypes: [ShareType] { return [.SMS, .Email, .Facebook, .FBMessenger, .Twitter, .Whatsapp, .Telegram] }
    private static var turkeyTypes: [ShareType] { return [.Whatsapp, .Facebook, .Email ,.FBMessenger, .Twitter, .SMS, .Telegram] }

    var moreInfoTypes: [ShareType] {
        return ShareType.shareTypesForCountry("", maxButtons: nil, includeNative: false)
    }

    static func shareTypesForCountry(countryCode: String, maxButtons: Int?, includeNative: Bool) -> [ShareType] {
        let turkey = "tr"

        let countryTypes: [ShareType]
        switch countryCode {
        case turkey:
            countryTypes = turkeyTypes
        default:
            countryTypes = otherCountriesTypes
        }

        var resultShareTypes = countryTypes.filter { $0.canShare }

        if var maxButtons = maxButtons where maxButtons > 0 {
            maxButtons = includeNative ? maxButtons-1 : maxButtons
            if resultShareTypes.count > maxButtons {
                resultShareTypes = Array(resultShareTypes[0..<maxButtons])
            }
        }

        if includeNative {
            resultShareTypes.append(.Native)
        }

        return resultShareTypes
    }

    var canShare: Bool {
        switch  self {
        case .Email:
            return MFMailComposeViewController.canSendMail()
        case Facebook, .Twitter, .Native, .CopyLink:
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
}

final class SocialHelper {
    /**
        Returns a social message for the given product with a title.
    
        - parameter title: The title
        - parameter product: The product
        - returns: The social message.
    */
    static func socialMessageWithProduct(product: Product) -> SocialMessage {
        let productIsMine = Core.myUserRepository.myUser?.objectId == product.user.objectId
        let socialTitleMyProduct = product.price.free ? LGLocalizedString.productIsMineShareBodyFree :
                                                        LGLocalizedString.productIsMineShareBody
        let socialTitle = productIsMine ? socialTitleMyProduct : LGLocalizedString.productShareBody
        return ProductSocialMessage(title: socialTitle, product: product, isMine: productIsMine)
    }

    static func socialMessageUser(user: User, itsMe: Bool) -> SocialMessage {
        return UserSocialMessage(user: user, itsMe: itsMe)
    }

    static func socialMessageAppShare() -> SocialMessage {
        return AppShareSocialMessage()
    }

    static func socialMessageCommercializer(shareUrl: String, thumbUrl: String?) -> SocialMessage {
        return CommercializerSocialMessage(shareUrl: shareUrl, thumbUrl: thumbUrl)
    }

    static func shareOnSMS(socialMessage: SocialMessage, viewController: UIViewController,
                           delegate: MFMessageComposeViewControllerDelegate) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = socialMessage.smsShareText
            messageVC.recipients = []
            messageVC.messageComposeDelegate = delegate;
            viewController.presentViewController(messageVC, animated: false, completion: nil)
        } else {
            viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareSmsError)
        }
    }
    
    static func shareOnFacebook(socialMessage: SocialMessage, viewController: UIViewController,
                                delegate: FBSDKSharingDelegate?) {
        FBSDKShareDialog.showFromViewController(viewController, withContent: socialMessage.fbShareContent,
                delegate: delegate)
    }

    static func shareOnTwitter(socialMessage: SocialMessage, viewController: UIViewController, delegate: TwitterShareDelegate) {

        socialMessage.twitterComposer.showFromViewController(viewController) { result in
            switch result {
            case .Cancelled:
                delegate.twitterShareCancelled()
            case .Done:
                delegate.twitterShareSuccess()
            }
        }
    }

    static func shareOnFbMessenger(socialMessage: SocialMessage, delegate: FBSDKSharingDelegate?) {
        FBSDKMessageDialog.showWithContent(socialMessage.fbMessengerShareContent, delegate: delegate)
    }

    static func shareOnWhatsapp(socialMessage: SocialMessage, viewController: UIViewController) {
        guard let url = generateWhatsappURL(socialMessage) else { return }

        if !UIApplication.sharedApplication().openURL(url) {
            viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareWhatsappError)
        }
    }

    static func shareOnTelegram(socialMessage: SocialMessage, viewController: UIViewController) {
        guard let url = generateTelegramURL(socialMessage) else { return }

        if !UIApplication.sharedApplication().openURL(url) {
            viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareTelegramError)
        }
    }

    static func shareOnEmail(socialMessage: SocialMessage, viewController: UIViewController,
        delegate: MFMailComposeViewControllerDelegate?) {
            let isEmailAccountConfigured = MFMailComposeViewController.canSendMail()
            if isEmailAccountConfigured {
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = delegate
                vc.setSubject(socialMessage.emailShareSubject)
                vc.setMessageBody(socialMessage.emailShareBody, isHTML: socialMessage.emailShareIsHtml)
                viewController.presentViewController(vc, animated: true, completion: nil)
            }
            else {
                viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareEmailError)
            }
    }

    static func shareOnCopyLink(socialMessage: SocialMessage, viewController: UIViewController) {
        UIPasteboard.generalPasteboard().string = socialMessage.copyLinkText
        viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareCopylinkOk)
    }
    
    static func generateWhatsappURL(socialMessage: SocialMessage) -> NSURL? {
        return generateMessageShareURL(socialMessage.whatsappShareText, withUrlScheme: Constants.whatsAppShareURL)
    }

    static func generateTelegramURL(socialMessage: SocialMessage) -> NSURL? {
        return generateMessageShareURL(socialMessage.telegramShareText, withUrlScheme: Constants.telegramShareURL)
    }

    static func generateMessageShareURL(socialMessageText: String, withUrlScheme scheme: String) -> NSURL? {
        let queryCharSet = NSMutableCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]")
        queryCharSet.invert()
        queryCharSet.formIntersectionWithCharacterSet(NSCharacterSet.URLQueryAllowedCharacterSet())
        guard let urlEncodedShareText = socialMessageText
            .stringByAddingPercentEncodingWithAllowedCharacters(queryCharSet) else { return nil }
        return NSURL(string: String(format: scheme, urlEncodedShareText))
    }

    static func canShareInFacebook() -> Bool {
        return true
    }

    static func canShareInTwitter() -> Bool {
        return true
    }

    static func canShareInWhatsapp() -> Bool {
        guard let url = NSURL(string: "whatsapp://") else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }

    static func canShareInFBMessenger() -> Bool {
        guard let url = NSURL(string: "fb-messenger-api://") else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }

    static func canShareInEmail() -> Bool {
        return ShareType.Email.canShare
    }

    static func canShareInTelegram() -> Bool {
        guard let url = NSURL(string: "tg://") else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }
}


// MARK: - UIViewController native share extension

protocol NativeShareDelegate {
    var nativeShareSuccessMessage: String? { get }
    var nativeShareErrorMessage: String? { get }
    func nativeShareInFacebook()
    func nativeShareInTwitter()
    func nativeShareInEmail()
    func nativeShareInWhatsApp()
}

extension UIViewController {

    func presentNativeShare(socialMessage socialMessage: SocialMessage, delegate: NativeShareDelegate?,
                                          barButtonItem: UIBarButtonItem? = nil) {

        guard let activityItems = socialMessage.nativeShareItems else { return }
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
        if vc.respondsToSelector(Selector("popoverPresentationController")) {
            let presentationController = vc.popoverPresentationController
            if let item = barButtonItem {
                presentationController?.barButtonItem = item
            } else {
                presentationController?.sourceView = self.view
            }
        }

        vc.completionWithItemsHandler = { [weak self] (activity, success, items, error) in

            // Comment left here as a clue to manage future activities
            /*   SAMPLES OF SHARING RESULTS VIA ACTIVITY VC

             println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")

             Activity: com.apple.UIKit.activity.PostToFacebook Success: true Items: nil Error: nil
             Activity: net.whatsapp.WhatsApp.ShareExtension Success: true Items: nil Error: nil
             Activity: com.apple.UIKit.activity.Mail Success: true Items: nil Error: nil
             Activity: com.apple.UIKit.activity.PostToTwitter Success: true Items: nil Error: nil
             */

            guard success else {
                //In case of cancellation just do nothing -> success == false && error == nil
                guard error != nil else { return }
                if let errorMessage = delegate?.nativeShareErrorMessage {
                    self?.showAutoFadingOutMessageAlert(errorMessage)
                }
                return
            }

            if activity == UIActivityTypePostToFacebook {
                delegate?.nativeShareInFacebook()
            } else if activity == UIActivityTypePostToTwitter {
                delegate?.nativeShareInTwitter()
            } else if activity == UIActivityTypeMail {
                delegate?.nativeShareInEmail()
            } else if let ac = activity, let _ = ac.rangeOfString("whatsapp") {
                delegate?.nativeShareInWhatsApp()
                return
            } else if activity == UIActivityTypeCopyToPasteboard {
                return
            }

            if let successMessage = delegate?.nativeShareSuccessMessage {
                self?.showAutoFadingOutMessageAlert(successMessage)
            }
        }
        presentViewController(vc, animated: true, completion: nil)
    }
}
