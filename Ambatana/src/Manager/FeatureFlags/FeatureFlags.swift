import LGCoreKit
import CoreTelephony
import bumper
import RxSwift
import LGComponents

enum PostingFlowType: String {
    case standard
    case turkish
}

protocol FeatureFlaggeable: class {

    var trackingData: Observable<[(String, ABGroup)]?> { get }
    var syncedData: Observable<Bool> { get }
    func variablesUpdated()

    var surveyUrl: String { get }
    var surveyEnabled: Bool { get }

    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var userReviewsReportEnabled: Bool { get }
    var realEstateEnabled: RealEstateEnabled { get }
    var taxonomiesAndTaxonomyChildrenInFeed : TaxonomiesAndTaxonomyChildrenInFeed { get }
    var showClockInDirectAnswer : ShowClockInDirectAnswer { get }
    var deckItemPage: DeckItemPage { get }
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio { get }
    var realEstateNewCopy: RealEstateNewCopy { get }
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers { get }
    var searchImprovements: SearchImprovements { get }
    var relaxedSearch: RelaxedSearch { get }
    var bumpUpBoost: BumpUpBoost { get }
    var showProTagUserProfile: Bool { get }
    var sectionedMainFeed: SectionedMainFeed { get }
    var showExactLocationForPros: Bool { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var postingFlowType: PostingFlowType { get }
    var locationRequiresManualChangeSuggestion: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
    var moreInfoDFPAdUnitId: String { get }
    var feedDFPAdUnitId: String? { get }
    func collectionsAllowedFor(countryCode: String?) -> Bool
    var shouldChangeChatNowCopyInTurkey: Bool { get }
    var copyForChatNowInTurkey: CopyForChatNowInTurkey { get }
    var shareTypes: [ShareType] { get }
    var feedAdsProviderForUS:  FeedAdsProviderForUS { get }
    var feedAdUnitId: String? { get }
    var shouldChangeChatNowCopyInEnglish: Bool { get }
    var copyForChatNowInEnglish: CopyForChatNowInEnglish { get }
    var feedAdsProviderForTR:  FeedAdsProviderForTR { get }
    var shouldChangeSellFasterNowCopyInEnglish: Bool { get }
    var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish { get }
    var shouldShowIAmInterestedInFeed: IAmInterestedFeed { get }
    var googleAdxForTR: GoogleAdxForTR { get }
    var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS { get }
    var fullScreenAdUnitId: String? { get }
    var appInstallAdsInFeed: AppInstallAdsInFeed { get }
    var appInstallAdsInFeedAdUnit: String? { get }
    var alwaysShowBumpBannerWithLoading: AlwaysShowBumpBannerWithLoading { get }
    var showSellFasterInProfileCells: ShowSellFasterInProfileCells { get }
    var bumpInEditCopys: BumpInEditCopys { get }
    // MARK: Core
    var cachedFeed: CachedFeed { get }

    var copyForSellFasterNowInTurkish: CopyForSellFasterNowInTurkish { get }
    var multiAdRequestMoreInfo: MultiAdRequestMoreInfo { get }
    
    // MARK: Chat
    var showInactiveConversations: Bool { get }
    var showChatSafetyTips: Bool { get }
    var userIsTyping: UserIsTyping { get }
    var chatNorris: ChatNorris { get }
    var showChatConnectionStatusBar: ShowChatConnectionStatusBar { get }
    var showChatHeaderWithoutListingForAssistant: Bool { get }
    var showChatHeaderWithoutUser: Bool { get }
    var enableCTAMessageType: Bool { get }
    var expressChatImprovement: ExpressChatImprovement { get }
    var smartQuickAnswers: SmartQuickAnswers { get }
    var openChatFromUserProfile: OpenChatFromUserProfile { get }

    // MARK: Verticals
    var jobsAndServicesEnabled: EnableJobsAndServicesCategory { get }
    var servicesPaymentFrequency: ServicesPaymentFrequency { get }
    var carExtraFieldsEnabled: CarExtraFieldsEnabled { get }
    var realEstateMapTooltip: RealEstateMapTooltip { get }
    var servicesUnifiedFilterScreen: ServicesUnifiedFilterScreen { get }
    
    // MARK: Discovery
    var personalizedFeed: PersonalizedFeed { get }
    var personalizedFeedABTestIntValue: Int? { get }
    var multiContactAfterSearch: MultiContactAfterSearch { get }
    var emptySearchImprovements: EmptySearchImprovements { get }

    // MARK: Products
    var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu { get }
    var predictivePosting: PredictivePosting { get }
    var videoPosting: VideoPosting { get }
    var simplifiedChatButton: SimplifiedChatButton { get }
    var frictionlessShare: FrictionlessShare { get }

    // MARK: Users
    var advancedReputationSystem: AdvancedReputationSystem { get }
    var emergencyLocate: EmergencyLocate { get }
    var offensiveReportAlert: OffensiveReportAlert { get }
    var community: ShowCommunity { get }
    
    // MARK: Money
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers { get }
    
    // MARK: Retention
    var dummyUsersInfoProfile: DummyUsersInfoProfile { get }
    var onboardingIncentivizePosting: OnboardingIncentivizePosting { get }
    var highlightedIAmInterestedInFeed: HighlightedIAmInterestedFeed { get }
    var notificationSettings: NotificationSettings { get }
    var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions { get }
    var engagementBadging: EngagementBadging { get }
    var searchAlertsDisableOldestIfMaximumReached: SearchAlertsDisableOldestIfMaximumReached { get }
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}

extension TaxonomiesAndTaxonomyChildrenInFeed {
    var isActive: Bool { return self == .active }
}

extension RealEstateEnabled {
    var isActive: Bool { return self == .active }
}

extension ShowAdsInFeedWithRatio {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension NoAdsInFeedForNewUsers {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .adsEverywhere || self == .adsForNewUsersOnlyInFeed
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .adsEverywhere || self == .adsForNewUsersOnlyInFeed || self == .noAdsForNewUsers
    }
    var shouldShowAdsInFeed: Bool {
        return shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    private var shouldShowAdsInMoreInfoForNewUsers: Bool {
        return self == .control || self == .baseline || self == .adsEverywhere
    }
    private var shouldShowAdsInMoreInfoForOldUsers: Bool {
        return true
    }
    var shouldShowAdsInMoreInfo: Bool {
        return shouldShowAdsInMoreInfoForNewUsers || shouldShowAdsInMoreInfoForOldUsers
    }

    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(SharedConstants.newUserTimeThresholdForAds) {
            // New User
            return shouldShowAdsInFeedForNewUsers
        } else {
            // Old user
            return shouldShowAdsInFeedForOldUsers
        }
    }

    func shouldShowAdsInMoreInfoForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInMoreInfoForOldUsers }
        if creationDate.isNewerThan(SharedConstants.newUserTimeThresholdForAds) {
            // New User
            return shouldShowAdsInMoreInfoForNewUsers
        } else {
            // Old user
            return shouldShowAdsInMoreInfoForOldUsers
        }
    }
}

extension RealEstateNewCopy {
    var isActive: Bool { return self == .active }
}

extension DummyUsersInfoProfile {
    var isActive: Bool { return self == .active }
}

extension OnboardingIncentivizePosting {
    var isActive: Bool { return self == .blockingPosting || self == .blockingPostingSkipWelcome }
}

extension ServicesUnifiedFilterScreen {
    var isActive: Bool { return self == .active }
}

extension EnableJobsAndServicesCategory {
    var isActive: Bool { return self == .active }
}

extension ServicesPaymentFrequency {
    var isActive: Bool { return self == .active }
}

extension CarExtraFieldsEnabled {
    var isActive: Bool { return self == .active }
}

extension RealEstateMapTooltip {
    var isActive: Bool { return self == .active  }
}

extension BumpUpBoost {
    var isActive: Bool { get { return self != .control && self != .baseline } }

    var boostBannerUIUpdateThreshold: TimeInterval? {
        switch self {
        case .control, .baseline:
            return nil
        case .boostListing1hour, .sendTop1hour:
            return SharedConstants.oneHourTimeLimit
        case .sendTop5Mins, .cheaperBoost5Mins:
            return SharedConstants.fiveMinutesTimeLimit
        }
    }
}

extension DeckItemPage {
    var isActive: Bool {get { return self == .active }}
}

extension CopyForChatNowInTurkey {
    var isActive: Bool { return self != .control }
    
    var variantString: String {
        switch self {
        case .control:
            return R.Strings.bumpUpProductCellChatNowButton
        case .variantA:
            return R.Strings.bumpUpProductCellChatNowButtonA
        case .variantB:
            return R.Strings.bumpUpProductCellChatNowButtonB
        case .variantC:
            return R.Strings.bumpUpProductCellChatNowButtonC
        case .variantD:
            return R.Strings.bumpUpProductCellChatNowButtonD
        }
    }
}

extension AdvancedReputationSystem {
    var isActive: Bool { return self != .baseline && self != .control  }
    var shouldShowTooltip: Bool { return self == .variantB }
}

extension ShowCommunity {
    var isActive: Bool {  return self != .baseline && self != .control }
    var shouldShowOnTab: Bool { return self == .communityOnTabBar }
    var shouldShowOnNavBar: Bool { return self == .communityOnNavBar }
}

extension ShowPasswordlessLogin {
    var isActive: Bool { return self == .active }
}

extension EmergencyLocate {
    var isActive: Bool { return self == .active }
}

extension OffensiveReportAlert {
    var isActive: Bool { return self == .active }
}

extension FeedAdsProviderForUS {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .moPubAdsForAllUsers || self == .googleAdxForAllUsers
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers || self == .googleAdxForOldUsers || self == .googleAdxForAllUsers
    }
    
    var shouldShowAdsInFeed: Bool {
        return  shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    
    var shouldShowMoPubAds : Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    var shouldShowGoogleAdxAds : Bool {
        return self == .googleAdxForOldUsers || self == .googleAdxForAllUsers
    }
    
    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(SharedConstants.newUserTimeThresholdForAds) {
            return shouldShowAdsInFeedForNewUsers
        } else {
            return shouldShowAdsInFeedForOldUsers
        }
    }
}

extension FeedAdsProviderForTR {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .moPubAdsForAllUsers
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    var shouldShowAdsInFeed: Bool {
        return  shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    
    var shouldShowMoPubAds : Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(SharedConstants.newUserTimeThresholdForAds) {
            return shouldShowAdsInFeedForNewUsers
        } else {
            return shouldShowAdsInFeedForOldUsers
        }
    }
}

extension CopyForChatNowInEnglish {
    var isActive: Bool { get { return self != .control } }
    
    var variantString: String { get {
        switch self {
        case .control:
            return R.Strings.bumpUpProductCellChatNowButton
        case .variantA:
            return R.Strings.bumpUpProductCellChatNowButtonEnglishA
        case .variantB:
            return R.Strings.bumpUpProductCellChatNowButtonEnglishB
        case .variantC:
            return R.Strings.bumpUpProductCellChatNowButtonEnglishC
        case .variantD:
            return R.Strings.bumpUpProductCellChatNowButtonEnglishD
        }
        } }
}

extension CopyForSellFasterNowInEnglish {
    var isActive: Bool { return self != .control && self != .baseline }
    
    var variantString: String {
        switch self {
        case .control:
            return R.Strings.bumpUpBannerPayTextImprovement
        case .baseline:
            return R.Strings.bumpUpBannerPayTextImprovementEnglishA
        case .variantB:
            return R.Strings.bumpUpBannerPayTextImprovementEnglishB
        case .variantC:
            return R.Strings.bumpUpBannerPayTextImprovementEnglishC
        case .variantD:
            return R.Strings.bumpUpBannerPayTextImprovementEnglishD
        }
    }
}

extension CopyForSellFasterNowInTurkish {
    var isActive: Bool { return self != .control && self != .baseline }

    var variantString: String {
        switch self {
        case .control:
            return R.Strings.bumpUpBannerPayTextImprovement
        case .baseline:
            return R.Strings.bumpUpBannerPayTextImprovement
        case .variantB:
            return R.Strings.bumpUpBannerPayTextImprovementTurkishB
        case .variantC:
            return R.Strings.bumpUpBannerPayTextImprovementTurkishC
        case .variantD:
            return R.Strings.bumpUpBannerPayTextImprovementTurkishD
        }
    }
}

extension IAmInterestedFeed {
    var isVisible: Bool { return self == .control || self == .baseline }
}

extension PersonalizedFeed {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension NotificationSettings {
    var isActive: Bool { return self == .differentLists || self == .sameList }
}

extension EngagementBadging {
    var isActive: Bool { return self == .active }
}


// MARK: Products

extension ServicesCategoryOnSalchichasMenu {
    var isActive: Bool { return self != .control && self != .baseline }    
}

extension PredictivePosting {
    var isActive: Bool { return self == .active }

    func isSupportedFor(postCategory: PostCategory?, language: String) -> Bool {
        if #available(iOS 11, *), isActive, postCategory?.listingCategory.isProduct ?? true, language == "en" {
            return true
        } else {
            return false
        }
    }
}

extension VideoPosting {
    var isActive: Bool { return self == .active }
}

extension FrictionlessShare {
    var isActive: Bool { return self == .active }
}

extension GoogleAdxForTR {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .googleAdxForAllUsers
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .googleAdxForOldUsers || self == .googleAdxForAllUsers
    }
    
    var shouldShowAdsInFeed: Bool {
        return  shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    
    var shouldShowGoogleAdxAds : Bool {
        return self == .googleAdxForOldUsers || self == .googleAdxForAllUsers
    }
    
    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(SharedConstants.newUserTimeThresholdForAds) {
            return shouldShowAdsInFeedForNewUsers
        } else {
            return shouldShowAdsInFeedForOldUsers
        }
    }
}

extension FullScreenAdsWhenBrowsingForUS {
    private var shouldShowFullScreenAdsForNewUsers: Bool {
        return self == .adsForAllUsers
    }
    private var shouldShowFullScreenAdsForOldUsers: Bool {
        return self == .adsForOldUsers || self == .adsForAllUsers
    }
    
    var shouldShowFullScreenAds: Bool {
        return  shouldShowFullScreenAdsForNewUsers || shouldShowFullScreenAdsForOldUsers
    }
    
    func shouldShowFullScreenAdsForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn,
            creationDate.isNewerThan(SharedConstants.newUserTimeThresholdForAds) else { return shouldShowFullScreenAdsForOldUsers }
        return shouldShowFullScreenAdsForNewUsers
    }
}

extension PreventMessagesFromFeedToProUsers {
    var isActive: Bool { return self == .active }
}

extension AppInstallAdsInFeed {
    var isActive: Bool { return self == .active }
}

extension AlwaysShowBumpBannerWithLoading {
    var isActive: Bool { return self == .active }
}

extension SearchAlertsDisableOldestIfMaximumReached {
    var isActive: Bool { return self == .active }
}

extension ShowSellFasterInProfileCells {
    var isActive: Bool { return self == .active }
}

extension BumpInEditCopys {
    var variantString: String {
        switch self {
        case .control, .baseline:
            return R.Strings.editProductFeatureLabelLongText
        case .attractMoreBuyers:
            return R.Strings.editProductFeatureLabelVariantB
        case .attractMoreBuyersToSellFast:
            return R.Strings.editProductFeatureLabelVariantC
        case .showMeHowToAttract:
            return R.Strings.editProductFeatureLabelVariantD
        }
    }
}

extension MultiAdRequestMoreInfo {
    var isActive: Bool { return self == .active }

}

final class FeatureFlags: FeatureFlaggeable {
    
    static let sharedInstance: FeatureFlags = FeatureFlags()

    private let locale: Locale
    private var locationManager: LocationManager
    private let carrierCountryInfo: CountryConfigurable
    private let abTests: ABTests
    private let dao: FeatureFlagsDAO

    init(locale: Locale,
         locationManager: LocationManager,
         countryInfo: CountryConfigurable,
         abTests: ABTests,
         dao: FeatureFlagsDAO) {
        Bumper.initialize()

        // Initialize all vars that shouldn't change over application lifetime
        self.locale = locale
        self.locationManager = locationManager
        self.carrierCountryInfo = countryInfo
        self.abTests = abTests
        self.dao = dao
    }

    convenience init() {
        self.init(locale: Locale.current,
                  locationManager: Core.locationManager,
                  countryInfo: CTTelephonyNetworkInfo(),
                  abTests: ABTests(),
                  dao: FeatureFlagsUDDAO())
    }


    // MARK: - Public methods

    func registerVariables() {
        abTests.registerVariables()
    }


    // MARK: - A/B Tests features

    var trackingData: Observable<[(String, ABGroup)]?> {
        return abTests.trackingData.asObservable()
    }

    func variablesUpdated() {
        defer { abTests.variablesUpdated() }
        guard Bumper.enabled else { return }
        
        dao.save(advanceReputationSystem: AdvancedReputationSystem.fromPosition(abTests.advancedReputationSystem.value))
        dao.save(emergencyLocate: EmergencyLocate.fromPosition(abTests.emergencyLocate.value))
        dao.save(community: ShowCommunity.fromPosition(abTests.community.value))
    }
    
    var surveyUrl: String {
        if Bumper.enabled {
            return Bumper.surveyEnabled ? SharedConstants.surveyDefaultTestUrl : ""
        }
        return abTests.surveyURL.value
    }

    var surveyEnabled: Bool {
        if Bumper.enabled {
            return Bumper.surveyEnabled
        }
        return abTests.surveyEnabled.value
    }

    var freeBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.freeBumpUpEnabled
        }
        return abTests.freeBumpUpEnabled.value
    }

    var pricedBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.pricedBumpUpEnabled
        }
        return abTests.pricedBumpUpEnabled.value
    }

    var userReviewsReportEnabled: Bool {
        if Bumper.enabled {
            return Bumper.userReviewsReportEnabled
        }
        return abTests.userReviewsReportEnabled.value
    }

    var realEstateEnabled: RealEstateEnabled {
        if Bumper.enabled {
            return Bumper.realEstateEnabled
        }
        return RealEstateEnabled.fromPosition(abTests.realEstateEnabled.value)
    }

    var deckItemPage: DeckItemPage {
        if Bumper.enabled {
            return Bumper.deckItemPage
        }
        return DeckItemPage.fromPosition(abTests.deckItemPage.value)
    }
    
    var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed {
        if Bumper.enabled {
            return Bumper.taxonomiesAndTaxonomyChildrenInFeed
        }
        return TaxonomiesAndTaxonomyChildrenInFeed.fromPosition(abTests.taxonomiesAndTaxonomyChildrenInFeed.value)
    }
    
    var showClockInDirectAnswer: ShowClockInDirectAnswer {
        if Bumper.enabled {
            return Bumper.showClockInDirectAnswer
        }
        return ShowClockInDirectAnswer.fromPosition(abTests.showClockInDirectAnswer.value)
    }
    
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        if Bumper.enabled {
            return Bumper.showAdsInFeedWithRatio
        }
        return ShowAdsInFeedWithRatio.fromPosition(abTests.showAdsInFeedWithRatio.value)
    }
    
    var realEstateNewCopy: RealEstateNewCopy {
        if Bumper.enabled {
            return Bumper.realEstateNewCopy
        }
        return RealEstateNewCopy.fromPosition(abTests.realEstateNewCopy.value)
    }
    
    var dummyUsersInfoProfile: DummyUsersInfoProfile {
        if Bumper.enabled {
            return Bumper.dummyUsersInfoProfile
        }
        return DummyUsersInfoProfile.fromPosition(abTests.dummyUsersInfoProfile.value)
    }

    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers {
        if Bumper.enabled {
            return Bumper.noAdsInFeedForNewUsers
        }
        return NoAdsInFeedForNewUsers.fromPosition(abTests.noAdsInFeedForNewUsers.value)
    }

    var searchImprovements: SearchImprovements {
        if Bumper.enabled {
            return Bumper.searchImprovements
        }
        return SearchImprovements.fromPosition(abTests.searchImprovements.value)
    }
    
    var relaxedSearch: RelaxedSearch {
        if Bumper.enabled {
            return Bumper.relaxedSearch
        }
        return RelaxedSearch.fromPosition(abTests.relaxedSearch.value)
    }
    
    var bumpUpBoost: BumpUpBoost {
        if Bumper.enabled {
            return Bumper.bumpUpBoost
        }
        return BumpUpBoost.fromPosition(abTests.bumpUpBoost.value)
    }

    var showProTagUserProfile: Bool {
        if Bumper.enabled {
            return Bumper.showProTagUserProfile
        }
        return abTests.showProTagUserProfile.value
    }

    var advancedReputationSystem: AdvancedReputationSystem {
        if Bumper.enabled {
            return Bumper.advancedReputationSystem
        }
        let cached = dao.retrieveAdvanceReputationSystem()
        return cached ?? AdvancedReputationSystem.fromPosition(abTests.advancedReputationSystem.value)
    }

    var community: ShowCommunity {
        if Bumper.enabled {
            return Bumper.showCommunity
        }
        let cached = dao.retrieveCommunity()
        return cached ?? ShowCommunity.fromPosition(abTests.community.value)
    }
    
    var sectionedMainFeed: SectionedMainFeed {
        if Bumper.enabled {
            return Bumper.sectionedMainFeed
        }
        return SectionedMainFeed.fromPosition(abTests.sectionedMainFeed.value)
    }
    
    var showExactLocationForPros: Bool {
        if Bumper.enabled {
            return Bumper.showExactLocationForPros
        }
        return abTests.showExactLocationForPros.value
    }

    var showPasswordlessLogin: ShowPasswordlessLogin {
        if Bumper.enabled {
            return Bumper.showPasswordlessLogin
        }
        return ShowPasswordlessLogin.fromPosition(abTests.showPasswordlessLogin.value)
    }

    var emergencyLocate: EmergencyLocate {
        if Bumper.enabled {
            return Bumper.emergencyLocate
        }
        let cached = dao.retrieveEmergencyLocate()
        return cached ?? EmergencyLocate.fromPosition(abTests.emergencyLocate.value)
    }

    var offensiveReportAlert: OffensiveReportAlert {
        if Bumper.enabled {
            return Bumper.offensiveReportAlert
        }
        return OffensiveReportAlert.fromPosition(abTests.offensiveReportAlert.value)
    }
    
    
    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        switch locationCountryCode {
        case .turkey?:
            return false
        default:
            return true
        }
    }
    
    var postingFlowType: PostingFlowType {
        if Bumper.enabled {
            return Bumper.realEstateFlowType == .standard ? .standard : .turkish
        }
        switch locationCountryCode {
        case .turkey?:
            return .turkish
        default:
            return .standard
        }
    }

    var locationRequiresManualChangeSuggestion: Bool {
        // Manual location is already ok
        guard let currentLocation = locationManager.currentLocation, currentLocation.isAuto else { return false }
        guard let countryCodeString = carrierCountryInfo.countryCode, let countryCode = CountryCode(string: countryCodeString) else { return false }
        switch countryCode {
        case .turkey:
            // In turkey, if current location country doesn't match carrier one we must sugest user to change it
            return !locationManager.countryMatchesWith(countryCode: countryCodeString)
        case .usa:
            return false
        }
    }

    var signUpEmailNewsletterAcceptRequired: Bool {
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return true
        default:
            return false
        }
    }
    
    var signUpEmailTermsAndConditionsAcceptRequired: Bool {
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return true
        default:
            return false
        }
    }

    func collectionsAllowedFor(countryCode: String?) -> Bool {
        guard let code = countryCode, let countryCode = CountryCode(string: code) else { return false }
        switch countryCode {
        case .usa:
            return true
        default:
            return false
        }
    }
    
    var shareTypes: [ShareType] {
       switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return [.whatsapp, .facebook, .email ,.fbMessenger, .twitter, .sms, .telegram]
        default:
            return [.sms, .email, .facebook, .fbMessenger, .twitter, .whatsapp, .telegram]
        }
    }

    var moreInfoDFPAdUnitId: String {
        switch sensorLocationCountryCode {
        case .usa?:
            return multiAdRequestMoreInfo.isActive ? EnvironmentProxy.sharedInstance.moreInfoMultiAdUnitIdDFPUSA :
                EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFPUSA
        default:
            return multiAdRequestMoreInfo.isActive ? EnvironmentProxy.sharedInstance.moreInfoMultiAdUnitIdDFP :
                EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFP
        }
    }

    var feedDFPAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            switch showAdsInFeedWithRatio {
            case .baseline, .control:
                return noAdsInFeedForNewUsers.shouldShowAdsInFeed ? EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio : nil
            case .ten:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA10Ratio
            case .fifteen:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA15Ratio
            case .twenty:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio
            }
        }
        switch sensorLocationCountryCode {
        case .usa?:
            switch showAdsInFeedWithRatio {
            case .baseline, .control:
                return noAdsInFeedForNewUsers.shouldShowAdsInFeed ? EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio : nil
            case .ten:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA10Ratio
            case .fifteen:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA15Ratio
            case .twenty:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio
            }
        default:
            return nil
        }
    }

    var shouldChangeChatNowCopyInTurkey: Bool {
        if Bumper.enabled {
            return Bumper.copyForChatNowInTurkey.isActive
        }
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return true
        default:
            return false
        }
    }
    
    var copyForChatNowInTurkey: CopyForChatNowInTurkey {
        if Bumper.enabled {
            return Bumper.copyForChatNowInTurkey
        }
        return CopyForChatNowInTurkey.fromPosition(abTests.copyForChatNowInTurkey.value)
    }
    
    var feedAdsProviderForUS: FeedAdsProviderForUS {
        if Bumper.enabled {
            return Bumper.feedAdsProviderForUS
        }
        return FeedAdsProviderForUS.fromPosition(abTests.feedAdsProviderForUS.value)
    }
    
    var feedAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            switch feedAdsProviderForUS {
            case .moPubAdsForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForAllUsers
            case .moPubAdsForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForOldUsers
            case .googleAdxForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxUSAForAllUsers
            case .googleAdxForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxUSAForOldUsers
            default:
                switch googleAdxForTR {
                case .googleAdxForAllUsers:
                    return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxTRForAllUsers
                case .googleAdxForOldUsers:
                    return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxTRForOldUsers
                default:
                    switch feedAdsProviderForTR {
                    case .moPubAdsForAllUsers:
                        return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForAllUsers
                    case .moPubAdsForOldUsers:
                        return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForOldUsers
                    default:
                        return nil
                    }
                }
            }
        }
        switch sensorLocationCountryCode {
        case .usa?:
            switch feedAdsProviderForUS {
            case .moPubAdsForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForAllUsers
            case .moPubAdsForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForOldUsers
            case .googleAdxForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxUSAForAllUsers
            case .googleAdxForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxUSAForOldUsers
            default:
                return nil
            }
        case .turkey?:
            switch googleAdxForTR {
            case .googleAdxForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxTRForAllUsers
            case .googleAdxForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxTRForOldUsers
            default:
                switch feedAdsProviderForTR {
                case .moPubAdsForAllUsers:
                    return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForAllUsers
                case .moPubAdsForOldUsers:
                    return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForOldUsers
                default:
                    return nil
                }
            }
            
        default:
            return nil
        }
    }

    var shouldChangeChatNowCopyInEnglish: Bool {
        if Bumper.enabled {
            return Bumper.copyForChatNowInEnglish.isActive
        }
        switch (localeCountryCode) {
        case .usa?:
            return true
        default:
            return false
        }
    }
    
    var copyForChatNowInEnglish: CopyForChatNowInEnglish {
        if Bumper.enabled {
            return Bumper.copyForChatNowInEnglish
        }
        return CopyForChatNowInEnglish.fromPosition(abTests.copyForChatNowInEnglish.value)
    }

    var shouldShowIAmInterestedInFeed: IAmInterestedFeed {
        if Bumper.enabled {
            return Bumper.iAmInterestedFeed
        }
        return IAmInterestedFeed.fromPosition(abTests.iAmInterestedInFeed.value)
    }
    
    var feedAdsProviderForTR: FeedAdsProviderForTR {
        if Bumper.enabled {
            return Bumper.feedAdsProviderForTR
        }
        return FeedAdsProviderForTR.fromPosition(abTests.feedAdsProviderForTR.value)
    }

    var shouldChangeSellFasterNowCopyInEnglish: Bool {
        if Bumper.enabled {
            return Bumper.copyForSellFasterNowInEnglish.isActive
        }
        switch (localeCountryCode) {
        case .usa?:
            return true
        default:
            return false
        }
    }

    var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish {
        if Bumper.enabled {
            return Bumper.copyForSellFasterNowInEnglish
        }
        return CopyForSellFasterNowInEnglish.fromPosition(abTests.copyForSellFasterNowInEnglish.value)
    }

    var googleAdxForTR: GoogleAdxForTR {
        if Bumper.enabled {
            return Bumper.googleAdxForTR
        }
        return GoogleAdxForTR.fromPosition(abTests.googleAdxForTR.value)
    }
    
    var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS {
        if Bumper.enabled {
            return Bumper.fullScreenAdsWhenBrowsingForUS
        }
        return FullScreenAdsWhenBrowsingForUS.fromPosition(abTests.fullScreenAdsWhenBrowsingForUS.value)
    }
    
    var fullScreenAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            switch fullScreenAdsWhenBrowsingForUS {
            case .adsForAllUsers:
                return EnvironmentProxy.sharedInstance.fullScreenAdUnitIdAdxForAllUsersForUS
            case .adsForOldUsers:
                return EnvironmentProxy.sharedInstance.fullScreenAdUnitIdAdxForOldUsersForUS
            default:
                return nil
            }
        }
        switch sensorLocationCountryCode {
        case .usa?:
            switch fullScreenAdsWhenBrowsingForUS {
            case .adsForAllUsers:
                return EnvironmentProxy.sharedInstance.fullScreenAdUnitIdAdxForAllUsersForUS
            case .adsForOldUsers:
                return EnvironmentProxy.sharedInstance.fullScreenAdUnitIdAdxForOldUsersForUS
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var appInstallAdsInFeedAdUnit: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxInstallAppUSA
        }
        switch sensorLocationCountryCode {
        case .usa?:
            return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxInstallAppUSA
        case .turkey?:
            return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxInstallAppTR
        default:
            return nil
        }
    }
    
    var appInstallAdsInFeed: AppInstallAdsInFeed {
        if Bumper.enabled {
            return Bumper.appInstallAdsInFeed
        }
        return AppInstallAdsInFeed.fromPosition(abTests.appInstallAdsInFeed.value)
    }

    var alwaysShowBumpBannerWithLoading: AlwaysShowBumpBannerWithLoading {
        if Bumper.enabled {
            return Bumper.alwaysShowBumpBannerWithLoading
        }
        return AlwaysShowBumpBannerWithLoading.fromPosition(abTests.alwaysShowBumpBannerWithLoading.value)
    }

    var showSellFasterInProfileCells: ShowSellFasterInProfileCells {
        if Bumper.enabled {
            return Bumper.showSellFasterInProfileCells
        }
        return ShowSellFasterInProfileCells.fromPosition(abTests.showSellFasterInProfileCells.value)
    }

    var bumpInEditCopys: BumpInEditCopys {
        if Bumper.enabled {
            return Bumper.bumpInEditCopys
        }
        return BumpInEditCopys.fromPosition(abTests.bumpInEditCopys.value)
    }
  
    var shouldChangeSellFasterNowCopyInTurkish: Bool {
        if Bumper.enabled {
            return Bumper.copyForSellFasterNowInTurkish.isActive
        }
        switch (localeCountryCode) {
        case .turkey?:
            return true
        default:
            return false
        }
    }

    var copyForSellFasterNowInTurkish: CopyForSellFasterNowInTurkish {
        if Bumper.enabled {
            return Bumper.copyForSellFasterNowInTurkish
        }
        return CopyForSellFasterNowInTurkish.fromPosition(abTests.copyForSellFasterNowInTurkish.value)
    }
  
    var multiAdRequestMoreInfo: MultiAdRequestMoreInfo {
        if Bumper.enabled {
            return Bumper.multiAdRequestMoreInfo
        }
        return MultiAdRequestMoreInfo.fromPosition(abTests.multiAdRequestMoreInfo.value)
    }

    // MARK: - Private

    private var locationCountryCode: CountryCode? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return CountryCode(string: countryCode)
    }

    private var localeCountryCode: CountryCode? {
        return CountryCode(string: locale.lg_countryCode)
    }

    private var sensorLocationCountryCode: CountryCode? {
        guard let countryCode = locationManager.currentAutoLocation?.countryCode else { return nil }
        return CountryCode(string: countryCode)
    }
}

// MARK: Chat

extension UserIsTyping {
    var isActive: Bool { return self == .active }
}

extension ChatNorris {
    var isActive: Bool { return self == .redButton || self == .whiteButton || self == .greenButton }
}

extension ShowChatConnectionStatusBar {
    var isActive: Bool { return self == .active }
}

extension ExpressChatImprovement {
    var isActive: Bool { return self == .hideDontAsk || self == .newTitleAndHideDontAsk }
}

extension SmartQuickAnswers {
    var isActive: Bool { return self == .active }
}

extension FeatureFlags {
    
    var showInactiveConversations: Bool {
        if Bumper.enabled {
            return Bumper.showInactiveConversations
        }
        return abTests.showInactiveConversations.value
    }
    
    var showChatSafetyTips: Bool {
        if Bumper.enabled {
            return Bumper.showChatSafetyTips
        }
        return abTests.showChatSafetyTips.value
    }
    
    var userIsTyping: UserIsTyping {
        if Bumper.enabled {
            return Bumper.userIsTyping
        }
        return UserIsTyping.fromPosition(abTests.userIsTyping.value)
    }
    
    var chatNorris: ChatNorris {
        if Bumper.enabled {
            return Bumper.chatNorris
        }
        return  ChatNorris.fromPosition(abTests.chatNorris.value)
    }
    
    var showChatConnectionStatusBar: ShowChatConnectionStatusBar {
        if Bumper.enabled {
            return Bumper.showChatConnectionStatusBar
        }
        return  ShowChatConnectionStatusBar.fromPosition(abTests.showChatConnectionStatusBar.value)
    }

    var showChatHeaderWithoutListingForAssistant: Bool {
        if Bumper.enabled {
            return Bumper.showChatHeaderWithoutListingForAssistant
        }
        return abTests.showChatHeaderWithoutListingForAssistant.value
    }

    var showChatHeaderWithoutUser: Bool {
        if Bumper.enabled {
            return Bumper.showChatHeaderWithoutUser
        }
        return abTests.showChatHeaderWithoutUser.value
    }

    var enableCTAMessageType: Bool {
        if Bumper.enabled {
            return Bumper.enableCTAMessageType
        }
        return abTests.enableCTAMessageType.value
    }

    var expressChatImprovement: ExpressChatImprovement {
        if Bumper.enabled {
            return Bumper.expressChatImprovement
        }
        return  ExpressChatImprovement.fromPosition(abTests.expressChatImprovement.value)
    }
    
    var smartQuickAnswers: SmartQuickAnswers {
        if Bumper.enabled {
            return Bumper.smartQuickAnswers
        }
        return SmartQuickAnswers.fromPosition(abTests.smartQuickAnswers.value)
    }
    var openChatFromUserProfile: OpenChatFromUserProfile {
        if Bumper.enabled {
            return Bumper.openChatFromUserProfile
        }
        return OpenChatFromUserProfile.fromPosition(abTests.openChatFromUserProfile.value)
    }
}

// MARK: Verticals

extension FeatureFlags {
    
    var carExtraFieldsEnabled: CarExtraFieldsEnabled {
        if Bumper.enabled {
            return Bumper.carExtraFieldsEnabled
        }
        return CarExtraFieldsEnabled.fromPosition(abTests.carExtraFieldsEnabled.value)
    }
    
    var realEstateMapTooltip: RealEstateMapTooltip {
        if Bumper.enabled {
            return Bumper.realEstateMapTooltip
        }
        return RealEstateMapTooltip.fromPosition(abTests.realEstateMapTooltip.value)
    }
    
    var servicesUnifiedFilterScreen: ServicesUnifiedFilterScreen {
        if Bumper.enabled {
            return Bumper.servicesUnifiedFilterScreen
        }
        return ServicesUnifiedFilterScreen.fromPosition(abTests.servicesUnifiedFilterScreen.value)
    }
    
    var servicesPaymentFrequency: ServicesPaymentFrequency {
        if Bumper.enabled {
            return Bumper.servicesPaymentFrequency
        }
        return ServicesPaymentFrequency.fromPosition(abTests.servicesPaymentFrequency.value)
    }
    
    var jobsAndServicesEnabled: EnableJobsAndServicesCategory {
        if Bumper.enabled {
            return Bumper.enableJobsAndServicesCategory
        }
        
        return .control
        // FIXME: Enable A/B Test
    }
}


// MARK: Discovery

private extension PersonalizedFeed {
    static let defaultVariantValue = 4
}

extension FeatureFlags {
    /**
     This AB test has 3 cases: control(0), baseline(1) and active(2)
     But discovery team wants to be able to send values that are larger than 2 without us touching the code.
     
     Therefore, we assign all cases with abtest value > 2 as active
                and the rest falls back to control or baseline.
     ABIOS-4113 https://ambatana.atlassian.net/browse/ABIOS-4113
     */
    var personalizedFeed: PersonalizedFeed {
        if Bumper.enabled {
            return Bumper.personalizedFeed
        }
        if abTests.personlizedFeedIsActive {
            return PersonalizedFeed.personalized
        } else {
            return PersonalizedFeed.fromPosition(abTests.personalizedFeed.value)
        }
    }
    
    var personalizedFeedABTestIntValue: Int? {
        return abTests.personlizedFeedIsActive ? abTests.personalizedFeed.value : PersonalizedFeed.defaultVariantValue
    }
    
    var multiContactAfterSearch: MultiContactAfterSearch {
        if Bumper.enabled { return Bumper.multiContactAfterSearch }
        return MultiContactAfterSearch.fromPosition(abTests.multiContactAfterSearch.value)
    }
    
    var emptySearchImprovements: EmptySearchImprovements {
        if Bumper.enabled { return Bumper.emptySearchImprovements }
        return EmptySearchImprovements.fromPosition(abTests.emptySearchImprovements.value)
    }

    var cachedFeed: CachedFeed {
        if Bumper.enabled { return Bumper.cachedFeed }
        return CachedFeed.fromPosition(abTests.cachedFeed.value)
    }
}

extension EmptySearchImprovements {
    
    static let minNumberOfListing = 20
    
    func shouldContinueWithSimilarQueries(withCurrentListing numListings: Int) -> Bool {
        let resultIsInsufficient = numListings < EmptySearchImprovements.minNumberOfListing
            && self == .similarQueriesWhenFewResults
        let shouldAlwaysShowSimilar = self == .alwaysSimilar
        return resultIsInsufficient || shouldAlwaysShowSimilar
    }
    
    var isActive: Bool {
        return self != .control && self != .baseline
    }
    
    var filterDescription: String? {
        switch self {
        case .baseline, .control: return nil
        case .popularNearYou, .similarQueries, .similarQueriesWhenFewResults, .alwaysSimilar: return R.Strings.listingShowSimilarResultsDescription
        }
    }
}

extension CachedFeed {
    var isActive: Bool { return self == .active }
}

// MARK: Products

extension FeatureFlags {

    var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu {
        if Bumper.enabled {
            return Bumper.servicesCategoryOnSalchichasMenu
        }
        return ServicesCategoryOnSalchichasMenu.fromPosition(abTests.servicesCategoryOnSalchichasMenu.value)
    }

    var predictivePosting: PredictivePosting {
        if Bumper.enabled {
            return Bumper.predictivePosting
        }
        return PredictivePosting.fromPosition(abTests.predictivePosting.value)
    }

    var videoPosting: VideoPosting {
        if Bumper.enabled {
            return Bumper.videoPosting
        }
        return VideoPosting.fromPosition(abTests.videoPosting.value)
    }

    var simplifiedChatButton: SimplifiedChatButton {
        if Bumper.enabled {
            return Bumper.simplifiedChatButton
        }
        return SimplifiedChatButton.fromPosition(abTests.simplifiedChatButton.value)
    }

    var frictionlessShare: FrictionlessShare {
        if Bumper.enabled {
            return Bumper.frictionlessShare
        }
        return FrictionlessShare.fromPosition(abTests.frictionlessShare.value)
    }
}

// MARK: Money

extension FeatureFlags {
    
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers {
        if Bumper.enabled {
            return Bumper.preventMessagesFromFeedToProUsers
        }
        return PreventMessagesFromFeedToProUsers.fromPosition(abTests.preventMessagesFromFeedToProUsers.value)
    }
}


// MARK: Retention

extension FeatureFlags {
    
    var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        if Bumper.enabled {
            return Bumper.onboardingIncentivizePosting
        }
        return OnboardingIncentivizePosting.fromPosition(abTests.onboardingIncentivizePosting.value)
    }
    
    var highlightedIAmInterestedInFeed: HighlightedIAmInterestedFeed {
        if Bumper.enabled {
            return Bumper.highlightedIAmInterestedFeed
        }
        return HighlightedIAmInterestedFeed.fromPosition(abTests.highlightedIAmInterestedInFeed.value)
    }
    
    var notificationSettings: NotificationSettings {
        if Bumper.enabled {
            return Bumper.notificationSettings
        }
        return NotificationSettings.fromPosition(abTests.notificationSettings.value)
    }
    
    var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions {
        if Bumper.enabled {
            return Bumper.searchAlertsInSearchSuggestions
        }
        return SearchAlertsInSearchSuggestions.fromPosition(abTests.searchAlertsInSearchSuggestions.value)
    }
    
    var engagementBadging: EngagementBadging {
        if Bumper.enabled {
            return Bumper.engagementBadging
        }
        return EngagementBadging.fromPosition(abTests.engagementBadging.value)
    }
    
    var searchAlertsDisableOldestIfMaximumReached: SearchAlertsDisableOldestIfMaximumReached {
        if Bumper.enabled {
            return Bumper.searchAlertsDisableOldestIfMaximumReached
        }
        return SearchAlertsDisableOldestIfMaximumReached.fromPosition(abTests.searchAlertsDisableOldestIfMaximumReached.value)
    }
}
