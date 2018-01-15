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


// MARK: - Listing Share

struct ListingSocialMessage: SocialMessage {

    private let title: String
    private let listingUserName: String
    private let listingTitle: String
    private let listingDescription: String
    private let imageURL: URL?
    private let listingId: String
    private let isMine: Bool
    private let fallbackToStore: Bool
    static var utmCampaignValue = "product-detail-share"

    init(title: String, listing: Listing, isMine: Bool, fallbackToStore: Bool) {
        self.title = title
        self.listingUserName = listing.user.name ?? ""
        self.listingTitle = listing.title ?? ""
        self.imageURL = listing.images.first?.fileURL ?? listing.thumbnail?.fileURL
        self.listingId = listing.objectId ?? ""
        self.listingDescription = listing.description ?? ""
        self.isMine = isMine
        self.fallbackToStore = fallbackToStore
    }
    
    init(listing: Listing, fallbackToStore: Bool) {
        let listingIsMine = Core.myUserRepository.myUser?.objectId == listing.user.objectId
        let socialTitleMyListing = listing.price.isFree ? LGLocalizedString.productIsMineShareBodyFree :
            LGLocalizedString.productIsMineShareBody
        let socialTitle = listingIsMine ? socialTitleMyListing : LGLocalizedString.productShareBody
        self.init(title: socialTitle, listing: listing, isMine: listingIsMine, fallbackToStore: fallbackToStore)
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
        return LGLocalizedString.productShareTitleOnLetgo(listingTitle)
    }

    var emailShareBody: String {
        guard let urlString = shareUrl(.email)?.absoluteString else { return title }
        var message = title + " " + urlString
        if !isMine {
            message += " " + LGLocalizedString.productSharePostedBy(listingUserName)
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
        if let actualURL = shareUrl(source) {
            shareContent.contentURL = actualURL
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
        var body = listingTitle
        if !isMine {
            body += " " + LGLocalizedString.productSharePostedBy(listingUserName)
        }
        return body
    }

    private func shareUrl(_ source: ShareSource?) -> URL? {
        return branchUrl(source)
    }

    private func branchUrl(_ source: ShareSource?) -> URL? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        let linkProperties = branchLinkProperties(source)
        guard let branchUrl = branchObject.getShortUrl(with: linkProperties)
            else { return LetgoURLHelper.buildHomeURL() }
        return URL(string: branchUrl)
    }

    private var letgoUrl: URL? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        return LetgoURLHelper.buildProductURL(listingId: listingId)
    }

    private var branchObject: BranchUniversalObject {
        let branchUniversalObject: BranchUniversalObject =
            BranchUniversalObject(canonicalIdentifier: "products/"+listingId)
        branchUniversalObject.title = title
        branchUniversalObject.contentDescription = body()
        branchUniversalObject.canonicalUrl = Constants.branchWebsiteURL+"/products/"+listingId
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
        let controlParamString = addCampaignInfoToString("product/"+listingId, source: source)
        linkProperties.addControlParam("$deeplink_path", withValue: controlParamString)
        if var letgoUrlString = letgoUrl?.absoluteString {

            let iosUrl = fallbackToStore ? addCampaignInfoToString(Constants.appStoreURL, source: source) :
                                            letgoUrlString
            let androidUrl = fallbackToStore ? addCampaignInfoToString(Constants.playStoreURL, source: source) :
                                            letgoUrlString

            letgoUrlString = addCampaignInfoToString(letgoUrlString, source: source)
            linkProperties.addControlParam("$fallback_url", withValue: letgoUrlString)
            linkProperties.addControlParam("$desktop_url", withValue: letgoUrlString)
            linkProperties.addControlParam("$ios_url", withValue: iosUrl)
            linkProperties.addControlParam("$android_url", withValue: androidUrl)
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
        shareContent.contentURL = branchUrl(.facebook)
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
        shareContent.contentURL = branchUrl(.facebook)
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
