//
//  SocialMessage.swift
//  LetGo
//
//  Created by Eli Kohen on 22/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FBSDKShareKit
import TwitterKit
import LGCoreKit
import Branch

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
    var smsShareText: String { get }
    var copyLinkText: String { get }
    var shareUrl: NSURL? { get }
}

public protocol TwitterShareDelegate: class {
    func twitterShareCancelled()
    func twitterShareSuccess()
}


// MARK: - Product Share

struct ProductSocialMessage: SocialMessage {
    let title: String
    let body: String
    let shareUrl: NSURL?
    let imageURL: NSURL?
    let productId: String

    init(title: String, product: Product) {
        self.title = title
        self.body = [product.user.name, product.name ?? product.nameAuto].flatMap{$0}.joinWithSeparator(" - ")
        if let productId = product.objectId {
            self.shareUrl = NSURL(string: String(format: Constants.productURL, arguments: [productId]))
        }
        else {
            self.shareUrl = NSURL(string: Constants.websiteURL)
        }
        self.imageURL = product.images.first?.fileURL ?? product.thumbnail?.fileURL
        self.productId = product.objectId ?? ""
    }

    var whatsappShareText: String {
        return fullMessageWUrl
    }

    var telegramShareText: String {
        return fullMessageWUrl
    }

    var nativeShareText: String {
        return fullMessage
    }

    var smsShareText: String {
        return fullMessageWUrl
    }

    var copyLinkText: String {
        return shareUrl?.absoluteString ?? ""
    }

    func branchShareUrl(channel: String) -> String {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "product/"+productId)
        branchUniversalObject.title = title
        branchUniversalObject.contentDescription = body
        if let canonicalUrl = shareUrl?.absoluteString {
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
        guard let urlString = shareUrl?.absoluteString else { return shareContent }
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
        if let actualURL = shareUrl {
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
        twitterComposer.setText(fullMessage)
        twitterComposer.setURL(shareUrl)
        return twitterComposer
    }

    private var fullMessage: String {
        return title.isEmpty ? body : title + "\n" + body
    }

    private var fullMessageWUrl: String {
        let fullMessage = self.fullMessage.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let urlString = shareUrl?.absoluteString ?? ""
        return fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
    }
}


// MARK: - App Share

struct AppShareSocialMessage: SocialMessage {

    let shareUrl: NSURL?

    var whatsappShareText: String {
        return fullMessageWUrl
    }

    var telegramShareText: String {
        return fullMessageWUrl
    }

    var nativeShareText: String {
        return LGLocalizedString.appShareMessageText
    }

    var smsShareText: String {
        return fullMessageWUrl
    }

    var copyLinkText: String {
        return shareUrl?.absoluteString ?? ""
    }

    func branchShareUrl(channel: String) -> String {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "app")
        branchUniversalObject.title = LGLocalizedString.appShareSubjectText
        branchUniversalObject.contentDescription = LGLocalizedString.appShareMessageText
        if let canonicalUrl = shareUrl?.absoluteString {
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
        guard let urlString = shareUrl?.absoluteString else { return shareBody }
        shareBody += ":\n\n"
        return shareBody + "<a href=\"" + urlString + "\">"+LGLocalizedString.appShareDownloadText+"</a>"
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.appShareSubjectText
        shareContent.contentDescription = LGLocalizedString.appShareMessageText
        shareContent.contentURL = shareUrl
        shareContent.imageURL = NSURL(string: Constants.facebookAppInvitePreviewImageURL)
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(LGLocalizedString.appShareMessageText)
        twitterComposer.setURL(shareUrl)
        return twitterComposer
    }

    private var fullMessageWUrl: String {
        let fullMessage = LGLocalizedString.appShareMessageText
        let urlString = shareUrl?.absoluteString ?? ""
        return fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
    }
}


// MARK: - Commercializer

enum CommercializerUTMSource: String {
    case Facebook = "facebook"
    case Twitter = "twitter"
    case FBMessenger = "facebook_messenger"
    case Whatsapp = "whatsapp"
    case Telegram = "telegram"
    case Email = "email"
    case SMS = "sms"
    case CopyLink = "copy_link"
}

struct CommercializerSocialMessage: SocialMessage {

    let shareUrl: NSURL?
    let thumbUrl: NSURL?
    static let utmMediumKey = "utm_medium"
    static let utmSourceKey = "utm_source"
    static let utmMediumValue = "letgo_app"


    init(shareUrl: String, thumbUrl: String?) {
        self.shareUrl = NSURL(string: shareUrl)
        self.thumbUrl = NSURL(string: thumbUrl ?? "")
    }

    func branchShareUrl(channel: String) -> String {
        return ""
    }

    var emailShareSubject: String {
        return LGLocalizedString.commercializerShareSubjectText
    }

    var emailShareBody: String {
        var shareBody = LGLocalizedString.commercializerShareMessageText
        guard let urlString = shareUrl?.absoluteString else { return shareBody }
        shareBody += ":\n\n"
        return shareBody + completeURL(urlString, withSource: .Email)
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.commercializerShareSubjectText
        shareContent.contentDescription = LGLocalizedString.commercializerShareMessageText
        shareContent.contentURL = completeURL(shareUrl, withSource: .Facebook)
        shareContent.imageURL = thumbUrl
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.commercializerShareSubjectText
        shareContent.contentDescription = LGLocalizedString.commercializerShareMessageText
        shareContent.contentURL = completeURL(shareUrl, withSource: .FBMessenger)
        shareContent.imageURL = thumbUrl
        return shareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(shareText(.Twitter, includeUrl: false))
        twitterComposer.setURL(completeURL(shareUrl, withSource: .Twitter))
        return twitterComposer
    }

    var whatsappShareText: String {
        return shareText(.Whatsapp)
    }

    var telegramShareText: String {
        return shareText(.Telegram)
    }

    var nativeShareText: String {
        return shareText(nil, includeUrl: false)
    }

    var smsShareText: String {
        return shareText(.SMS)
    }

    var copyLinkText: String {
        guard let urlString = shareUrl?.absoluteString else { return "" }
        return completeURL(urlString, withSource: .CopyLink)
    }

    private func shareText(utmSource: CommercializerUTMSource?, includeUrl: Bool = true) -> String {
        var shareBody = LGLocalizedString.commercializerShareMessageText
        guard let urlString = shareUrl?.absoluteString where includeUrl else { return shareBody }
        shareBody += ":\n"
        return shareBody + completeURL(urlString, withSource: utmSource)
    }

    private func completeURL(url: NSURL?, withSource source: CommercializerUTMSource?) -> NSURL? {
        guard let urlString = url?.absoluteString else { return url }
        return NSURL(string: completeURL(urlString, withSource: source))
    }

    private func completeURL(url: String, withSource source: CommercializerUTMSource?) -> String {
        guard let sourceValue = source?.rawValue else { return url }
        return  url + "?" + CommercializerSocialMessage.utmMediumKey + "=" + CommercializerSocialMessage.utmMediumValue +
            "&" + CommercializerSocialMessage.utmSourceKey + "=" + sourceValue
    }
}
