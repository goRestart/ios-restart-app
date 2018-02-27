//
//  SocialMessage.swift
//  LetGo
//
//  Created by Eli Kohen on 22/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import AppsFlyerLib

typealias MessageWithURLCompletion = (String) -> ()
typealias NativeShareItemsCompletion = ([Any]) -> ()
typealias FBSDKShareLinkContentCompletion = (FBSDKShareLinkContent) -> ()
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
    static var utmMediumKey: String { get }
    static var utmMediumValue: String { get }
    static var utmCampaignKey: String { get }
    static var utmCampaignValue: String { get }
    static var utmSourceKey: String { get }
    static var utmSourceValue: String { get }
    
    var myUserId: String? { get }
    var myUserName: String? { get }
    
    var emailShareSubject: String { get }
    var emailShareIsHtml: Bool { get }
    var fallbackToStore: Bool { get }
    var controlParameter: String { get }
    
    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion)
    func retrieveWhatsappShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveTelegramShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveSMSShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveCopyLinkText(completion: @escaping MessageWithURLCompletion)
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion)
    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion)
    func retrieveFBShareContent(completion: @escaping FBSDKShareLinkContentCompletion)
    func retrieveFBMessengerShareContent(completion: @escaping FBSDKShareLinkContentCompletion)
    func retrieveTwitterShareText(completion: @escaping MessageWithURLCompletion)
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion)
}

extension SocialMessage {
    
    static var utmMediumKey: String { return "utm_medium" }
    static var utmSourceKey: String { return "utm_source" }
    static var utmMediumValue: String { return "letgo_app" }
    static var utmCampaignKey: String { return "utm_campaign" }
    static var utmSourceValue: String { return "ios_app" }
    static var siteIDKey: String { return "site_id" }
    static var deepLinkPathKey: String { return "$deeplink_path" }
    static var fallbackURLKey: String { return "$fallback_url" }
    static var desktopURLKey: String { return "$desktop_url" }
    static var iosURLKey: String { return "$ios_url" }
    static var androidURLKey: String { return "$android_url" }
    static var sub1: String { return "sub1" }
    static var sub2: String { return "sub2" }
    
    
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
    
    func retrieveTwitterShareText(completion: @escaping MessageWithURLCompletion) {
        retrieveFullMessageWithURL(source: .twitter, completion: completion)
    }
    
    
    // MARK: - AppsFlyer
    
    func retrieveShareURL(source: ShareSource?, campaign: String, deepLinkString: String, letgoURLString: String?,
                          fallbackToStore: Bool, myUserId: String?, myUserName: String?,
                          completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        AppsFlyerShareInviteHelper.generateInviteUrl(linkGenerator: { generator in
            return self.appsFlyerLinkGenerator(generator,
                                               source: source,
                                               campaign: campaign,
                                               deepLinkString: deepLinkString,
                                               letgoURLString: letgoURLString,
                                               fallbackToStore: fallbackToStore,
                                               myUserId: myUserId,
                                               myUserName: myUserName)}) { url in
                                                // The callback is handled by another thread invoked by AppsFlyer
                                                // Dispatch to main thread to avoid unexpected behaviours,
                                                // i.e. FacebookMessageDialog crashes if not called from main
                                                DispatchQueue.main.async {
                                                    completion(url)
                                                }
        }
    }
    
    private func appsFlyerLinkGenerator(_ generator: AppsFlyerLinkGenerator,
                                        source: ShareSource?,
                                        campaign: String,
                                        deepLinkString: String,
                                        letgoURLString: String?,
                                        fallbackToStore: Bool,
                                        myUserId: String?,
                                        myUserName: String?) -> AppsFlyerLinkGenerator {
        generator.setCampaign(campaign)
        if let source = source {
            generator.setChannel(source.rawValue)
        }
        generator.setBaseDeeplink(deepLinkString)
        generator.addParameterValue(Self.utmSourceValue, forKey: Self.siteIDKey)
        if var letgoURLString = letgoURLString {
            let iosURL = fallbackToStore ?
                addUtmParamsToURLString(Constants.appStoreURL,
                                        source: source) : letgoURLString
            let androidURL = fallbackToStore ?
                addUtmParamsToURLString(Constants.playStoreURL,
                                        source: source) : letgoURLString
            letgoURLString = addUtmParamsToURLString(letgoURLString,
                                                     source: source)
            generator.addParameterValue(letgoURLString, forKey: Self.fallbackURLKey)
            generator.addParameterValue(letgoURLString, forKey: Self.desktopURLKey)
            generator.addParameterValue(iosURL, forKey: Self.iosURLKey)
            generator.addParameterValue(androidURL, forKey: Self.androidURLKey)
        }
        if let myUserId = myUserId {
            generator.addParameterValue(myUserId, forKey: Self.sub1)
        }
        if let myUserName = myUserName {
            generator.addParameterValue(myUserName, forKey: Self.sub2)
        }
        
        return generator
    }
    
    
    // MARK: - Helpers
    
    // Adds campaign, medium and source info to the url or path
    func addUtmParamsToURLString(_ string: String, source: ShareSource?) -> String {
        guard !string.isEmpty else { return "" }
        let mediumValue = source?.rawValue ?? ""
        let completeURLString = Constants.deepLinkScheme + string + "?" + Self.utmCampaignKey + "=" + Self.utmCampaignValue + "&" +
            Self.utmMediumKey + "=" + mediumValue + "&" +
            Self.utmSourceKey + "=" + Self.utmSourceValue
        if let percentEncodedURLString = AppsFlyerDeepLink.percentEncodeForAmpersands(urlString: completeURLString), needsPercentEncoding {
            return percentEncodedURLString
        }
        return completeURLString
    }
}


// MARK: - Listing Share

struct ListingSocialMessage: SocialMessage {
    static var utmCampaignValue = "product-detail-share"

    let emailShareIsHtml = false
    var emailShareSubject: String {
        return LGLocalizedString.productShareTitleOnLetgo(listingTitle)
    }
    let fallbackToStore: Bool
    var controlParameter: String {
        return "product/"+listingId
    }
    var myUserId: String?
    var myUserName: String?
    
    private var fullMessage: String {
        return title + " - " + body
    }
    private var body: String {
        var body = listingTitle
        if !isMine {
            body += " " + LGLocalizedString.productSharePostedBy(listingUserName)
        }
        return body
    }
    private var letgoUrl: URL? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL() }
        return LetgoURLHelper.buildProductURL(listingId: listingId)
    }
    
    private let title: String
    private let listingUserName: String
    private let listingTitle: String
    private let listingDescription: String
    private let imageURL: URL?
    private let listingId: String
    private let isMine: Bool

    init(title: String, listing: Listing, isMine: Bool, fallbackToStore: Bool, myUserId: String?, myUserName: String?) {
        self.title = title
        self.listingUserName = listing.user.name ?? ""
        self.listingTitle = listing.title ?? ""
        self.imageURL = listing.images.first?.fileURL ?? listing.thumbnail?.fileURL
        self.listingId = listing.objectId ?? ""
        self.listingDescription = listing.description ?? ""
        self.isMine = isMine
        self.fallbackToStore = fallbackToStore
        self.myUserId = myUserId
        self.myUserName = myUserName
    }
    
    init(listing: Listing, fallbackToStore: Bool, myUserId: String?, myUserName: String?) {
        let listingIsMine = Core.myUserRepository.myUser?.objectId == listing.user.objectId
        let socialTitleMyListing = listing.price.isFree ? LGLocalizedString.productIsMineShareBodyFree :
            LGLocalizedString.productIsMineShareBody
        let socialTitle = listingIsMine ? socialTitleMyListing : LGLocalizedString.productShareBody
        self.init(title: socialTitle, listing: listing, isMine: listingIsMine, fallbackToStore: fallbackToStore,
                  myUserId: myUserId, myUserName: myUserName)
    }

    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        retrieveShareURL(source: .native) { url in
            guard let shareUrl = url else {
                completion([self.fullMessage])
                return
            }
            completion([shareUrl, self.fullMessage])
        }
    }
    
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: .email) { url in
            guard let shareUrl = url else { 
                completion(self.title)
                return
            }
            let shareUrlString = shareUrl.absoluteString
            var message = self.title + " " + shareUrlString
            if !self.isMine {
                message += " " + LGLocalizedString.productSharePostedBy(self.listingUserName)
            }
            completion(message)
        }
    }

    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        retrieveShareURL(source: source) { url in
            let urlString = url?.absoluteString ?? ""
            completion(self.title + " " + urlString + " - " + self.body)
        }
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        let deepLinkString = addUtmParamsToURLString("product/"+listingId,
                                                       source: source)
        retrieveShareURL(source: source,
                         campaign: ListingSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         letgoURLString: letgoUrl?.absoluteString,
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         completion: completion)
    }
}


// MARK: - App Share

struct AppShareSocialMessage: SocialMessage {

    static var utmCampaignValue = "app-invite-friend"
    
    let emailShareIsHtml = true
    var emailShareSubject: String {
        return LGLocalizedString.appShareSubjectText
    }
    let fallbackToStore = true
    let controlParameter = "home"
    var myUserId: String?
    var myUserName: String?

    private let imageURL: URL?
    
    init(myUserId: String?, myUserName: String?) {
        self.myUserId = myUserId
        self.myUserName = myUserName
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

    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        let fullMessage = LGLocalizedString.appShareMessageText
        retrieveShareURL(source: source) { url in
            let urlString = url?.absoluteString ?? ""
            let fullMessage = fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
            completion(fullMessage)
        }
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        let deepLinkString = addUtmParamsToURLString(controlParameter,
                                                     source: source)
        retrieveShareURL(source: source,
                         campaign: AppShareSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         letgoURLString: LetgoURLHelper.buildHomeURLString(),
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         completion: completion)
    }
}


// MARK: - User Share

struct UserSocialMessage: SocialMessage {
    static var utmCampaignValue = "profile-share"
    
    var emailShareSubject: String {
        return titleText
    }
    let emailShareIsHtml = true
    let fallbackToStore = false
    var controlParameter: String {
        return "users/\(userId)"
    }
    var myUserId: String?
    var myUserName: String?
    
    private var letgoURL: URL? {
        return !userId.isEmpty ? LetgoURLHelper.buildUserURL(userId: userId) : LetgoURLHelper.buildHomeURL()
    }

    private let userName: String?
    private let avatar: URL?
    private let userId: String
    private let titleText: String
    private let messageText: String
    
    init(user: User, itsMe: Bool, myUserId: String?, myUserName: String?) {
        userName = user.name
        avatar = user.avatar?.fileURL
        userId = user.objectId ?? ""
        self.myUserId = myUserId
        self.myUserName = myUserName
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
        let deepLinkString = addUtmParamsToURLString(controlParameter,
                                                     source: source)
        retrieveShareURL(source: source,
                         campaign: UserSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         letgoURLString: letgoURL?.absoluteString,
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         completion: completion)
    }
}
