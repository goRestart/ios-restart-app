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
    var requestTimeOut: RequestsTimeOut { get }
    var taxonomiesAndTaxonomyChildrenInFeed : TaxonomiesAndTaxonomyChildrenInFeed { get }
    var showClockInDirectAnswer : ShowClockInDirectAnswer { get }
    var deckItemPage: DeckItemPage { get }
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio { get }
    var realEstateNewCopy: RealEstateNewCopy { get }
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers { get }
    var searchImprovements: SearchImprovements { get }
    var relaxedSearch: RelaxedSearch { get }
    var bumpUpBoost: BumpUpBoost { get }
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings { get }
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
    
    // MARK: Chat
    var showInactiveConversations: Bool { get }
    var showChatSafetyTips: Bool { get }
    var userIsTyping: UserIsTyping { get }
    var chatNorris: ChatNorris { get }
    var chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs { get }
    var showChatConnectionStatusBar: ShowChatConnectionStatusBar { get }
    var showChatHeaderWithoutListingForAssistant: Bool { get }

    // MARK: Verticals
    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend { get }
    var filterSearchCarSellerType: FilterSearchCarSellerType { get }
    var realEstateMap: RealEstateMap { get }
    var showServicesFeatures: ShowServicesFeatures { get }
    var carExtraFieldsEnabled: CarExtraFieldsEnabled { get }
    
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

    // MARK: Users
    var advancedReputationSystem: AdvancedReputationSystem { get }
    var emergencyLocate: EmergencyLocate { get }
    var offensiveReportAlert: OffensiveReportAlert { get }
    
    // MARK: Money
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers { get }
    
    // MARK: Retention
    var mostSearchedDemandedItems: MostSearchedDemandedItems { get }
    var dummyUsersInfoProfile: DummyUsersInfoProfile { get }
    var onboardingIncentivizePosting: OnboardingIncentivizePosting { get }
    var highlightedIAmInterestedInFeed: HighlightedIAmInterestedFeed { get }
    var notificationSettings: NotificationSettings { get }
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}

extension TaxonomiesAndTaxonomyChildrenInFeed {
    var isActive: Bool { return self == .active }
}

extension MostSearchedDemandedItems {
    var isActive: Bool {
        return self == .cameraBadge ||
            self == .trendingButtonExpandableMenu ||
            self == .subsetAboveExpandableMenu
    }
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

extension ShowServicesFeatures {
    var isActive: Bool { return self == .active }
}

extension CarExtraFieldsEnabled {
    var isActive: Bool { return self == .active }
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

extension AddPriceTitleDistanceToListings {
    var hideDetailInFeaturedArea: Bool {
        return self == .infoInImage
    }
    
    var showDetailInNormalCell: Bool {
        return self == .infoWithWhiteBackground
    }
    
    var showDetailInImage: Bool {
        return self == .infoInImage
    }
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

extension RealEstateMap {
    var isActive: Bool { return self != .baseline && self != .control }
}

extension FilterSearchCarSellerType {
    var isActive: Bool { return self != .baseline && self != .control }
    
    var isMultiselection: Bool {
        return self == .variantA || self == .variantB
    }
}

extension AdvancedReputationSystem {
    var isActive: Bool { return self != .baseline && self != .control  }
    var shouldShowTooltip: Bool { return self == .variantB }
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

extension SearchCarsIntoNewBackend {
    var isActive: Bool { return self == .active }
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

extension IAmInterestedFeed {
    var isVisible: Bool { return self == .control || self == .baseline }
}

extension PersonalizedFeed {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension NotificationSettings {
    var isActive: Bool { return self == .differentLists || self == .sameList }
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

final class FeatureFlags: FeatureFlaggeable {
    
    static let sharedInstance: FeatureFlags = FeatureFlags()

    let requestTimeOut: RequestsTimeOut

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
        if Bumper.enabled {
            self.requestTimeOut = Bumper.requestsTimeOut
        } else {
            self.requestTimeOut = RequestsTimeOut.buildFromTimeout(dao.retrieveTimeoutForRequests())
                ?? RequestsTimeOut.fromPosition(abTests.requestsTimeOut.value)
        }

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
        if Bumper.enabled {
            dao.save(timeoutForRequests: TimeInterval(Bumper.requestsTimeOut.timeout))
        } else {
            dao.save(timeoutForRequests: TimeInterval(abTests.requestsTimeOut.value))
            dao.save(advanceReputationSystem: AdvancedReputationSystem.fromPosition(abTests.advancedReputationSystem.value))
            dao.save(emergencyLocate: EmergencyLocate.fromPosition(abTests.emergencyLocate.value))
            dao.save(chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs.fromPosition(abTests.chatConversationsListWithoutTabs.value))
        }
        abTests.variablesUpdated()
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

    var mostSearchedDemandedItems: MostSearchedDemandedItems {
        if Bumper.enabled {
            return Bumper.mostSearchedDemandedItems
        }
        return MostSearchedDemandedItems.fromPosition(abTests.mostSearchedDemandedItems.value)
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
    
    var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        if Bumper.enabled {
            return Bumper.onboardingIncentivizePosting
        }
        return OnboardingIncentivizePosting.fromPosition(abTests.onboardingIncentivizePosting.value)
    }
    
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings {
        if Bumper.enabled {
            return Bumper.addPriceTitleDistanceToListings
        }
        return AddPriceTitleDistanceToListings.fromPosition(abTests.addPriceTitleDistanceToListings.value)
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
    
    var highlightedIAmInterestedInFeed: HighlightedIAmInterestedFeed {
        if Bumper.enabled {
            return Bumper.highlightedIAmInterestedFeed
        }
        return HighlightedIAmInterestedFeed.fromPosition(abTests.highlightedIAmInterestedInFeed.value)
    }

    var offensiveReportAlert: OffensiveReportAlert {
        if Bumper.enabled {
            return Bumper.offensiveReportAlert
        }
        return OffensiveReportAlert.fromPosition(abTests.offensiveReportAlert.value)
    }

    var notificationSettings: NotificationSettings {
        if Bumper.enabled {
            return Bumper.notificationSettings
        }
        return NotificationSettings.fromPosition(abTests.notificationSettings.value)
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
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFPUSA
        default:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFP
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

extension ChatConversationsListWithoutTabs {
    var isActive: Bool { return self == .active }
}

extension ShowChatConnectionStatusBar {
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
    
    var chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs {
        if Bumper.enabled {
            return Bumper.chatConversationsListWithoutTabs
        }
        let cached = dao.retrieveChatConversationsListWithoutTabs()
        return cached ?? ChatConversationsListWithoutTabs.fromPosition(abTests.chatConversationsListWithoutTabs.value)
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
}

// MARK: Verticals

extension FeatureFlags {
    
    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend {
        if Bumper.enabled {
            return Bumper.searchCarsIntoNewBackend
        }
        return SearchCarsIntoNewBackend.fromPosition(abTests.searchCarsIntoNewBackend.value)
    }
    
    var filterSearchCarSellerType: FilterSearchCarSellerType {
        if Bumper.enabled {
            return Bumper.filterSearchCarSellerType
        }
        return FilterSearchCarSellerType.fromPosition(abTests.filterSearchCarSellerType.value)
    }
    
    var realEstateMap: RealEstateMap {
        if Bumper.enabled {
            return Bumper.realEstateMap
        }
        return RealEstateMap.fromPosition(abTests.realEstateMap.value)
    }
    
    var showServicesFeatures: ShowServicesFeatures {
        if Bumper.enabled {
            return Bumper.showServicesFeatures
        }
        return ShowServicesFeatures.fromPosition(abTests.showServicesFeatures.value)
    }
    
    var carExtraFieldsEnabled: CarExtraFieldsEnabled {
        if Bumper.enabled {
            return Bumper.carExtraFieldsEnabled
        }
        
        return .control
//        return CarExtraFieldsEnabled.fromPosition(abTests.carExtraFieldsEnabled.value)
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
