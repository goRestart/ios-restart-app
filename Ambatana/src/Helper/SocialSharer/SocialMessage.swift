import FBSDKShareKit
import LGCoreKit
import AppsFlyerLib
import LGComponents

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
    static var siteIDKey: String { return "af_siteid" }
    static var sub1: String { return "af_sub1" }
    static var sub2: String { return "af_sub2" }
    static var sub3: String { return "af_sub3" }
    static var webDeeplink: String { return "af_web_dp" }
    
    
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
    
    func retrieveShareURL(source: ShareSource?, campaign: String, deepLinkString: String, webURLString: String?,
                          fallbackToStore: Bool, myUserId: String?, myUserName: String?, myUserAvatar: String?,
                          completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        AppsFlyerShareInviteHelper.generateInviteUrl(linkGenerator: { generator in
            return self.appsFlyerLinkGenerator(generator,
                                               source: source,
                                               campaign: campaign,
                                               deepLinkString: deepLinkString,
                                               webURLString: webURLString,
                                               fallbackToStore: fallbackToStore,
                                               myUserId: myUserId,
                                               myUserName: myUserName,
                                               myUserAvatar: myUserAvatar)}) { url in
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
                                        webURLString: String?,
                                        fallbackToStore: Bool,
                                        myUserId: String?,
                                        myUserName: String?,
                                        myUserAvatar: String?) -> AppsFlyerLinkGenerator {
        generator.setCampaign(campaign)
        if let source = source {
            generator.setChannel(source.rawValue)
        }
        generator.setBaseDeeplink(deepLinkString)
        generator.addParameterValue(Self.utmSourceValue, forKey: Self.siteIDKey)
        if var webURLString = webURLString {
            webURLString = addUtmParamsToURLString(webURLString, source: source)
            generator.addParameterValue(webURLString, forKey: Self.webDeeplink)
        }
        if let myUserId = myUserId {
            generator.addParameterValue(myUserId, forKey: Self.sub1)
        }
        if let myUserName = myUserName {
            generator.addParameterValue(myUserName, forKey: Self.sub2)
        }
        if let myUserAvatar = myUserAvatar {
            generator.addParameterValue(myUserAvatar, forKey: Self.sub3)
        }
        
        return generator
    }
    
    
    // MARK: - Helpers
    
    // Adds campaign, medium and source info to the url or path
    func addUtmParamsToURLString(_ string: String, source: ShareSource?) -> String {
        guard !string.isEmpty else { return "" }
        let mediumValue = source?.rawValue ?? ""
        let completeURLString = string + "?" +
            Self.utmCampaignKey + "=" + Self.utmCampaignValue + "&" +
            Self.utmMediumKey + "=" + mediumValue + "&" +
            Self.utmSourceKey + "=" + Self.utmSourceValue
        if let percentEncodedURLString = AppsFlyerDeepLink.percentEncodeForAmpersands(urlString: completeURLString) {
            return percentEncodedURLString
        }
        return completeURLString
    }
    
    func addCustomSchemeToDeeplinkPath(_ deepLinkPath: String) -> String {
        return "\(SharedConstants.deepLinkScheme)\(deepLinkPath)"
    }
}


// MARK: - Listing Share

struct ListingSocialMessage: SocialMessage {
    static var utmCampaignValue = "product-detail-share"

    let emailShareIsHtml = false
    var emailShareSubject: String {
        return R.Strings.productShareTitleOnLetgo(listingTitle)
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
            body += " " + R.Strings.productSharePostedBy(listingUserName)
        }
        return body
    }
    private var webUrlString: String? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL()?.absoluteString }
        return LetgoURLHelper.buildProductURL(listingId: listingId, isLocalized: false)?.absoluteString
    }
    
    private var webUrlLangLocalizedString: String? {
        guard !listingId.isEmpty else { return LetgoURLHelper.buildHomeURL()?.absoluteString }
        return LetgoURLHelper.buildProductURL(listingId: listingId, isLocalized: true)?.absoluteString
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
        let socialTitleMyListing = listing.price.isFree ? R.Strings.productIsMineShareBodyFree :
            R.Strings.productIsMineShareBody
        let socialTitle = listingIsMine ? socialTitleMyListing : R.Strings.productShareBody
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
                message += " " + R.Strings.productSharePostedBy(self.listingUserName)
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
        let deepLinkPath = addUtmParamsToURLString("product/"+listingId,
                                                     source: source)
        let deepLinkString = addCustomSchemeToDeeplinkPath(deepLinkPath)
        retrieveShareURL(source: source,
                         campaign: ListingSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         webURLString: webUrlLangLocalizedString,
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         myUserAvatar: nil,
                         completion: completion)
    }
}


// MARK: - App Share

struct AppShareSocialMessage: SocialMessage {

    static var utmCampaignValue = "app-invite-friend"
    
    let emailShareIsHtml = true
    var emailShareSubject: String {
        return R.Strings.appShareSubjectText
    }
    let fallbackToStore = true
    let controlParameter = "home"
    var myUserId: String?
    var myUserName: String?
    
    init(myUserId: String?, myUserName: String?) {
        self.myUserId = myUserId
        self.myUserName = myUserName
    }
    
    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        retrieveShareURL(source: .native) { url in
            if let shareUrl = url {
                completion([shareUrl, R.Strings.appShareMessageText])
            } else {
                completion([R.Strings.appShareMessageText])
            }
        }
    }

    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        var shareBody = R.Strings.appShareMessageText
        retrieveShareURL(source: .email) { url in
            if let shareUrl = url {
                shareBody += ":\n\n"
                let shareUrlString = shareUrl.absoluteString
                let fullBody = shareBody + "<a href=\"" + shareUrlString + "\">"+R.Strings.appShareDownloadText+"</a>"
                completion(fullBody)
            } else {
                completion(shareBody)
            }
        }
    }

    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        let fullMessage = R.Strings.appShareMessageText
        retrieveShareURL(source: source) { url in
            let urlString = url?.absoluteString ?? ""
            let fullMessage = fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
            completion(fullMessage)
        }
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        let deepLinkPath = addUtmParamsToURLString(controlParameter,
                                                     source: source)
        let deepLinkString = addCustomSchemeToDeeplinkPath(deepLinkPath)
        retrieveShareURL(source: source,
                         campaign: AppShareSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         webURLString: LetgoURLHelper.buildHomeURLString(),
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         myUserAvatar: nil,
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
    
    private var webUrlString: String? {
        let webUrl = !userId.isEmpty ? LetgoURLHelper.buildUserURL(userId: userId) : LetgoURLHelper.buildHomeURL()
        return webUrl?.absoluteString
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
            titleText = R.Strings.userShareTitleTextMine
            messageText = R.Strings.userShareMessageMine
        } else if let userName = user.name, !userName.isEmpty {
            titleText = R.Strings.userShareTitleTextOtherWName(userName)
            messageText = R.Strings.userShareMessageOtherWName(userName)
        } else {
            titleText = R.Strings.userShareTitleTextOther
            messageText = R.Strings.userShareMessageOther
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
        let deepLinkPath = addUtmParamsToURLString(controlParameter,
                                                     source: source)
        let deepLinkString = addCustomSchemeToDeeplinkPath(deepLinkPath)
        retrieveShareURL(source: source,
                         campaign: UserSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         webURLString: webUrlString,
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         myUserAvatar: nil,
                         completion: completion)
    }
}

// MARK: - Affiliation Share

struct AffiliationSocialMessage: SocialMessage {
    
    static let utmCampaignValue = AppsFlyerAffiliationResolver.campaignValue
    
    let emailShareIsHtml = true
    let emailShareSubject: String = R.Strings.appShareSubjectText

    let fallbackToStore = true
    let controlParameter = "home"
    let myUserId: String?
    let myUserName: String?
    let myUserAvatar: String?
    
    private var displayName: String {
        return myUserName ?? ""
    }
    
    init(myUserId: String?, myUserName: String?, myUserAvatar: String?) {
        self.myUserId = myUserId
        self.myUserName = myUserName
        self.myUserAvatar = myUserAvatar
    }
    
    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) {
        let infoText: String = R.Strings.affiliationInviteMessageText
        retrieveShareURL(source: .native) { url in
            if let shareUrl = url {
                completion([shareUrl, infoText])
            } else {
                completion([infoText])
            }
        }
    }
    
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) {
        var shareBody = R.Strings.affiliationInviteMessageText
        retrieveShareURL(source: .email) { url in
            if let shareUrl = url  {
                shareBody += ":\n\n"
                let shareUrlString = shareUrl.absoluteString
                let fullBody = shareBody + "<a href=\"" + shareUrlString + "\">"+shareBody+"</a>"
                completion(fullBody)
            } else {
                completion(shareBody)
            }
        }
    }
    
    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) {
        let fullMessage = R.Strings.affiliationInviteMessageText
        retrieveShareURL(source: source) { url in
            let urlString = url?.absoluteString ?? ""
            let fullMessage = fullMessage.isEmpty ? urlString : fullMessage + ":\n" + urlString
            completion(fullMessage)
        }
    }
    
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) {
        let deepLinkPath = addUtmParamsToURLString(controlParameter,
                                                   source: source)
        let deepLinkString = addCustomSchemeToDeeplinkPath(deepLinkPath)
        retrieveShareURL(source: source,
                         campaign: AffiliationSocialMessage.utmCampaignValue,
                         deepLinkString: deepLinkString,
                         webURLString: LetgoURLHelper.buildHomeURLString(),
                         fallbackToStore: fallbackToStore,
                         myUserId: myUserId,
                         myUserName: myUserName,
                         myUserAvatar: myUserAvatar,
                         completion: completion)
    }
}
