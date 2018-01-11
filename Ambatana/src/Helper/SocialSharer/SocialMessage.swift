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
import AppsFlyerLib

typealias MessageWithURLCompletion = (String) -> ()
typealias NativeShareItemsCompletion = ([Any]) -> ()
typealias FBSDKShareLinkContentCompletion = (FBSDKShareLinkContent) -> ()
typealias TwitterComposerCompletion = (TWTRComposer) -> ()
typealias AppsFlyerGenerateInviteURLCompletion = (URL?) -> ()

protocol SocialMessage {
    var emailShareSubject: String { get }
    var emailShareIsHtml: Bool { get }
    
    static var utmMediumKey: String { get }
    static var utmMediumValue: String { get }
    static var utmCampaignKey: String { get }
    static var utmCampaignValue: String { get }
    static var utmSourceKey: String { get }
    static var utmSourceValue: String { get }
    
    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion)
    func retrieveWhatsappShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion)
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion)
    func retrieveFBShareContent(completion: @escaping FBSDKShareLinkContentCompletion)
    func retrieveFBMessengerShareContent(completion: @escaping FBSDKShareLinkContentCompletion)
    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion)
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
    let emailShareIsHtml = false
    var emailShareSubject: String {
        return LGLocalizedString.productShareTitleOnLetgo(listingTitle)
    }
    private var letgoUrl: URL? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        return LetgoURLHelper.buildProductURL(listingId: listingId)
    }

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
        let socialTitleMyListing = listing.price.free ? LGLocalizedString.productIsMineShareBodyFree :
            LGLocalizedString.productIsMineShareBody
        let socialTitle = listingIsMine ? socialTitleMyListing : LGLocalizedString.productShareBody
        self.init(title: socialTitle, listing: listing, isMine: listingIsMine, fallbackToStore: fallbackToStore)
    }

    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        retrieveShareUrl(.native) { url in
            if let shareUrl = url {
                completion([shareUrl, self.fullMessage()])
            } else {
                completion([self.fullMessage()])
            }
        }
    }
    
    func retrieveWhatsappShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.whatsapp) { message in
            completion(message)
        }
    }
    
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.telegram) { message in
            completion(message)
        }
    }
    
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.sms) { message in
            completion(message)
        }
    }
    
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion) {
        retrieveShareUrl(.copyLink) { url in
            let copyLinkText = url?.absoluteString ?? ""
            completion(copyLinkText)
        }
    }
    
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        retrieveShareUrl(.email) { url in
            if let shareUrl = url {
                let shareUrlString = shareUrl.absoluteString
                var message = self.title + " " + shareUrlString
                if !self.isMine {
                    message += " " + LGLocalizedString.productSharePostedBy(self.listingUserName)
                }
                completion(message)
            } else {
                completion(self.title)
            }
        }
    }

    func retrieveFBShareContent(completion: @escaping FBSDKShareLinkContentCompletion) {
        fbShareLinkContent(.facebook, completion: completion)
    }

    func retrieveFBMessengerShareContent(completion: @escaping FBSDKShareLinkContentCompletion) {
        fbShareLinkContent(.fbMessenger, completion: completion)
    }

    private func fbShareLinkContent(_ source: ShareSource, completion: @escaping FBSDKShareLinkContentCompletion) {
        let shareContent = FBSDKShareLinkContent()
        retrieveShareUrl(source) { url in
            if let url = url {
                shareContent.contentURL = url
            }
            completion(shareContent)
        }
    }

    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion) {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(fullMessage())
        retrieveShareUrl(.twitter) { url in
            twitterComposer.setURL(url)
            completion(twitterComposer)
        }
    }

    private func retrieveFullMessageWUrl(_ source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        retrieveShareUrl(source) { url in
            let urlString = url?.absoluteString ?? ""
            completion(self.title + " " + urlString + " - " + self.body())
        }
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
    
    private func retrieveShareUrl(_ source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        retrieveAppsFlyerUrl(source, completion: completion)
    }
    
    private func retrieveAppsFlyerUrl(_ source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        AppsFlyerShareInviteHelper.generateInviteUrl(linkGenerator: { generator in
            return self.appsFlyerLinkGenerator(generator, source: source)},
                                                     completionHandler: completion)
    }
    
    private func appsFlyerLinkGenerator(_ generator: AppsFlyerLinkGenerator, source: ShareSource?) -> AppsFlyerLinkGenerator {
        generator.setCampaign("product-detail-share")
        if let source = source {
            generator.setChannel(source.rawValue)
        }
        generator.addParameterValue("ios_app", forKey: "site_id")
        let controlParamString = addCampaignInfoToString("product/"+listingId, source: source)
        generator.addParameterValue(controlParamString, forKey: "$deeplink_path")
        if var letgoUrlString = letgoUrl?.absoluteString {
            let iosUrl = fallbackToStore ? addCampaignInfoToString(Constants.appStoreURL, source: source) : letgoUrlString
            let androidUrl = fallbackToStore ? addCampaignInfoToString(Constants.playStoreURL, source: source) : letgoUrlString
            letgoUrlString = addCampaignInfoToString(letgoUrlString, source: source)
            generator.addParameterValue(letgoUrlString, forKey: "$fallback_url")
            generator.addParameterValue(letgoUrlString, forKey: "$desktop_url")
            generator.addParameterValue(iosUrl, forKey: "$ios_url")
            generator.addParameterValue(androidUrl, forKey: "$android_url")
        }
        
        return generator
    }
}


// MARK: - App Share

struct AppShareSocialMessage: SocialMessage {

    private let imageUrl: URL?
    static var utmCampaignValue = "app-invite-friend"
    
    let emailShareIsHtml = true
    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }

    init() {
        imageUrl = URL(string: Constants.facebookAppInvitePreviewImageURL)
    }
    
    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        retrieveShareUrl(.native) { url in
            if let shareUrl = url {
                completion([shareUrl, LGLocalizedString.appShareMessageText])
            } else {
                completion([LGLocalizedString.appShareMessageText])
            }
        }
    }

    func retrieveWhatsappShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.whatsapp) { message in
            completion(message)
        }
    }
    
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.telegram) { message in
            completion(message)
        }
    }
    
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.sms) { message in
            completion(message)
        }
    }
    
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion) {
        retrieveShareUrl(.copyLink) { url in
            let copyLinkText = url?.absoluteString ?? ""
            completion(copyLinkText)
        }
    }

    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        var shareBody = LGLocalizedString.appShareMessageText
        retrieveShareUrl(.email) { url in
            if let shareUrl = url {
                shareBody += ":\n\n"
                let shareUrlString = shareUrl.absoluteString
                let fullBody = shareBody + "<a href=\"" + shareUrlString + "\">"+LGLocalizedString.appShareDownloadText+"</a>"
                completion(fullBody)
            } else {
                completion(shareBody)
            }
        }
    }

    func retrieveFBShareContent(completion: @escaping FBSDKShareLinkContentCompletion) {
        retrieveFBShareLinkContent(.facebook, completion: completion)
    }
    
    func retrieveFBMessengerShareContent(completion: @escaping FBSDKShareLinkContentCompletion) {
        retrieveFBShareLinkContent(.fbMessenger, completion: completion)
    }
    
    private func retrieveFBShareLinkContent(_ source: ShareSource, completion: @escaping FBSDKShareLinkContentCompletion) {
        let shareContent = FBSDKShareLinkContent()
        retrieveShareUrl(source) { url in
            shareContent.contentURL = url
            completion(shareContent)
        }
    }

    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion) {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(LGLocalizedString.appShareMessageText)
        retrieveShareUrl(.twitter) { url in
            twitterComposer.setURL(url)
            completion(twitterComposer)
        }
    }

    private func retrieveFullMessageWUrl(_ source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        let fullMessage = LGLocalizedString.appShareMessageText
        retrieveShareUrl(source) { url in
            let urlString = url?.absoluteString ?? ""
            let fullMessage = fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
            completion(fullMessage)
        }
    }

    private func retrieveShareUrl(_ source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        retrieveAppsFlyerUrl(source, completion: completion)
    }
    
    private func retrieveAppsFlyerUrl(_ source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        AppsFlyerShareInviteHelper.generateInviteUrl(linkGenerator: { generator in
            return self.appsFlyerLinkGenerator(generator, source: source)},
                                                     completionHandler: completion)
    }
    
    private func appsFlyerLinkGenerator(_ generator: AppsFlyerLinkGenerator, source: ShareSource?) -> AppsFlyerLinkGenerator {
        generator.setCampaign(AppShareSocialMessage.utmCampaignValue)
        if let source = source {
            generator.setChannel(source.rawValue)
        }
        generator.addParameterValue("ios_app", forKey: "site_id")
        generator.addParameterValue("home", forKey: "$deeplink_path")
        
        let iosUrl = addCampaignInfoToString(Constants.appStoreURL, source: source)
        let androidUrl = addCampaignInfoToString(Constants.playStoreURL, source: source)
        let letgoUrlString = addCampaignInfoToString(LetgoURLHelper.buildHomeURLString(), source: source)
        generator.addParameterValue(letgoUrlString, forKey: "$fallback_url")
        generator.addParameterValue(letgoUrlString, forKey: "$desktop_url")
        generator.addParameterValue(iosUrl, forKey: "$ios_url")
        generator.addParameterValue(androidUrl, forKey: "$android_url")
        
        return generator
    }
}

// MARK: - User Share

struct UserSocialMessage: SocialMessage {
    static var utmCampaignValue = "profile-share"

    private let userName: String?
    private let avatar: URL?
    private let userId: String
    private let titleText: String
    private let messageText: String
    var emailShareSubject: String {
        return titleText
    }
    let emailShareIsHtml = true
    private var letgoURL: URL? {
        return !userId.isEmpty ? LetgoURLHelper.buildUserURL(userId: userId) : LetgoURLHelper.buildHomeURL()
    }

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

    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        retrieveAppsFlyerUrl(.native) { url in
            if let shareUrl = url {
                completion([shareUrl, self.messageText])
            } else {
                completion([self.messageText])
            }
        }
    }
    
    func retrieveWhatsappShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.whatsapp) { message in
            completion(message)
        }
    }
    
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.telegram) { message in
            completion(message)
        }
    }
    
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWUrl(.sms) { message in
            completion(message)
        }
    }
    
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion) {
        retrieveShareUrl(.copyLink) { url in
            let copyLinkText = url?.absoluteString ?? ""
            completion(copyLinkText)
        }
    }

    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        retrieveAppsFlyerUrl(.email) { url in
            if let shareUrlString = url?.absoluteString {
                completion(self.messageText + "\n\n" + shareUrlString)
            } else {
                completion(self.messageText)
            }
        }
    }

    func retrieveFBShareContent(completion: @escaping FBSDKShareLinkContentCompletion) {
        retrieveFBShareLinkContent(.facebook, completion: completion)
    }
    
    func retrieveFBMessengerShareContent(completion: @escaping FBSDKShareLinkContentCompletion) {
        retrieveFBShareLinkContent(.fbMessenger, completion: completion)
    }
    
    private func retrieveFBShareLinkContent(_ source: ShareSource, completion: @escaping FBSDKShareLinkContentCompletion) {
        let shareContent = FBSDKShareLinkContent()
        retrieveShareUrl(source) { url in
            shareContent.contentURL = url
            completion(shareContent)
        }
    }
    
    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion) {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(LGLocalizedString.appShareMessageText)
        retrieveShareUrl(.twitter) { url in
            twitterComposer.setURL(url)
            completion(twitterComposer)
        }
    }

    private func retrieveFullMessageWUrl(_ source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        retrieveAppsFlyerUrl(source) { url in
            if let urlString = url?.absoluteString {
                completion(self.messageText.isEmpty ? urlString : self.messageText + ":\n" + urlString)
            } else {
                completion(self.messageText)
            }
        }
    }
    
    private func retrieveShareUrl(_ source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        retrieveAppsFlyerUrl(source, completion: completion)
    }
    
    private func retrieveAppsFlyerUrl(_ source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        AppsFlyerShareInviteHelper.generateInviteUrl(linkGenerator: { generator in
            return self.appsFlyerLinkGenerator(generator, source: source)},
                                                     completionHandler: completion)
    }

    private func appsFlyerLinkGenerator(_ generator: AppsFlyerLinkGenerator, source: ShareSource?) -> AppsFlyerLinkGenerator {
        generator.setCampaign(UserSocialMessage.utmCampaignValue)
        if let source = source {
            generator.setChannel(source.rawValue)
        }
        generator.addParameterValue("ios_app", forKey: "site_id")
        generator.addParameterValue("users/\(userId)", forKey: "$deeplink_path")
        
        guard let urlStr = letgoURL?.absoluteString else { return generator }
        let letgoUrlString = addCampaignInfoToString(urlStr, source: source)
        generator.addParameterValue(letgoUrlString, forKey: "$fallback_url")
        generator.addParameterValue(letgoUrlString, forKey: "$desktop_url")
        generator.addParameterValue(letgoUrlString, forKey: "$ios_url")
        generator.addParameterValue(letgoUrlString, forKey: "$android_url")
        
        return generator
    }
}
