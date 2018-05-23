//
//  Constants.swift
//  LetGo
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import AVFoundation

struct Constants {
    // Input validation
    static let fullNameMinLength = 2
    static let passwordMinLength = 4
    static let passwordMaxLength = 20
    static let listingDescriptionMaxLength = 1500
    static let userRatingDescriptionMaxLength = 255
    static let userRatingMinStarsPositive = 3
    static let emailSuggestedDomains = ["gmail.com", "yahoo.com", "hotmail.com", "aol.com", "icloud.com", "outlook.com",
                                        "live.com", "comcast.com", "msn.com", "windowslive.com", "mynet.com",
                                        "yandex.com"]

    // Map
    static let largestRegionRadius = 20000.0
    static let accurateRegionRadius = 1000.0    // meters
    static let nonAccurateRegionRadius = 5000.0 // meters
    static let metersInOneMile: Double = 1609.34
    
    // URLs
    static let appStoreURL = "itms-apps://itunes.apple.com/app/id986339882?mt=8"
    static let appStoreWriteReviewURL = "itms-apps://itunes.apple.com/app/id986339882?action=write-review&mt=8"
    static let playStoreURL = "https://play.google.com/store/apps/details?id=com.abtnprojects.ambatana"
    
    // DeepLinks
    static let deepLinkScheme = "letgo://"
    // Branch
    static let branchWebsiteURL = "https://app.letgo.com"
    static let branchLinksHost = "app.letgo.com"
    // AppsFlyer
    static let appsFlyerLinksHost = "letgo.onelink.me"

    // Website
    static let websiteRecaptchaEndpoint = "/mcaptcha"
    static let websiteHelpEndpoint = "/help_app"
    static let websiteContactUsEndpoint = "/contact_app"
    static let websitePrivacyEndpoint = "/privacy_app"
    static let websiteTermsEndpoint = "/terms_app"
    static func websiteListingEndpoint(_ listingId: String) -> String {
        return String(format: "/product/%@", arguments: [listingId])
    }
    static func websiteUserEndpoint(_ userId: String) -> String {
        return String(format: "/user/%@", arguments: [userId])
    }

    // Deep links other apps
    static let whatsAppShareURL = "whatsapp://send?text=%@"
    static let telegramShareURL = "tg://msg?text=%@"
    static let twitterShareURL = "https://twitter.com/intent/tweet?text=%@"

    // Onboarding
    static let abTestSyncTimeout: TimeInterval = 5
    
    // Listing List
    static let listingListMaxDistanceLabel = 20
    static let listingListMaxMinsLabel = 60.0
    static let listingListMaxHoursLabel = 24.0
    static let listingListMaxDaysLabel = 30.0
    static let listingListMaxMonthsLabel = 3.0
    static let listingListFooterHeight: CGFloat = 70
    static let listingListFixedInsets: CGFloat = 6
    static let listingListNewLabelThreshold = TimeInterval.make(days: 1)
    static let numListingsPerPageDefault = 50
    static let numListingsPerPageBig = 50
    static let listingsPagingThresholdPercentage: Float = 0.4 // Percentage of page to check bottom threshold to paginate
    static let maxSelectedForYouQueryTerms = 15
    static let listingsSearchSuggestionsMaxResults = 10
    
    // Categories
    static let categoriesCellFactor: CGFloat = 150.0 / 160.0
    
    // Filters
    static var distanceSliderDefaultPosition = 0
    static let distanceSliderPositions = [0, 1, 10, 20, 30, 100]

    // Pre Permissions
    static let pushPermissionRepeatTime = TimeInterval.make(days: 1)

    // Surveys
    static let surveysMinGapTime = TimeInterval.make(days: 1)
    static let surveyDefaultTestUrl = "https://letgo1.typeform.com/to/e9Ndb4"

    // Listing posting
    static var maxImageCount: Int {
        return FeatureFlags.sharedInstance.increaseNumberOfPictures.isActive ? 10 : 5
    }
    static let maxPriceIntegerCharacters = 9
    static let maxPriceFractionalCharacters = 2
    static let currencyDefault = "US"
    static let defaultPrice: ListingPrice = .normal(0)
    static let sizeSquareMetersUnit: String = "㎡"

    // Camera
    static let videoMaxRecordingDuration: TimeInterval = 15
    static let videoMinRecordingDuration: TimeInterval = 2
    static let videoSnapshotTime: TimeInterval = 1
    static let videoFileExtension: String = "mp4"
    static let videoSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: 480,
        AVVideoHeightKey: 640,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
    ];

    // Messages retrieving
    static let numMessagesPerPage = 40

    // Domain
    static var appDomain: String {
        return Bundle.main.bundleIdentifier ?? "com.letgo.ios"
    }

    // Rating
    static let ratingRepeatTime = TimeInterval.make(days: 3)

    // Listing Detail
    static let minimumStatsCountToShow = 5
    static let maxCharactersOnUserNameChatButton = 12
    static let imageRequestPoolCapacity = 15
    
    // User
    static let maxUserNameLength = 18

    // Edit Listing
    static let cloudsightTimeThreshold = TimeInterval.make(minutes: 15) // just ask for automatic generated name the first 15 mins
    static let cloudsightRequestRepeatInterval: TimeInterval = 2  // repeat the request every 2 seconds

    // Config
    static let defaultConfigTimeOut: Double = 3    // seconds
    static let defaultQuadKeyZoomLevel: Int = 13

    // FBSDK
    static let fbSdkRequiredDelay: TimeInterval = 0.25 // FBSdk calls callback before dismissing view so delay is required prior to any alert

    // Image Caching
    static let imagesUrlCacheMemoryCapacity = 20 * 1024 * 1024 // 20 MB
    static let imagesUrlCacheDiskCapacity = 150 * 1024 * 1024 // 150 MB

    // Alerts
    static let bubbleChatDuration: TimeInterval = 3         // seconds
    static let bubbleFavoriteDuration: TimeInterval = 5
    static let autocloseMessageDefaultTime: TimeInterval = 2.5

    // NewRelic
    static let newRelicGodModeToken = "AAfcb13d44209d7454436d2efa9974174d063a8d1d"
    static let newRelicProductionToken = "AA448d0966d24653a9a1c92e2d37f86ef5ec61cc7c"

    // Cars
    static let filterMinCarYear: Int = 1990

    // Bump Ups
    static let maxRetriesForBumpUpRestore = 20
    static let maxRetriesForFirstTimeBumpUp = 3
    static let promoteAfterPostWaitTime = TimeInterval.make(days: 1)
    static let fiveMinutesTimeLimit = TimeInterval.make(minutes: 5)
    static let oneHourTimeLimit = TimeInterval.make(hours: 1)

    // Tracking
    // TODO: ABIOS-3771 Remove this when integrating LGAnalytics module
    static let parameterNotApply = "N/A"
    static let parameterSkipValue = "skip"

    // Ads
    static let adInFeedCustomTargetingKey = "pos_var"
    static let newUserTimeThresholdForAds = TimeInterval.make(days: 15)

    // Professional Dealers
    static let usaPhoneNumberDigitsCount = 10
    static let usaFirstDashPosition = 3
    static let usaSecondDashPosition = 7

    struct Reputation {
        static let minScore: Int = 50
        static let maxScore: Int = 80
    }
    
    // Chat norris
    static let minSafeHourForMeetings = 10
    static let maxSafeHourForMeetings = 17
}
