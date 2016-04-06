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

enum CommercializerUTMSource: String {
    case Facebook = "facebook"
    case Twitter = "twitter"
    case FBMessenger = "facebook_messenger"
    case Whatsapp = "whatsapp"
    case Telegram = "telegram"
    case Email = "email"
}

public protocol SocialMessage {
    var whatsappShareText: String { get }
    var telegramShareText: String { get }
    func branchShareUrl(channel: String) -> String
    var emailShareSubject: String { get }
    var emailShareBody: String { get }
    var emailShareIsHtml: Bool { get }
    var fbShareContent: FBSDKShareLinkContent { get }
    var fbMessengerShareContent: FBSDKShareLinkContent { get }
    var twitterComposer: TWTRComposer { get }
    var nativeShareText: String { get }
}

public protocol TwitterShareDelegate: class {
    func twitterShareCancelled()
    func twitterShareSuccess()
}

struct ProductSocialMessage: SocialMessage {
    let title: String
    let body: String
    let url: NSURL?
    let imageURL: NSURL?
    let productId: String

    init(title: String, product: Product) {
        self.title = title
        self.body = [product.user.name, product.name].flatMap{$0}.joinWithSeparator(" - ")
        if let productId = product.objectId {
            self.url = NSURL(string: String(format: Constants.productURL, arguments: [productId]))
        }
        else {
            self.url = NSURL(string: Constants.websiteURL)
        }
        self.imageURL = product.images.first?.fileURL ?? product.thumbnail?.fileURL
        self.productId = product.objectId ?? ""
    }

    var whatsappShareText: String {
        return shareText
    }

    var telegramShareText: String {
        return shareText
    }

    var nativeShareText: String {
        return shareText
    }

    /** Returns the full sharing content. */
    private var shareText: String {
        return title.isEmpty ? emailShareBody : title + "\n" + emailShareBody
    }

    func branchShareUrl(channel: String) -> String {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "product/"+productId)
        branchUniversalObject.title = title
        branchUniversalObject.contentDescription = body
        if let canonicalUrl = url?.absoluteString {
            branchUniversalObject.canonicalUrl = canonicalUrl
        }
        if let imageURL = imageURL?.absoluteString {
            branchUniversalObject.imageUrl = imageURL
        }
        branchUniversalObject.addMetadataKey("type", value: "product")
        branchUniversalObject.addMetadataKey("productId", value: productId)

        let linkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        linkProperties.channel = channel
        guard let result = branchUniversalObject.getShortUrlWithLinkProperties(linkProperties)
            else { return "" }
        return result
    }

    var emailShareSubject: String {
        return title
    }
    
    var emailShareBody: String {
        var shareContent = body
        guard let urlString = url?.absoluteString else { return shareContent }
        if !shareContent.isEmpty {
            shareContent += ":\n"
        }
        return shareContent + urlString
    }

    let emailShareIsHtml = false

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = title
        shareContent.contentDescription = body
        if let actualURL = url {
            shareContent.contentURL = actualURL
        }
        if let actualImageURL = imageURL {
            shareContent.imageURL = actualImageURL
        }
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(shareText)
        twitterComposer.setURL(url)
        return twitterComposer
    }
}

struct AppShareSocialMessage: SocialMessage {

    let url: NSURL?

    var whatsappShareText: String {
        return shareText
    }

    var telegramShareText: String {
        return shareText
    }

    var nativeShareText: String {
        return shareText
    }

    private var shareText: String {
        var shareBody = LGLocalizedString.appShareMessageText
        guard let urlString = url?.absoluteString else { return shareBody }
        shareBody += ":\n"
        return shareBody + urlString
    }

    func branchShareUrl(channel: String) -> String {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "app")
        branchUniversalObject.title = LGLocalizedString.appShareSubjectText
        branchUniversalObject.contentDescription = LGLocalizedString.appShareMessageText
        if let canonicalUrl = url?.absoluteString {
            branchUniversalObject.canonicalUrl = canonicalUrl
        }
        branchUniversalObject.imageUrl = Constants.facebookAppInvitePreviewImageURL
        branchUniversalObject.addMetadataKey("type", value: "app")

        let linkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        linkProperties.channel = channel
        guard let result = branchUniversalObject.getShortUrlWithLinkProperties(linkProperties)
            else { return "" }
        return result
    }

    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }

    var emailShareBody: String {
        var shareBody = LGLocalizedString.appShareMessageText
        guard let urlString = url?.absoluteString else { return shareBody }
        shareBody += ":\n\n"
        return shareBody + "<a href=\"" + urlString + "\">"+LGLocalizedString.appShareDownloadText+"</a>"
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.appShareSubjectText
        shareContent.contentDescription = LGLocalizedString.appShareMessageText
        shareContent.contentURL = url
        shareContent.imageURL = NSURL(string: Constants.facebookAppInvitePreviewImageURL)
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(shareText)
        twitterComposer.setURL(url)
        return twitterComposer
    }
}

struct CommercializerSocialMessage: SocialMessage {

    let url: NSURL?
    let thumbUrl: NSURL?
    let utmMediumKey = "utm_medium"
    let utmSourceKey = "utm_source"
    let utmMediumValue = "letgo_app"


    init(shareUrl: String, thumbUrl: String?) {
        self.url = NSURL(string: shareUrl)
        self.thumbUrl = NSURL(string: thumbUrl ?? "")
    }

    private func shareText(utmSource: CommercializerUTMSource?) -> String {
        var shareBody = LGLocalizedString.commercializerShareMessageText
        guard let urlString = url?.absoluteString else { return shareBody }
        shareBody += ":\n"
        return shareBody + completeURL(urlString, withSource: utmSource)
    }

    func branchShareUrl(channel: String) -> String {
        return ""
    }

    var emailShareSubject: String {
        return LGLocalizedString.commercializerShareSubjectText
    }

    var emailShareBody: String {
        var shareBody = LGLocalizedString.commercializerShareMessageText
        guard let urlString = url?.absoluteString else { return shareBody }
        shareBody += ":\n\n"
        return shareBody + completeURL(urlString, withSource: .Email)
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.commercializerShareSubjectText
        shareContent.contentDescription = LGLocalizedString.commercializerShareMessageText
        shareContent.contentURL = url //completeURL(url, withSource: .Facebook)
        shareContent.imageURL = thumbUrl
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.commercializerShareSubjectText
        shareContent.contentDescription = LGLocalizedString.commercializerShareMessageText
        shareContent.contentURL = url //completeURL(url, withSource: .FBMessenger)
        shareContent.imageURL = thumbUrl
        return shareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(shareText(.Twitter))
        twitterComposer.setURL(completeURL(url, withSource: .Twitter))
        return twitterComposer
    }

    private func completeURL(url: NSURL?, withSource source: CommercializerUTMSource?) -> NSURL? {
        guard let urlString = url?.absoluteString else { return url }
        return NSURL(string: completeURL(urlString, withSource: source))
    }

    private func completeURL(url: String, withSource source: CommercializerUTMSource?) -> String {
        guard let sourceValue = source?.rawValue else { return url }
        return  url + "?" + utmMediumKey + "=" + utmMediumValue + "&" + utmSourceKey + "=" + sourceValue
    }

    var whatsappShareText: String {
        return shareText(.Whatsapp)
    }

    var telegramShareText: String {
        return shareText(.Telegram)
    }

    var nativeShareText: String {
        return shareText(nil)
    }
}

final class SocialHelper {
    
    /**
        Returns a social message for the given product with a title.
    
        - parameter title: The title
        - parameter product: The product
        - returns: The social message.
    */
    static func socialMessageWithTitle(title: String, product: Product) -> SocialMessage {
        return ProductSocialMessage(title: title, product: product)
    }

    static func socialMessageAppShare(shareUrl: String) -> SocialMessage {
        let url = NSURL(string: shareUrl)
        return AppShareSocialMessage(url: url)
    }

    static func socialMessageCommercializer(shareUrl: String, thumbUrl: String?) -> SocialMessage {
        return CommercializerSocialMessage(shareUrl: shareUrl, thumbUrl: thumbUrl)
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
        return MFMailComposeViewController.canSendMail()
    }

    static func canShareInTelegram() -> Bool {
        guard let url = NSURL(string: "tg://") else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }
}
