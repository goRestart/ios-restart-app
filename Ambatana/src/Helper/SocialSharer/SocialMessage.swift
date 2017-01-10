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

protocol SocialMessage {
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
    var nativeShareItems: [Any] { get }
    
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
    
    func addCampaignInfoToString(_ string: String, source: ShareSource?) -> String {
        guard !string.isEmpty else { return "" }
        // The share source is the medium for the deeplink
        let mediumValue = source?.rawValue ?? ""
        return string + "?" + Self.utmCampaignKey + "=" + Self.utmCampaignValue + "&" +
            Self.utmMediumKey + "=" + mediumValue + "&" +
            Self.utmSourceKey + "=" + Self.utmSourceValue
    }
}

enum ShareSource: String {
    case facebook = "facebook"
    case twitter = "twitter"
    case fbMessenger = "facebook_messenger"
    case whatsapp = "whatsapp"
    case telegram = "telegram"
    case email = "email"
    case sms = "sms"
    case copyLink = "copy_link"
    case native = "native"
}


// MARK: - Product Share

struct ProductSocialMessage: SocialMessage {

    private let title: String
    private let productUserName: String
    private let productTitle: String
    private let productDescription: String
    private let imageURL: URL?
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

    var nativeShareItems: [Any] {
        if let shareUrl = shareUrl(.native) {
            return [shareUrl, fullMessage()]
        } else {
            return [fullMessage()]
        }
    }

    var whatsappShareText: String {
        return fullMessageWUrl(.whatsapp)
    }

    var telegramShareText: String {
        return fullMessageWUrl(.telegram)
    }

    var smsShareText: String {
        return fullMessageWUrl(.sms)
    }

    var copyLinkText: String {
        return shareUrl(.copyLink)?.absoluteString ?? ""
    }

    var emailShareSubject: String {
        return LGLocalizedString.productShareTitleOnLetgo(productTitle)
    }

    var emailShareBody: String {
        guard let urlString = shareUrl(.email)?.absoluteString else { return title }
        var message = title + " " + urlString
        if !isMine {
            message += " " + LGLocalizedString.productSharePostedBy(productUserName)
        }
        return message
    }

    let emailShareIsHtml = false

    var fbShareContent: FBSDKShareLinkContent {
        return fbShareLinkContent(.facebook)
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareLinkContent(.fbMessenger)
    }

    private func fbShareLinkContent(_ source: ShareSource) -> FBSDKShareLinkContent {
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
        twitterComposer.setURL(shareUrl(.twitter))
        return twitterComposer
    }

    private func fullMessageWUrl(_ source: ShareSource) -> String {
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

    private func shareUrl(_ source: ShareSource?) -> URL? {
        return branchUrl(source)
    }

    private func branchUrl(_ source: ShareSource?) -> URL? {
        guard !productId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrl(with: linkProperties)
            else { return LetgoURLHelper.buildHomeURL() }
        return URL(string: branchUrl)
    }

    private var letgoUrl: URL? {
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

    private func branchLinkProperties(_ source: ShareSource?) -> BranchLinkProperties {
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

    private let imageUrl: URL?
    static var utmCampaignValue = "app-invite-friend"

    init() {
        imageUrl = URL(string: Constants.facebookAppInvitePreviewImageURL)
    }

    var nativeShareItems: [Any] {
        if let shareUrl = branchUrl(.native) {
            return [shareUrl, LGLocalizedString.appShareMessageText]
        } else {
            return [LGLocalizedString.appShareMessageText]
        }
    }

    var whatsappShareText: String {
        return fullMessageWUrl(.whatsapp)
    }

    var telegramShareText: String {
        return fullMessageWUrl(.telegram)
    }

    var smsShareText: String {
        return fullMessageWUrl(.sms)
    }

    var copyLinkText: String {
        return branchUrl(.copyLink)?.absoluteString ?? ""
    }

    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }

    var emailShareBody: String {
        var shareBody = LGLocalizedString.appShareMessageText
        guard let urlString = branchUrl(.email)?.absoluteString else { return shareBody }
        shareBody += ":\n\n"
        return shareBody + "<a href=\"" + urlString + "\">"+LGLocalizedString.appShareDownloadText+"</a>"
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.appShareSubjectText
        shareContent.contentDescription = LGLocalizedString.appShareMessageText
        shareContent.contentURL = branchUrl(.facebook)
        shareContent.imageURL = imageUrl
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(LGLocalizedString.appShareMessageText)
        twitterComposer.setURL(branchUrl(.twitter))
        return twitterComposer
    }
    
    private func fullMessageWUrl(_ source: ShareSource) -> String {
        let fullMessage = LGLocalizedString.appShareMessageText
        let urlString = branchUrl(source)?.absoluteString ?? ""
        return fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
    }
    
    private func branchUrl(_ source: ShareSource?) -> URL? {
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrl(with: linkProperties)
            else { return LetgoURLHelper.buildHomeURL() }
        return URL(string: branchUrl)
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
    
    private func branchLinkProperties(_ source: ShareSource?) -> BranchLinkProperties {
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
    private let avatar: URL?
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
        } else if let userName = user.name, !userName.isEmpty {
            titleText = LGLocalizedString.userShareTitleTextOtherWName(userName)
            messageText = LGLocalizedString.userShareMessageOtherWName(userName)
        } else {
            titleText = LGLocalizedString.userShareTitleTextOther
            messageText = LGLocalizedString.userShareMessageOther
        }
    }

    var nativeShareItems: [Any] {
        if let branchUrl = branchUrl(.native) {
            return [branchUrl, messageText]
        } else {
            return [messageText]
        }
    }

    var whatsappShareText: String {
        return fullMessageWUrl(.whatsapp)
    }

    var telegramShareText: String {
        return fullMessageWUrl(.telegram)
    }

    var smsShareText: String {
        return fullMessageWUrl(.sms)
    }

    var copyLinkText: String {
        return branchUrl(.copyLink)?.absoluteString ?? ""
    }

    var emailShareSubject: String {
        return titleText
    }

    var emailShareBody: String {
        guard let urlStr = branchUrl(.email)?.absoluteString else {
            return messageText
        }
        return messageText + "\n\n" + urlStr
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = titleText
        shareContent.contentDescription = messageText
        shareContent.contentURL = branchUrl(.facebook)
        shareContent.imageURL = avatar
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        return fbShareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(messageText)
        twitterComposer.setURL(branchUrl(.twitter))
        return twitterComposer
    }

    private func fullMessageWUrl(_ source: ShareSource) -> String {
        guard let urlString = branchUrl(source)?.absoluteString else {
            return messageText
        }
        return messageText.isEmpty ? urlString : messageText + ":\n" + urlString
    }

    private var letgoURL: URL? {
        return !userId.isEmpty ? LetgoURLHelper.buildUserURL(userId: userId) : LetgoURLHelper.buildHomeURL()
    }

    private func branchUrl(_ source: ShareSource?) -> URL? {
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrl(with: linkProperties) else { return letgoURL }
        return URL(string: branchUrl) ?? letgoURL
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

    private func branchLinkProperties(_ source: ShareSource?) -> BranchLinkProperties {
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

    private let shareUrl: URL?
    private let thumbUrl: URL?
    static var utmCampaignValue = "product-detail-share"

    init(shareUrl: String, thumbUrl: String?) {
        self.shareUrl = URL(string: shareUrl)
        self.thumbUrl = URL(string: thumbUrl ?? "")
    }

    var nativeShareItems: [Any] {
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
        return shareBody + completeURL(urlString, withSource: .email)
    }

    let emailShareIsHtml = true

    var fbShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.commercializerShareSubjectText
        shareContent.contentDescription = LGLocalizedString.commercializerShareMessageText
        shareContent.contentURL = completeURL(shareUrl, withSource: .facebook)
        shareContent.imageURL = thumbUrl
        return shareContent
    }

    var fbMessengerShareContent: FBSDKShareLinkContent {
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentTitle = LGLocalizedString.commercializerShareSubjectText
        shareContent.contentDescription = LGLocalizedString.commercializerShareMessageText
        shareContent.contentURL = completeURL(shareUrl, withSource: .fbMessenger)
        shareContent.imageURL = thumbUrl
        return shareContent
    }

    var twitterComposer: TWTRComposer {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(shareText(.twitter, includeUrl: false))
        twitterComposer.setURL(completeURL(shareUrl, withSource: .twitter))
        return twitterComposer
    }

    var whatsappShareText: String {
        return shareText(.whatsapp)
    }

    var telegramShareText: String {
        return shareText(.telegram)
    }

    var smsShareText: String {
        return shareText(.sms)
    }

    var copyLinkText: String {
        guard let urlString = shareUrl?.absoluteString else { return "" }
        return completeURL(urlString, withSource: .copyLink)
    }

    private func shareText(_ utmSource: ShareSource?, includeUrl: Bool = true) -> String {
        var shareBody = LGLocalizedString.commercializerShareMessageText
        guard let urlString = shareUrl?.absoluteString, includeUrl else { return shareBody }
        shareBody += ":\n"
        return shareBody + completeURL(urlString, withSource: utmSource)
    }

    private func completeURL(_ url: URL?, withSource source: ShareSource?) -> URL? {
        guard let urlString = url?.absoluteString else { return url }
        return URL(string: completeURL(urlString, withSource: source))
    }

    private func completeURL(_ url: String, withSource source: ShareSource?) -> String {
        guard let sourceValue = source?.rawValue else { return url }
        return  url + "?" + CommercializerSocialMessage.utmMediumKey + "=" + CommercializerSocialMessage.utmMediumValue +
            "&" + CommercializerSocialMessage.utmSourceKey + "=" + sourceValue
    }
}
