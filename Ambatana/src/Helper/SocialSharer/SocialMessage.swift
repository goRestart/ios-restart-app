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


// MARK: - ShareSource

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


// MARK: - SocialMessage

protocol SocialMessage {
    var emailShareSubject: String { get }
    var emailShareIsHtml: Bool { get }
    var fallbackToStore: Bool { get }
    
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
    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion)
    func retrieveFBShareContent(completion: @escaping FBSDKShareLinkContentCompletion)
    func retrieveFBMessengerShareContent(completion: @escaping FBSDKShareLinkContentCompletion)
    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion)
    func retrieveTwitterComposer(text: String, completion: @escaping TwitterComposerCompletion)
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion)
}

extension SocialMessage {
    
    static var utmMediumKey: String { return "utm_medium" }
    static var utmSourceKey: String { return "utm_source" }
    static var utmMediumValue: String { return "letgo_app" }
    static var utmCampaignKey: String { return "utm_campaign" }
    static var utmSourceValue: String { return "ios_app" }

    
    // MARK: - Mediums
    
    func retrieveWhatsappShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWithURL(source: .whatsapp) { message in
            completion(message)
        }
    }
    
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWithURL(source: .telegram) { message in
            completion(message)
        }
    }
    
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWithURL(source: .sms) { message in
            completion(message)
        }
    }
    
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: .copyLink) { url in
            let copyLinkText = url?.absoluteString ?? ""
            completion(copyLinkText)
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
        retrieveShareURL(source: source) { url in
            if let url = url {
                shareContent.contentURL = url
            }
            completion(shareContent)
        }
    }
    
    func retrieveTwitterComposer(text: String, completion: @escaping TwitterComposerCompletion) {
        let twitterComposer = TWTRComposer()
        twitterComposer.setText(text)
        retrieveShareURL(source: .twitter) { url in
            twitterComposer.setURL(url)
            completion(twitterComposer)
        }
    }
    
    
    // MARK: AppsFlyer
    
    func retrieveShareURL(source: ShareSource?, campaign: String, controlParameter: String, letgoURLString: String?,
                          fallbackToStore: Bool, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        AppsFlyerShareInviteHelper.generateInviteUrl(linkGenerator: { generator in
            return self.appsFlyerLinkGenerator(generator,
                                               source: source,
                                               campaign: campaign,
                                               controlParameter: controlParameter,
                                               letgoURLString: letgoURLString,
                                               fallbackToStore: fallbackToStore)},
                                                     completionHandler: completion)
    }
    
    private func appsFlyerLinkGenerator(_ generator: AppsFlyerLinkGenerator, source: ShareSource?, campaign: String,
                                controlParameter: String, letgoURLString: String?, fallbackToStore: Bool) -> AppsFlyerLinkGenerator {
        generator.setCampaign(campaign)
        if let source = source {
            generator.setChannel(source.rawValue)
        }
        generator.addParameterValue("ios_app", forKey: "site_id")
        generator.addParameterValue(controlParameter, forKey: "$deeplink_path")
        if var letgoURLString = letgoURLString {
            let iosURL = fallbackToStore ? addCampaignInfoToString(Constants.appStoreURL, source: source) : letgoURLString
            let androidURL = fallbackToStore ? addCampaignInfoToString(Constants.playStoreURL, source: source) : letgoURLString
            letgoURLString = addCampaignInfoToString(letgoURLString, source: source)
            generator.addParameterValue(letgoURLString, forKey: "$fallback_url")
            generator.addParameterValue(letgoURLString, forKey: "$desktop_url")
            generator.addParameterValue(iosURL, forKey: "$ios_url")
            generator.addParameterValue(androidURL, forKey: "$android_url")
        }
        
        return generator
    }
    
    
    // MARK: - Helpers
    
    func addCampaignInfoToString(_ string: String, source: ShareSource?) -> String {
        guard !string.isEmpty else { return "" }
        // The share source is the medium for the deeplink
        let mediumValue = source?.rawValue ?? ""
        return string + "?" + Self.utmCampaignKey + "=" + Self.utmCampaignValue + "&" +
            Self.utmMediumKey + "=" + mediumValue + "&" +
            Self.utmSourceKey + "=" + Self.utmSourceValue
    }
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
    static var utmCampaignValue = "product-detail-share"
    let emailShareIsHtml = false
    var emailShareSubject: String {
        return LGLocalizedString.productShareTitleOnLetgo(listingTitle)
    }
    private var letgoUrl: URL? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        return LetgoURLHelper.buildProductURL(listingId: listingId)
    }
    let fallbackToStore: Bool

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
        retrieveShareURL(source: .native) { url in
            if let shareUrl = url {
                completion([shareUrl, self.fullMessage()])
            } else {
                completion([self.fullMessage()])
            }
        }
    }
    
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: .email) { url in
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

    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: source) { url in
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
    
    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion) {
        retrieveTwitterComposer(text: fullMessage(), completion: completion)
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        retrieveShareURL(source: source,
                         campaign: "product-detail-share",
                         controlParameter: "product/"+listingId,
                         letgoURLString: letgoUrl?.absoluteString,
                         fallbackToStore: fallbackToStore,
                         completion: completion)
    }
}


// MARK: - App Share

struct AppShareSocialMessage: SocialMessage {

    private let imageURL: URL?
    static var utmCampaignValue = "app-invite-friend"
    
    let emailShareIsHtml = true
    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }
    let fallbackToStore = true

    init() {
        imageURL = URL(string: Constants.facebookAppInvitePreviewImageURL)
    }
    
    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        retrieveShareURL(source: .native) { url in
            if let shareUrl = url {
                completion([shareUrl, LGLocalizedString.appShareMessageText])
            } else {
                completion([LGLocalizedString.appShareMessageText])
            }
        }
    }

    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        var shareBody = LGLocalizedString.appShareMessageText
        retrieveShareURL(source: .email) { url in
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

    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion) {
        retrieveTwitterComposer(text: LGLocalizedString.appShareMessageText, completion: completion)
    }

    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        let fullMessage = LGLocalizedString.appShareMessageText
        retrieveShareURL(source: source) { url in
            let urlString = url?.absoluteString ?? ""
            let fullMessage = fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
            completion(fullMessage)
        }
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        retrieveShareURL(source: source,
                         campaign: AppShareSocialMessage.utmCampaignValue,
                         controlParameter: "home",
                         letgoURLString: LetgoURLHelper.buildHomeURLString(),
                         fallbackToStore: fallbackToStore,
                         completion: completion)
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
    let fallbackToStore = false
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
        retrieveShareURL(source: .native) { url in
            if let shareUrl = url {
                completion([shareUrl, self.messageText])
            } else {
                completion([self.messageText])
            }
        }
    }
    
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWithURL(source: .telegram) { message in
            completion(message)
        }
    }
    
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWithURL(source: .sms) { message in
            completion(message)
        }
    }
    
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: .copyLink) { url in
            let copyLinkText = url?.absoluteString ?? ""
            completion(copyLinkText)
        }
    }

    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: .email) { url in
            if let shareUrlString = url?.absoluteString {
                completion(self.messageText + "\n\n" + shareUrlString)
            } else {
                completion(self.messageText)
            }
        }
    }
    
    func retrieveTwitterComposer(completion: @escaping TwitterComposerCompletion) {
        retrieveTwitterComposer(text: LGLocalizedString.appShareMessageText, completion: completion)
    }

    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: source) { url in
            if let urlString = url?.absoluteString {
                completion(self.messageText.isEmpty ? urlString : self.messageText + ":\n" + urlString)
            } else {
                completion(self.messageText)
            }
        }
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        retrieveShareURL(source: source,
                         campaign: UserSocialMessage.utmCampaignValue,
                         controlParameter: "users/\(userId)",
                         letgoURLString: letgoURL?.absoluteString,
                         fallbackToStore: fallbackToStore,
                         completion: completion)
    }
}
