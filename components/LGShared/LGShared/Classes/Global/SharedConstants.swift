import LGCoreKit
import AVFoundation

public struct SharedConstants {
    // Input validation
    public static let fullNameMinLength = 2
    public static let passwordMinLength = 4
    public static let passwordMaxLength = 20
    public static let listingDescriptionMaxLength = 1500
    public static let userRatingDescriptionMaxLength = 255
    public static let userRatingMinStarsPositive = 3
    public static let emailSuggestedDomains = ["gmail.com", "yahoo.com", "hotmail.com", "aol.com", "icloud.com", "outlook.com",
                                        "live.com", "comcast.com", "msn.com", "windowslive.com", "mynet.com",
                                        "yandex.com"]

    // Map
    public static let largestRegionRadius = 20000.0
    public static let accurateRegionRadius = 1000.0    // meters
    public static let nonAccurateRegionRadius = 5000.0 // meters
    public static let metersInOneMile: Double = 1609.34
    
    // URLs
    public static let appStoreURL = "itms-apps://itunes.apple.com/app/id986339882?mt=8"
    public static let appStoreWriteReviewURL = "itms-apps://itunes.apple.com/app/id986339882?action=write-review&mt=8"
    public static let playStoreURL = "https://play.google.com/store/apps/details?id=com.abtnprojects.ambatana"
    
    // DeepLinks
    public static let deepLinkScheme = "letgo://"
    // AppsFlyer
    public static let appsFlyerLinksHost = "letgo.onelink.me"

    // Website
    public static let websiteRecaptchaEndpoint = "/mcaptcha"
    public static let websiteHelpEndpoint = "/help_app"
    public static let websiteContactUsEndpoint = "/contact_app"
    public static let websitePrivacyEndpoint = "/privacy_app"
    public static let websiteTermsEndpoint = "/terms_app"
    public static let websiteAffiliationHowItWorks = "/rewards-how-it-works"
    public static let websiteCommunityGuideline = "/community-guidelines"
    public static let websitePaymentsFaqs = "/paymentsfaqs"
    public static func websiteListingEndpoint(_ listingId: String) -> String {
        return String(format: "/product/%@", arguments: [listingId])
    }
    public static func websiteUserEndpoint(_ userId: String) -> String {
        return String(format: "/user/%@", arguments: [userId])
    }
    
    // Deep links other apps
    public static let whatsAppShareURL = "whatsapp://send?text=%@"
    public static let telegramShareURL = "tg://msg?text=%@"
    public static let twitterShareURL = "https://twitter.com/intent/tweet?text=%@"

    // Onboarding
    public static let abTestSyncTimeout: TimeInterval = 5
    
    // Listing List
    public static let listingListMaxDistanceLabel = 20
    public static let listingListMaxMinsLabel = 60.0
    public static let listingListMaxHoursLabel = 24.0
    public static let listingListMaxDaysLabel = 30.0
    public static let listingListMaxMonthsLabel = 3.0
    public static let listingListFooterHeight: CGFloat = 70
    public static let listingListFixedInsets: CGFloat = 6
    public static let listingListNewLabelThreshold = TimeInterval.make(days: 1)
    public static let numListingsPerPageDefault = 50
    public static let numListingsPerPageBig = 50
    public static let listingsPagingThresholdPercentage: Float = 0.4 // Percentage of page to check bottom threshold to paginate
    public static let maxSelectedForYouQueryTerms = 15
    public static let listingsSearchSuggestionsMaxResults = 10
    public static let selectedForYouPosition = 10
    
    // Categories
    public static let categoriesCellFactor: CGFloat = 150.0 / 160.0
    
    // Filters
    public static var distanceSliderDefaultPosition = 0
    public static let distanceSliderPositions = [0, 1, 10, 20, 30, 100]

    // Pre Permissions
    public static let pushPermissionRepeatTime = TimeInterval.make(days: 1)

    // Listing posting
    public static var maxImageCount: Int = 10
    public static let maxPriceIntegerCharacters = 9
    public static let maxPriceFractionalCharacters = 2
    public static let currencyDefault = "US"
    public static let defaultPrice: ListingPrice = .normal(0)
    public static let sizeSquareMetersUnit: String = "㎡"
    public static let maxNumberMultiPosting = 15
    

    // Camera
    public static let videoMaxRecordingDuration: TimeInterval = 15
    public static let videoMinRecordingDuration: TimeInterval = 3
    public static let videoSnapshotTime: TimeInterval = 1
    public static let videoFileExtension: String = "mp4"
    public static let videoSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: 480,
        AVVideoHeightKey: 640,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
    ];

    public struct MachineLearning {
        public static let minimumConfidence: Double = 0.3
        public static let minimumConfidenceToRemove: Double = 0.2
        public static let maximumDaysToDisplay: Double = 30
        public static let pricePositionDisplay: Int = 2
    }

    // Messages retrieving
    public static let numMessagesPerPage = 40

    // Domain
    public static var appDomain: String {
        return Bundle.main.bundleIdentifier ?? "com.letgo.ios"
    }

    // Rating
    public static let ratingRepeatTime = TimeInterval.make(days: 3)

    // Listing Detail
    public static let minimumStatsCountToShow = 5
    public static let maxCharactersOnUserNameChatButton = 12
    public static let imageRequestPoolCapacity = 15
    
    // User
    public static let maxUserNameLength = 18

    // Edit Listing
    public static let cloudsightTimeThreshold = TimeInterval.make(minutes: 15) // just ask for automatic generated name the first 15 mins
    public static let cloudsightRequestRepeatInterval: TimeInterval = 2  // repeat the request every 2 seconds

    // Config
    public static let defaultConfigTimeOut: Double = 3    // seconds
    public static let defaultQuadKeyZoomLevel: Int = 13

    // FBSDK
    public static let fbSdkRequiredDelay: TimeInterval = 0.25 // FBSdk calls callback before dismissing view so delay is required prior to any alert

    // Image Caching
    public static let imagesUrlCacheMemoryCapacity = 20 * 1024 * 1024 // 20 MB
    public static let imagesUrlCacheDiskCapacity = 150 * 1024 * 1024 // 150 MB

    // Alerts
    public static let bubbleChatDuration: TimeInterval = 3         // seconds
    public static let bubbleFavoriteDuration: TimeInterval = 5
    public static let autocloseMessageDefaultTime: TimeInterval = 2.5

    // NewRelic
    public static let newRelicGodModeToken = "AAfcb13d44209d7454436d2efa9974174d063a8d1d"
    public static let newRelicProductionToken = "AA448d0966d24653a9a1c92e2d37f86ef5ec61cc7c"

    // Cars
    public static let filterMinCarYear: Int = 1990
    public static let filterMinCarSeatsNumber: Int = 1
    public static let filterMaxCarSeatsNumber: Int = 9
    public static let filterMinCarMileage: Int = 0
    public static let filterMaxCarMileage: Int = 300000

    // Bump Ups
    public static let maxRetriesForBumpUpRestore = 20
    public static let maxRetriesForFirstTimeBumpUp = 3
    public static let promoteAfterPostWaitTime = TimeInterval.make(days: 1)
    public static let fiveMinutesTimeLimit = TimeInterval.make(minutes: 5)
    public static let oneHourTimeLimit = TimeInterval.make(hours: 1)

    // Tracking
    // TODO: ABIOS-3771 Remove this when integrating LGAnalytics module
    public static let parameterNotApply = "N/A"
    public static let parameterSkipValue = "skip"

    // Ads
    public static let adInFeedCustomTargetingKey = "pos_var"
    public static let newUserTimeThresholdForAds = TimeInterval.make(days: 15)
    public static let adNetwork = "adNetwork"

    // Professional Dealers
    public static let usaPhoneNumberDigitsCount = 10
    public static let usaFirstDashPosition = 3
    public static let usaSecondDashPosition = 7

    public struct Reputation {
        public static let minScore: Int = 50
        public static let maxScore: Int = 80
    }
    
    // Chat norris
    public static let minSafeHourForMeetings = 10
    public static let maxSafeHourForMeetings = 17
    
    public enum Feed {
        public static let adInFeedInitialPosition = 3
        public static let adsInFeedRatio = 20
        public static let firstAdBannerIndex = 1
        public static let adBannerRatio = 6
    }
    
}
