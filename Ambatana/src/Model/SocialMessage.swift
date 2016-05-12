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
    var emailShareSubject: String { get }
    var emailShareBody: String { get }
    var emailShareIsHtml: Bool { get }
    var fbShareContent: FBSDKShareLinkContent { get }
    var fbMessengerShareContent: FBSDKShareLinkContent { get }
    var twitterComposer: TWTRComposer { get }
    var smsShareText: String { get }
    var copyLinkText: String { get }
    var nativeShareItems: [AnyObject]? { get }
}

public protocol TwitterShareDelegate: class {
    func twitterShareCancelled()
    func twitterShareSuccess()
}

enum ShareSource: String {
    case Facebook = "facebook"
    case Twitter = "twitter"
    case FBMessenger = "facebook_messenger"
    case Whatsapp = "whatsapp"
    case Telegram = "telegram"
    case Email = "email"
    case SMS = "sms"
    case CopyLink = "copy_link"
}


// MARK: - Product Share

struct ProductSocialMessage: SocialMessage {

    private static let BRANCH_URLS = true

    private let title: String
    private let body: String
    private let imageURL: NSURL?
    private let productId: String

    init(title: String, product: Product) {
        self.title = title
        self.body = [product.user.name, product.name ?? product.nameAuto].flatMap{$0}.joinWithSeparator(" - ")
        self.imageURL = product.images.first?.fileURL ?? product.thumbnail?.fileURL
        self.productId = product.objectId ?? ""
    }

    var nativeShareItems: [AnyObject]? {
        guard let shareUrl = shareUrl(nil) else { return nil }
        return [shareUrl, fullMessage]
    }

    var whatsappShareText: String {
        return fullMessageWUrl(.Whatsapp)
    }

    var telegramShareText: String {
        return fullMessageWUrl(.Telegram)
    }

    var smsShareText: String {
        return fullMessageWUrl(.SMS)
    }

    var copyLinkText: String {
        return shareUrl(.CopyLink)?.absoluteString ?? ""
    }

    var emailShareSubject: String {
        return title
    }

    var emailShareBody: String {
        var shareContent = body
        guard let urlString = shareUrl(.Email)?.absoluteString else { return shareContent }
        if !shareContent.isEmpty {
            shareContent += ":\n"
        }
        return shareContent + urlString
    }

    let emailShareIsHtml = false

    var fbShareContent: FBSDKShareLinkContent {
        return fbShareLinkContent(.Facebook)
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareLinkContent(.FBMessenger)
    }

    private func fbShareLinkContent(source: ShareSource) -> FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = title
        shareContent.contentDescription = body
        if let actualURL = shareUrl(source) {
            shareContent.contentURL = actualURL
        }
        if let actualImageURL = imageURL {
            shareContent.imageURL = actualImageURL
        }
        return shareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(fullMessage)
        twitterComposer.setURL(shareUrl(.Twitter))
        return twitterComposer
    }

    private var fullMessage: String {
        return title.isEmpty ? body : title + "\n" + body
    }

    private func fullMessageWUrl(source: ShareSource) -> String {
        let fullMessage = self.fullMessage.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let urlString = shareUrl(source)?.absoluteString ?? ""
        return fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
    }

    private func shareUrl(source: ShareSource?) -> NSURL? {
        return ProductSocialMessage.BRANCH_URLS ? branchUrl(source) : letgoUrl
    }

    private func branchUrl(source: ShareSource?) -> NSURL? {
        guard !productId.isEmpty else { return NSURL(string: Constants.websiteURL) }
        let linkProperties = branchLinkProperties(nil)
        guard let branchUrl = branchObject.getShortUrlWithLinkProperties(linkProperties)
            else { return NSURL(string: Constants.websiteURL) }
        return NSURL(string: branchUrl)
    }

    private var letgoUrl: NSURL? {
        guard !productId.isEmpty else { return NSURL(string: Constants.websiteURL) }
        return NSURL(string: String(format: Constants.productURL, arguments: [productId]))
    }

    private var branchObject: BranchUniversalObject {
        let branchUniversalObject: BranchUniversalObject =
            BranchUniversalObject(canonicalIdentifier: "products/"+productId)
        branchUniversalObject.title = title
        branchUniversalObject.contentDescription = body
        branchUniversalObject.canonicalUrl = Constants.appWebsiteURL+"/products/"+productId
        if let imageURL = imageURL?.absoluteString {
            branchUniversalObject.imageUrl = imageURL
        }
        return branchUniversalObject
    }

    private func branchLinkProperties(source: ShareSource?) -> BranchLinkProperties {
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = "product-detail-share"
        if let source = source {
            linkProperties.channel = source.rawValue
        }
        linkProperties.tags = ["ios_app"]
        linkProperties.addControlParam("$deeplink_path", withValue: "product/"+productId)
        if let letgoUrlString = letgoUrl?.absoluteString {
            linkProperties.addControlParam("$fallback_url", withValue: letgoUrlString)
            linkProperties.addControlParam("$desktop_url", withValue: letgoUrlString)
            linkProperties.addControlParam("$ios_url", withValue: letgoUrlString)
            linkProperties.addControlParam("$android_url", withValue: letgoUrlString)
        }
        return linkProperties
    }
}


// MARK: - App Share

struct AppShareSocialMessage: SocialMessage {

    let shareUrl: NSURL?

    var nativeShareItems: [AnyObject]? {
        guard let shareUrl = shareUrl else { return nil }
        return [shareUrl, LGLocalizedString.appShareMessageText]
    }

    var whatsappShareText: String {
        return fullMessageWUrl
    }

    var telegramShareText: String {
        return fullMessageWUrl
    }

    var smsShareText: String {
        return fullMessageWUrl
    }

    var copyLinkText: String {
        return shareUrl?.absoluteString ?? ""
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

struct CommercializerSocialMessage: SocialMessage {

    private let shareUrl: NSURL?
    private let thumbUrl: NSURL?
    static let utmMediumKey = "utm_medium"
    static let utmSourceKey = "utm_source"
    static let utmMediumValue = "letgo_app"


    init(shareUrl: String, thumbUrl: String?) {
        self.shareUrl = NSURL(string: shareUrl)
        self.thumbUrl = NSURL(string: thumbUrl ?? "")
    }

    var nativeShareItems: [AnyObject]? {
        guard let shareUrl = shareUrl else { return nil }
        return [shareUrl, shareText(nil, includeUrl: false)]
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

    var smsShareText: String {
        return shareText(.SMS)
    }

    var copyLinkText: String {
        guard let urlString = shareUrl?.absoluteString else { return "" }
        return completeURL(urlString, withSource: .CopyLink)
    }

    private func shareText(utmSource: ShareSource?, includeUrl: Bool = true) -> String {
        var shareBody = LGLocalizedString.commercializerShareMessageText
        guard let urlString = shareUrl?.absoluteString where includeUrl else { return shareBody }
        shareBody += ":\n"
        return shareBody + completeURL(urlString, withSource: utmSource)
    }

    private func completeURL(url: NSURL?, withSource source: ShareSource?) -> NSURL? {
        guard let urlString = url?.absoluteString else { return url }
        return NSURL(string: completeURL(urlString, withSource: source))
    }

    private func completeURL(url: String, withSource source: ShareSource?) -> String {
        guard let sourceValue = source?.rawValue else { return url }
        return  url + "?" + CommercializerSocialMessage.utmMediumKey + "=" + CommercializerSocialMessage.utmMediumValue +
            "&" + CommercializerSocialMessage.utmSourceKey + "=" + sourceValue
    }
}
