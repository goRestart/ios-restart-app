//
//  Constants.swift
//  LetGo
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

struct Constants {
    // Input validation
    static let fullNameMinLength = 2
    static let passwordMinLength = 4
    static let passwordMaxLength = 20
    static let productDescriptionMaxLength = 1500
    static let userRatingDescriptionMaxLength = 255
    static let userRatingMinStarsToOptionalDescr = 3
    static let emailSuggestedDomains = ["gmail.com", "yahoo.com", "hotmail.com", "aol.com", "icloud.com", "outlook.com",
                                        "live.com", "comcast.com", "msn.com", "windowslive.com", "mynet.com",
                                        "yandex.com"]

    // Map
    static let accurateRegionRadius = 1000.0    // meters
    static let nonAccurateRegionRadius = 5000.0 // meters
    
    // URLs
    static let appStoreURL = "itms-apps://itunes.apple.com/app/id986339882?mt=8"
    static let playStoreURL = "https://play.google.com/store/apps/details?id=com.abtnprojects.ambatana"
    static let appShareFbMessengerURL = "https://letgo.onelink.me/2963730415?pid=letgo_app&c=facebook-messenger-sold"
    static let appShareWhatsappURL = "https://letgo.onelink.me/2963730415?pid=letgo_app&c=whatsapp-sold"
    static let appShareEmailURL = "https://letgo.onelink.me/2963730415?pid=letgo_app&c=email-sold"

    // Branch
    static let branchWebsiteURL = "https://app.letgo.com"
    static let branchLinksHost = "app.letgo.com"

    // Website
    static let websiteRecaptchaEndpoint = "/mcaptcha"
    static let websiteHelpEndpoint = "/help_app"
    static let websiteContactUsEndpoint = "/contact_app"
    static let websitePrivacyEndpoint = "/privacy_app"
    static let websiteTermsEndpoint = "/terms_app"
    static func websiteProductEndpoint(_ productId: String) -> String {
        return String(format: "/product/%@", arguments: [productId])
    }
    static func websiteUserEndpoint(_ userId: String) -> String {
        return String(format: "/user/%@", arguments: [userId])
    }

    // Deep links other apps
    static let whatsAppShareURL = "whatsapp://send?text=%@"
    static let telegramShareURL = "tg://msg?text=%@"

    // Onboarding
    static let abTestSyncTimeout: TimeInterval = 5
    
    // Product List
    static let productListMaxDistanceLabel = 20
    static let productListMaxMinsLabel = 60.0
    static let productListMaxHoursLabel = 24.0
    static let productListMaxDaysLabel = 30.0
    static let productListMaxMonthsLabel = 3.0
    static let productListFooterHeight: CGFloat = 70
    static let productListFixedInsets: CGFloat = 6
    static let productListNewLabelThreshold: TimeInterval = 60 * 60 * 24 // 1 day
    static let numProductsPerPageDefault = 20
    static let numProductsPerPageBig = 40
    static let productsPagingThresholdPercentage: Float = 0.4 // Percentage of page to check bottom threshold to paginate
    
    // Categories
    static let categoriesCellFactor: CGFloat = 150.0 / 160.0
    
    // Filters
    static var distanceFilterDefault = 0
    static let distanceFilterOptions = [0, 1, 10, 20, 30, 100]
    
    // App sharing
    static let facebookAppLinkURL = "https://fb.me/900185926729336"
    static let facebookAppInvitePreviewImageURL = "http://cdn.letgo.com/static/app-invites-facebook.jpg"

    // Pre Permissions
    static let pushPermissionRepeatTime: TimeInterval = (60 * 60 * 24) // 1 day

    // Product posting
    static let maxImageCount = 5
    static let maxPriceIntegerCharacters = 9
    static let maxPriceFractionalCharacters = 2

    // Messages retrieving
    static let numMessagesPerPage = 40

    // Domain
    static var appDomain: String {
        return Bundle.main.bundleIdentifier ?? "com.letgo.ios"
    }

    // Rating
    static let ratingRepeatTime: TimeInterval = (60 * 60 * 24 * 3) // 3 days

    // Product Detail
    static let minimumStatsCountToShow = 5
    static let maxCharactersOnUserNameChatButton = 12
    static let imageRequestPoolCapacity = 15
    
    // User
    static let maxUserNameLength = 18

    // Edit Product
    static let cloudsightTimeThreshold: TimeInterval = 900        // just ask for automatic generated name the first 15 mins
    static let cloudsightRequestRepeatInterval: TimeInterval = 2  // repeat the request every 2 seconds

    // Config
    static let defaultConfigTimeOut: Double = 3    // seconds
    static let defaultQuadKeyZoomLevel: Int = 13

    // user rating from chat
    static let myMessagesCountForRating = 2
    static let otherMessagesCountForRating = 2

    // FBSDK
    static let fbSdkRequiredDelay: TimeInterval = 0.25 // FBSdk calls callback before dismissing view so delay is required prior to any alert


    // Bubbles
    static let bubbleChatDuration: TimeInterval = 3         // seconds
    static let bubbleFavoriteDuration: TimeInterval = 5

    // NewRelic
    static let newRelicGodModeToken = "AAfcb13d44209d7454436d2efa9974174d063a8d1d"
    static let newRelicProductionToken = "AA448d0966d24653a9a1c92e2d37f86ef5ec61cc7c"
}
