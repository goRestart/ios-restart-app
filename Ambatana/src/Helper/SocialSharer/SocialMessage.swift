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
    var nativeShareItems: [AnyObject] { get }
    
    static var utmMediumKey: String { get }
    static var utmMediumValue: String { get }
    static var utmCampaignKey: String { get }
    static var utmCampaignValue: String { get }
    static var utmSourceKey: String { get }
    static var utmSourceValue: String { get }
}

extension SocialMessage {
    static var utmMediumKey: String { return "utm_medium" }
    static var utmSourceKey: String { return "utm_source" }
    static var utmMediumValue: String { return "letgo_app" }
    static var utmCampaignKey: String { return "utm_campaign" }
    static var utmSourceValue: String { return "ios_app" }
    
    func addCampaignInfoToString(string: String, source: ShareSource?) -> String {
        guard !string.isEmpty else { return "" }
        // The share source is the medium for the deeplink
        let mediumValue = source?.rawValue ?? ""
        return string + "?" + Self.utmCampaignKey + "=" + Self.utmCampaignValue + "&" +
            Self.utmMediumKey + "=" + mediumValue + "&" +
            Self.utmSourceKey + "=" + Self.utmSourceValue
    }
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
    case Native = "native"
}


// MARK: - Product Share

struct ProductSocialMessage: SocialMessage {

    private let title: String
    private let productUserName: String
    private let productTitle: String
    private let productDescription: String
    private let imageURL: NSURL?
    private let productId: String
    private let isMine: Bool
    static var utmCampaignValue = "product-detail-share"

    init(title: String, product: Product, isMine: Bool) {
        self.title = title
        self.productUserName = product.user.name ?? ""
        self.productTitle = product.title ?? ""
        self.imageURL = product.images.first?.fileURL ?? product.thumbnail?.fileURL
        self.productId = product.objectId ?? ""
        self.productDescription = product.description ?? ""
        self.isMine = isMine
    }

    init(product: Product) {
        let productIsMine = Core.myUserRepository.myUser?.objectId == product.user.objectId
        let socialTitleMyProduct = product.price.free ? LGLocalizedString.productIsMineShareBodyFree :
            LGLocalizedString.productIsMineShareBody
        let socialTitle = productIsMine ? socialTitleMyProduct : LGLocalizedString.productShareBody
        self.init(title: socialTitle, product: product, isMine: productIsMine)
    }

    var nativeShareItems: [AnyObject] {
        if let shareUrl = shareUrl(.Native) {
            return [shareUrl, fullMessage()]
        } else {
            return [fullMessage()]
        }
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
        return LGLocalizedString.productShareTitleOnLetgo(productTitle)
    }

    var emailShareBody: String {
        guard let urlString = shareUrl(.Email)?.absoluteString else { return title }
        var message = title + " " + urlString
        if !isMine {
            message += " " + LGLocalizedString.productSharePostedBy(productUserName)
        }
        return message
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
        
        shareContent.contentTitle = title + (isMine ? "" : " " + LGLocalizedString.productSharePostedBy(productUserName))
        shareContent.contentDescription = productTitle + (productDescription.isEmpty ? "" : ": " + productDescription)
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
        twitterComposer.setText(fullMessage())
        twitterComposer.setURL(shareUrl(.Twitter))
        return twitterComposer
    }

    private func fullMessageWUrl(source: ShareSource) -> String {
        let urlString = shareUrl(source)?.absoluteString ?? ""
        return title + " " + urlString + " - " + body()
    }
    
    private func fullMessage() -> String {
        return title + " - " + body()
    }
    
    private func body() -> String {
        var body = productTitle
        if !isMine {
            body += " " + LGLocalizedString.productSharePostedBy(productUserName)
        }
        return body
    }

    private func shareUrl(source: ShareSource?) -> NSURL? {
        return branchUrl(source)
    }

    private func branchUrl(source: ShareSource?) -> NSURL? {
        guard !productId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrlWithLinkProperties(linkProperties)
            else { return LetgoURLHelper.buildHomeURL() }
        return NSURL(string: branchUrl)
    }

    private var letgoUrl: NSURL? {
        guard !productId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        return LetgoURLHelper.buildProductURL(productId: productId)
    }

    private var branchObject: BranchUniversalObject {
        let branchUniversalObject: BranchUniversalObject =
            BranchUniversalObject(canonicalIdentifier: "products/"+productId)
        branchUniversalObject.title = title
        branchUniversalObject.contentDescription = body()
        branchUniversalObject.canonicalUrl = Constants.branchWebsiteURL+"/products/"+productId
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
        let controlParamString = addCampaignInfoToString("product/"+productId, source: source)
        linkProperties.addControlParam("$deeplink_path", withValue: controlParamString)
        if var letgoUrlString = letgoUrl?.absoluteString {
            letgoUrlString = addCampaignInfoToString(letgoUrlString, source: source)
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

    private let imageUrl: NSURL?
    static var utmCampaignValue = "app-invite-friend"

    init() {
        imageUrl = NSURL(string: Constants.facebookAppInvitePreviewImageURL)
    }

    var nativeShareItems: [AnyObject] {
        if let shareUrl = branchUrl(.Native) {
            return [shareUrl, LGLocalizedString.appShareMessageText]
        } else {
            return [LGLocalizedString.appShareMessageText]
        }
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
        return branchUrl(.CopyLink)?.absoluteString ?? ""
    }

    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }

    var emailShareBody: String {
        var shareBody = LGLocalizedString.appShareMessageText
        guard let urlString = branchUrl(.Email)?.absoluteString else { return shareBody }
        shareBody += ":\n\n"
        return shareBody + "<a href=\"" + urlString + "\">"+LGLocalizedString.appShareDownloadText+"</a>"
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.appShareSubjectText
        shareContent.contentDescription = LGLocalizedString.appShareMessageText
        shareContent.contentURL = branchUrl(.Facebook)
        shareContent.imageURL = imageUrl
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(LGLocalizedString.appShareMessageText)
        twitterComposer.setURL(branchUrl(.Twitter))
        return twitterComposer
    }
    
    private func fullMessageWUrl(source: ShareSource) -> String {
        let fullMessage = LGLocalizedString.appShareMessageText
        let urlString = branchUrl(source)?.absoluteString ?? ""
        return fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
    }
    
    private func branchUrl(source: ShareSource?) -> NSURL? {
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrlWithLinkProperties(linkProperties)
            else { return LetgoURLHelper.buildHomeURL() }
        return NSURL(string: branchUrl)
    }
    
    private var branchObject: BranchUniversalObject {
        let branchUniversalObject: BranchUniversalObject =
            BranchUniversalObject(canonicalIdentifier: "app_share")
        branchUniversalObject.title = LGLocalizedString.appShareSubjectText
        branchUniversalObject.contentDescription = LGLocalizedString.appShareMessageText
        branchUniversalObject.canonicalUrl = Constants.branchWebsiteURL
        if let imageURL = imageUrl?.absoluteString {
            branchUniversalObject.imageUrl = imageURL
        }
        return branchUniversalObject
    }
    
    private func branchLinkProperties(source: ShareSource?) -> BranchLinkProperties {
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = AppShareSocialMessage.utmCampaignValue
        if let source = source {
            linkProperties.channel = source.rawValue
        }
        linkProperties.tags = ["ios_app"]
        linkProperties.addControlParam("$deeplink_path", withValue: "home")
        
        let letgoUrlString = addCampaignInfoToString(LetgoURLHelper.buildHomeURLString(), source: source)
        let letgoUrlStringAppStore = addCampaignInfoToString(Constants.appStoreURL, source: source)
        let letgoUrlStringPlayStore = addCampaignInfoToString(Constants.playStoreURL, source: source)
        
        linkProperties.addControlParam("$fallback_url", withValue: letgoUrlString)
        linkProperties.addControlParam("$desktop_url", withValue: letgoUrlString)
        linkProperties.addControlParam("$ios_url", withValue: letgoUrlStringAppStore)
        linkProperties.addControlParam("$android_url", withValue: letgoUrlStringPlayStore)
        return linkProperties
    }
}


// MARK - User

struct UserSocialMessage: SocialMessage {
    static var utmCampaignValue = "profile-share"

    private let userName: String?
    private let avatar: NSURL?
    private let userId: String
    private let titleText: String
    private let messageText: String

    init(user: User, itsMe: Bool) {
        userName = user.name
        avatar = user.avatar?.fileURL
        userId = user.objectId ?? ""
        if itsMe {
            titleText = LGLocalizedString.userShareTitleTextMine
            messageText = LGLocalizedString.userShareMessageMine
        } else if let userName = user.name where !userName.isEmpty {
            titleText = LGLocalizedString.userShareTitleTextOtherWName(userName)
            messageText = LGLocalizedString.userShareMessageOtherWName(userName)
        } else {
            titleText = LGLocalizedString.userShareTitleTextOther
            messageText = LGLocalizedString.userShareMessageOther
        }
    }

    var nativeShareItems: [AnyObject] {
        if let branchUrl = branchUrl(.Native) {
            return [branchUrl, messageText]
        } else {
            return [messageText]
        }
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
        return branchUrl(.CopyLink)?.absoluteString ?? ""
    }

    var emailShareSubject: String {
        return titleText
    }

    var emailShareBody: String {
        guard let urlStr = branchUrl(.Email)?.absoluteString else {
            return messageText
        }
        return messageText + "\n\n" + urlStr
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = titleText
        shareContent.contentDescription = messageText
        shareContent.contentURL = branchUrl(.Facebook)
        shareContent.imageURL = avatar
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(messageText)
        twitterComposer.setURL(branchUrl(.Twitter))
        return twitterComposer
    }

    private func fullMessageWUrl(source: ShareSource) -> String {
        guard let urlString = branchUrl(source)?.absoluteString else {
            return messageText
        }
        return messageText.isEmpty ? urlString : messageText + ":\n" + urlString
    }

    private var letgoURL: NSURL? {
        return !userId.isEmpty ? LetgoURLHelper.buildUserURL(userId: userId) : LetgoURLHelper.buildHomeURL()
    }

    private func branchUrl(source: ShareSource?) -> NSURL? {
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrlWithLinkProperties(linkProperties) else { return letgoURL }
        return NSURL(string: branchUrl) ?? letgoURL
    }

    private var branchObject: BranchUniversalObject {
        let branchUniversalObject: BranchUniversalObject =
            BranchUniversalObject(canonicalIdentifier: "users/\(userId)")
        branchUniversalObject.title = titleText
        branchUniversalObject.contentDescription = messageText
        branchUniversalObject.canonicalUrl = Constants.branchWebsiteURL+"/users/"+userId
        if let imageURL = avatar?.absoluteString {
            branchUniversalObject.imageUrl = imageURL
        }
        return branchUniversalObject
    }

    private func branchLinkProperties(source: ShareSource?) -> BranchLinkProperties {
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = UserSocialMessage.utmCampaignValue
        if let source = source {
            linkProperties.channel = source.rawValue
        }
        linkProperties.tags = ["ios_app"]
        linkProperties.addControlParam("$deeplink_path", withValue: "users/\(userId)")

        guard let urlStr = letgoURL?.absoluteString else { return linkProperties }

        let letgoUrlString = addCampaignInfoToString(urlStr, source: source)
        linkProperties.addControlParam("$fallback_url", withValue: letgoUrlString)
        linkProperties.addControlParam("$desktop_url", withValue: letgoUrlString)
        linkProperties.addControlParam("$ios_url", withValue: letgoUrlString)
        linkProperties.addControlParam("$android_url", withValue: letgoUrlString)
        return linkProperties
    }
}


// MARK: - Commercializer

struct CommercializerSocialMessage: SocialMessage {

    private let shareUrl: NSURL?
    private let thumbUrl: NSURL?
    static var utmCampaignValue = "product-detail-share"

    init(shareUrl: String, thumbUrl: String?) {
        self.shareUrl = NSURL(string: shareUrl)
        self.thumbUrl = NSURL(string: thumbUrl ?? "")
    }

    var nativeShareItems: [AnyObject] {
        let shareTxt = shareText(nil, includeUrl: false)
        if let shareUrl = shareUrl {
            return [shareUrl, shareTxt]
        } else {
            return [shareTxt]
        }
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
