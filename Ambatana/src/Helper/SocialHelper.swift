//
//  SocialHelper.swift
//  LetGo
//
//  Created by AHL on 16/8/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import MessageUI

public protocol SocialMessage {
    var shareText: String { get }
    var emailShareSubject: String { get }
    var emailShareBody: String { get }
    var fbShareContent: FBSDKShareLinkContent { get }
}

struct ProductSocialMessage: SocialMessage {
    let title: String
    let body: String
    let url: NSURL?
    let imageURL: NSURL?
    
    /** Returns the full sharing content. */
    var shareText: String {
        /*  format:
                <title>
                <body>:     (ideally: "<username> - <product_name>:")
                <url>
        */
        var shareContent = "\(title)"
        if !shareContent.isEmpty {
            shareContent += "\n"
        }
        shareContent += emailShareBody
        return shareContent
    }

    var emailShareSubject: String {
        return title
    }
    
    var emailShareBody: String {
        /*  format:
            <body>:     (ideally: "<username> - <product_name>:")
            <url>
        */
        var shareContent = body
        if let urlString = url?.absoluteString {
            if !shareContent.isEmpty {
                shareContent += ":\n"
            }
            shareContent += urlString
        }
        return shareContent
    }

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
}

struct AppShareSocialMessage: SocialMessage {

    let url: NSURL?

    var shareText: String {
        return emailShareBody
    }

    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }

    var emailShareBody: String {
        var shareBody = LGLocalizedString.appShareMessageText
        if let urlString = url?.absoluteString {
            if !shareBody.isEmpty {
                shareBody += ":\n"
            }
            shareBody += urlString
        }
        return shareBody
    }

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.appShareSubjectText
        shareContent.contentDescription = LGLocalizedString.appShareMessageText
        if let actualURL = url {
            shareContent.contentURL = actualURL
        }
        return shareContent
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
        /* body should be, ideally:
            <username> - <product_name>
            
            or:
            <username>
        
            or:
            <product_name>
        */
        var body: String = ""
        if let username = product.user.name {
            body += username
        }
        if let productName = product.name {
            if !body.isEmpty {
                body += " - "
            }
            body += productName
        }
        var url: NSURL?
        if let productId = product.objectId {
            url = NSURL(string: String(format: Constants.productURL, arguments: [productId]))
        }
        else {
            url = NSURL(string: Constants.websiteURL)
        }
        var imageURL: NSURL?
        if let firstImageURL = product.images.first?.fileURL {
            imageURL = firstImageURL
        }
        else if let thumbURL = product.thumbnail?.fileURL {
            imageURL = thumbURL
        }
        return ProductSocialMessage(title: title, body: body, url: url, imageURL: imageURL)
    }

    static func socialMessageAppShare(shareUrl: String) -> SocialMessage {
        let url = NSURL(string: shareUrl)
        return AppShareSocialMessage(url: url)
    }

    static func shareOnFacebook(socialMessage: SocialMessage, viewController: UIViewController,
        delegate: FBSDKSharingDelegate?) {
            FBSDKShareDialog.showFromViewController(viewController, withContent: socialMessage.fbShareContent,
                delegate: delegate)
    }

    static func shareOnFbMessenger(socialMessage: SocialMessage, delegate: FBSDKSharingDelegate?) {
        FBSDKMessageDialog.showWithContent(socialMessage.fbShareContent, delegate: delegate)
    }

    static func shareOnWhatsapp(socialMessage: SocialMessage, viewController: UIViewController) {
            guard let url = generateWhatsappURL(socialMessage) else { return }

            if !UIApplication.sharedApplication().openURL(url) {
                viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareWhatsappError)
            }
    }

    static func shareOnEmail(socialMessage: SocialMessage, viewController: UIViewController,
        delegate: MFMailComposeViewControllerDelegate?) {
            let isEmailAccountConfigured = MFMailComposeViewController.canSendMail()
            if isEmailAccountConfigured {
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = delegate
                vc.setSubject(socialMessage.emailShareSubject)
                vc.setMessageBody(socialMessage.emailShareBody, isHTML: false)
                viewController.presentViewController(vc, animated: true, completion: nil)
            }
            else {
                viewController.showAutoFadingOutMessageAlert(LGLocalizedString.productShareEmailError)
            }
    }

    static func generateWhatsappURL(socialMessage: SocialMessage) -> NSURL? {
        let queryCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        guard let urlEncodedShareText = socialMessage.shareText
            .stringByAddingPercentEncodingWithAllowedCharacters(queryCharSet) else { return nil }
        return NSURL(string: String(format: Constants.whatsAppShareURL, arguments: [urlEncodedShareText]))
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
}