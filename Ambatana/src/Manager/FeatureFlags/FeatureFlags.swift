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

    var realEstateEnabled: RealEstateEnabled { get }
    var deckItemPage: NewItemPageV3 { get }

    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio { get }
    var searchImprovements: SearchImprovements { get }
    var relaxedSearch: RelaxedSearch { get }
    var mutePushNotifications: MutePushNotifications { get }
    var facebookUnavailable: Bool { get }
    var showProTagUserProfile: Bool { get }
    var showExactLocationForPros: Bool { get }
    var showPasswordlessLogin: ShowPasswordlessLogin { get }
    
    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var shouldHightlightFreeFilterInFeed: Bool { get }

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
    var feedAdUnitId: String? { get }
    var shouldChangeChatNowCopyInEnglish: Bool { get }
    var copyForChatNowInEnglish: CopyForChatNowInEnglish { get }
    var shouldChangeSellFasterNowCopyInEnglish: Bool { get }
    var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish { get }
    var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS { get }
    var fullScreenAdUnitId: String? { get }
    var appInstallAdsInFeed: AppInstallAdsInFeed { get }
    var appInstallAdsInFeedAdUnit: String? { get }
    var alwaysShowBumpBannerWithLoading: AlwaysShowBumpBannerWithLoading { get }
    var showSellFasterInProfileCells: ShowSellFasterInProfileCells { get }
    var bumpInEditCopys: BumpInEditCopys { get }

    var copyForSellFasterNowInTurkish: CopyForSellFasterNowInTurkish { get }
    var multiAdRequestMoreInfo: MultiAdRequestMoreInfo { get }
    var multiDayBumpUp: MultiDayBumpUp { get }
    
    // MARK: Chat
    var showInactiveConversations: Bool { get }
    var showChatSafetyTips: Bool { get }
    var chatNorris: ChatNorris { get }
    var showChatConnectionStatusBar: ShowChatConnectionStatusBar { get }
    var showChatHeaderWithoutUser: Bool { get }
    var enableCTAMessageType: Bool { get }
    var expressChatImprovement: ExpressChatImprovement { get }
    var smartQuickAnswers: SmartQuickAnswers { get }
    var openChatFromUserProfile: OpenChatFromUserProfile { get }
    var markAsSoldQuickAnswerNewFlow: MarkAsSoldQuickAnswerNewFlow { get }
    var shouldMoveLetsMeetAction: Bool { get }

    // MARK: Verticals
    var jobsAndServicesEnabled: EnableJobsAndServicesCategory { get }
    var servicesPaymentFrequency: ServicesPaymentFrequency { get }
    var carPromoCells: CarPromoCells { get }
    var servicesPromoCells: ServicesPromoCells { get }
    var realEstatePromoCells: RealEstatePromoCells { get }
    var clickToTalk: ClickToTalk { get }
    var proUsersExtraImages: ProUsersExtraImages { get }
    var boostSmokeTest: BoostSmokeTest { get }
    
    // MARK: Discovery
    var personalizedFeed: PersonalizedFeed { get }
    var personalizedFeedABTestIntValue: Int? { get }
    var sectionedFeed: SectionedDiscoveryFeed { get }
    var sectionedFeedABTestIntValue: Int { get }
    var newSearchAPI: NewSearchAPIEndPoint { get }

    // MARK: Products
    var predictivePosting: PredictivePosting { get }
    var simplifiedChatButton: SimplifiedChatButton { get }
    var frictionlessShare: FrictionlessShare { get }
    var turkeyFreePosting: TurkeyFreePosting { get }
    var bulkPosting: BulkPosting{ get }
    var makeAnOfferButton: MakeAnOfferButton { get }

    // MARK: Users
    var emergencyLocate: EmergencyLocate { get }
    var offensiveReportAlert: OffensiveReportAlert { get }
    var community: ShowCommunity { get }
    var advancedReputationSystem11: AdvancedReputationSystem11 { get }
    var advancedReputationSystem12: AdvancedReputationSystem12 { get }
    var advancedReputationSystem13: AdvancedReputationSystem13 { get }

    // MARK: Money
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers { get }
    var multiAdRequestInChatSectionForUS: MultiAdRequestInChatSectionForUS { get }
    var multiAdRequestInChatSectionForTR: MultiAdRequestInChatSectionForTR { get }
    var multiAdRequestInChatSectionAdUnitId: String? { get }
    var bumpPromoAfterSellNoLimit: BumpPromoAfterSellNoLimit { get }
    var polymorphFeedAdsUSA: PolymorphFeedAdsUSA { get }
    
    // MARK: Retention
    var dummyUsersInfoProfile: DummyUsersInfoProfile { get }
    var onboardingIncentivizePosting: OnboardingIncentivizePosting { get }
    var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions { get }
    var engagementBadging: EngagementBadging { get }
    var searchAlertsDisableOldestIfMaximumReached: SearchAlertsDisableOldestIfMaximumReached { get }
    var randomImInterestedMessages: RandomImInterestedMessages { get }
    var imInterestedInProfile: ImInterestedInProfile { get }
    var shareAfterScreenshot: ShareAfterScreenshot { get }
    var affiliationEnabled: AffiliationEnabled { get }
    var imageSizesNotificationCenter: ImageSizesNotificationCenter { get }
    var blockingSignUp: BlockingSignUp {  get }

    var rx_affiliationEnabled: Observable<AffiliationEnabled> { get }
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}

extension FeatureFlaggeable {
    var chatNowButtonText: String {
        if shouldChangeChatNowCopyInTurkey {
            return R.Strings.bumpUpProductCellChatNowButton
        } else if shouldChangeChatNowCopyInEnglish {
            return R.Strings.bumpUpProductCellChatNowButtonEnglishB
        }
        return R.Strings.bumpUpProductCellChatNowButton
    }
}

extension RealEstateEnabled {
    var isActive: Bool { return self == .active }
}

extension ShowAdsInFeedWithRatio {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension DummyUsersInfoProfile {
    var isActive: Bool { return self == .active }
}

extension OnboardingIncentivizePosting {
    var isActive: Bool { return self == .blockingPosting || self == .blockingPostingSkipWelcome }
}

extension EnableJobsAndServicesCategory {
    var isActive: Bool { return self == .active }
}

extension ServicesPaymentFrequency {
    var isActive: Bool { return self == .active }
}

extension CarPromoCells {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension ServicesPromoCells {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension RealEstatePromoCells {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension NewItemPageV3 {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension OpenChatFromUserProfile {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension ProUsersExtraImages {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension ClickToTalk {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension BoostSmokeTest {
    var isActive: Bool { return self != .control && self != .baseline }
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

extension ShowCommunity {
    var isActive: Bool {  return self != .baseline && self != .control }
    var shouldShowOnTab: Bool { return isActive && self == .communityOnTabBar }
    var shouldShowOnNavBar: Bool { return isActive && self == .communityOnNavBar }
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

extension PersonalizedFeed {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension EngagementBadging {
    var isActive: Bool { return self == .active }
}

extension AdvancedReputationSystem11 {
    var isActive: Bool { return self == .active }
}

extension AdvancedReputationSystem12 {
    var isActive: Bool { return self == .active }
}

extension AdvancedReputationSystem13 {
    var isActive: Bool { return self == .active }
}

// MARK: Products

extension PredictivePosting {
    var isActive: Bool { return self == .active }

    func isSupportedFor(postCategory: PostCategory?, language: String) -> Bool {
        if #available(iOS 11, *), isActive, postCategory?.listingCategory.isProduct ?? false, language == "en" {
            return true
        } else {
            return false
        }
    }
}

extension FrictionlessShare {
    var isActive: Bool { return self == .active }
}

extension TurkeyFreePosting {
    var isActive: Bool { return self == .active }
}

extension BulkPosting {
    var isActive: Bool { return self != .control && self != .baseline }

    var productsLimit: Int {
        switch self {
        case .control, .baseline:
            return 0
        case .variantA, .variantD:
            return 5
        case .variantB:
            return 10
        case .variantC:
            return 25
        }
    }

    var showDoneButtonInCameraScreen: Bool {
        switch self {
        case .control, .baseline, .variantD:
            return false
        case .variantA, .variantB, .variantC:
            return true
        }
    }

    func supportsCategory(category: PostCategory?) -> Bool {
        switch category {
        case .otherItems?:
            return isActive
        default:
            return false
        }
    }
}
extension MakeAnOfferButton {
    var isActive: Bool { return self == .active }
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
            creationDate.isNewerThan(seconds: SharedConstants.newUserTimeThresholdForAds) else { return shouldShowFullScreenAdsForOldUsers }
        return shouldShowFullScreenAdsForNewUsers
    }
}

extension PreventMessagesFromFeedToProUsers {
    var isActive: Bool { return self == .active }
}

extension MarkAsSoldQuickAnswerNewFlow {
    var isActive: Bool { return self == .markAsSoldNewFlowQuickAnswer }
}

extension MultiAdRequestInChatSectionForUS {
    var isActive: Bool { return self == .active }
    
    func shouldShowAdsForUser(createdIn: Date?) -> Bool {
        guard isActive else { return false }
        return createdIn?.isOlderThan(seconds: SharedConstants.newUserTimeThresholdForAds) ?? false
    }
}

extension MultiAdRequestInChatSectionForTR {
    var isActive: Bool { return self == .active }
    
    func shouldShowAdsForUser(createdIn: Date?) -> Bool {
        guard isActive else { return false }
        return createdIn?.isOlderThan(seconds: SharedConstants.newUserTimeThresholdForAds) ?? false
    }
}

extension BumpPromoAfterSellNoLimit {
    var isActive: Bool { return self == .alwaysShow || self == .straightToBump }
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

extension RandomImInterestedMessages {
    var isActive: Bool { return self == .active }
}

extension ImInterestedInProfile {
    var isActive: Bool { return self == .active }
}

extension ShareAfterScreenshot {
    var isActive: Bool { return self == .active }
}

extension AffiliationEnabled {
    var isActive: Bool { return self == .active }
}

extension ImageSizesNotificationCenter {
    var isActive: Bool {
        return self == .nineSix || self == .oneTwoEight
    }
}

extension BlockingSignUp {
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

extension MultiDayBumpUp {
    var isActive: Bool { return self != .control && self != .baseline }
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
        if Bumper.enabled {
            dao.save(mutePushNotifications: Bumper.mutePushNotifications,
                     hourStart: abTests.core.mutePushNotificationsStartHour.value,
                     hourEnd: abTests.core.mutePushNotificationsEndHour.value)
            dao.save(affiliationEnabled: Bumper.affiliationEnabled)
            dao.save(blockingSignUp: Bumper.blockingSignUp)
        } else {
            dao.save(emergencyLocate: EmergencyLocate.fromPosition(abTests.emergencyLocate.value))
            dao.save(community: ShowCommunity.fromPosition(abTests.community.value))
            dao.save(advancedReputationSystem11: AdvancedReputationSystem11.fromPosition(abTests.advancedReputationSystem11.value))
            dao.save(advancedReputationSystem12: AdvancedReputationSystem12.fromPosition(abTests.advancedReputationSystem12.value))
            dao.save(advancedReputationSystem13: AdvancedReputationSystem13.fromPosition(abTests.advancedReputationSystem13.value))
            dao.save(mutePushNotifications: MutePushNotifications.fromPosition(abTests.core.mutePushNotifications.value),
                     hourStart: abTests.core.mutePushNotificationsStartHour.value,
                     hourEnd: abTests.core.mutePushNotificationsEndHour.value)
            dao.save(affiliationEnabled: AffiliationEnabled.fromPosition(abTests.affiliationCampaign.value))
            dao.save(blockingSignUp: BlockingSignUp.fromPosition(abTests.blockingSignUp.value))
        }
    }

    var realEstateEnabled: RealEstateEnabled {
        if Bumper.enabled {
            return Bumper.realEstateEnabled
        }
        return RealEstateEnabled.fromPosition(abTests.realEstateEnabled.value)
    }

    var deckItemPage: NewItemPageV3 {
        if Bumper.enabled {
            return Bumper.newItemPageV3
        }
        return NewItemPageV3.fromPosition(abTests.deckItemPage.value)
    }

    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        if Bumper.enabled {
            return Bumper.showAdsInFeedWithRatio
        }
        return ShowAdsInFeedWithRatio.fromPosition(abTests.showAdsInFeedWithRatio.value)
    }
    
    var dummyUsersInfoProfile: DummyUsersInfoProfile {
        if Bumper.enabled {
            return Bumper.dummyUsersInfoProfile
        }
        return DummyUsersInfoProfile.fromPosition(abTests.dummyUsersInfoProfile.value)
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
    
    var mutePushNotifications: MutePushNotifications {
        if Bumper.enabled {
            return Bumper.mutePushNotifications
        }
        let cached = dao.retrieveMutePushNotifications()?.toMutePushNotifications()
        return cached ?? MutePushNotifications.fromPosition(abTests.mutePushNotifications.value)
    }

    var mutePushNotificationsStartHour: Int {
        return abTests.mutePushNotificationsStartHour.value
    }
    
    var mutePushNotificationsEndHour: Int {
        return abTests.mutePushNotificationsEndHour.value
    }
    
    var facebookUnavailable: Bool {
        if Bumper.enabled {
            return Bumper.facebookUnavailable
        }
        return abTests.facebookUnavailable.value
    }
    
    var showProTagUserProfile: Bool {
        if Bumper.enabled {
            return Bumper.showProTagUserProfile
        }
        return abTests.showProTagUserProfile.value
    }

    var community: ShowCommunity {
        if Bumper.enabled {
            return Bumper.showCommunity
        }
        let cached = dao.retrieveCommunity()
        return cached ?? ShowCommunity.fromPosition(abTests.community.value)
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
    
    var markAsSoldQuickAnswerNewFlow: MarkAsSoldQuickAnswerNewFlow {
        if Bumper.enabled {
            return Bumper.markAsSoldQuickAnswerNewFlow
        }
        return MarkAsSoldQuickAnswerNewFlow.fromPosition(abTests.markAsSoldQuickAnswerNewFlow.value)
    }
    
    var shouldMoveLetsMeetAction: Bool {
        if Bumper.enabled {
            return Bumper.shouldMoveLetsMeetAction && !chatNorris.isActive
        }
        return abTests.shouldMoveLetsMeetAction.value && !chatNorris.isActive
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

    var advancedReputationSystem11: AdvancedReputationSystem11 {
        if Bumper.enabled {
            return Bumper.advancedReputationSystem11
        }
        let cached = dao.retrieveAdvancedReputationSystem11()
        return cached ?? AdvancedReputationSystem11.fromPosition(abTests.advancedReputationSystem11.value)
    }

    var advancedReputationSystem12: AdvancedReputationSystem12 {
        if Bumper.enabled {
            return Bumper.advancedReputationSystem12
        }
        let cached = dao.retrieveAdvancedReputationSystem12()
        return cached ?? AdvancedReputationSystem12.fromPosition(abTests.advancedReputationSystem12.value)
    }

    var advancedReputationSystem13: AdvancedReputationSystem13 {
        if Bumper.enabled {
            return Bumper.advancedReputationSystem13
        }
        let cached = dao.retrieveAdvancedReputationSystem13()
        return cached ?? AdvancedReputationSystem13.fromPosition(abTests.advancedReputationSystem13.value)
    }

    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        switch locationCountryCode {
        case .turkey?:
            return turkeyFreePosting.isActive
        default:
            return true
        }
    }

    var shouldHightlightFreeFilterInFeed: Bool {
        switch locationCountryCode {
        case .turkey?: return freePostingModeAllowed // just for turkey
        default: return false
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
                return nil
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
                return nil
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
    
    var feedAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxUSAForOldUsers
        }
        switch sensorLocationCountryCode {
        case .usa?:
            return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxUSAForOldUsers
        case .turkey?:
            return EnvironmentProxy.sharedInstance.feedAdUnitIdAdxTRForOldUsers
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

    var multiDayBumpUp: MultiDayBumpUp {
        if Bumper.enabled {
            return Bumper.multiDayBumpUp
        }
        return MultiDayBumpUp.fromPosition(abTests.multiDayBumpUp.value)
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

extension NewSearchAPIEndPoint {
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
        
        return EnableJobsAndServicesCategory.fromPosition(abTests.jobsAndServicesEnabled.value)
    }
    
    var carPromoCells: CarPromoCells {
        if Bumper.enabled {
            return Bumper.carPromoCells
        }
        
        return CarPromoCells.fromPosition(abTests.carPromoCells.value)
    }
    
    var servicesPromoCells: ServicesPromoCells {
        if Bumper.enabled {
            return Bumper.servicesPromoCells
        }
        
        return ServicesPromoCells.fromPosition(abTests.servicesPromoCells.value)
    }
    
    var realEstatePromoCells: RealEstatePromoCells {
        if Bumper.enabled {
            return Bumper.realEstatePromoCells
        }
        
        return RealEstatePromoCells.fromPosition(abTests.realEstatePromoCells.value)
    }
    
    var proUsersExtraImages: ProUsersExtraImages {
        if Bumper.enabled {
            return Bumper.proUsersExtraImages
        }
        
        return ProUsersExtraImages.fromPosition(abTests.proUserExtraImages.value)
    }
    
    var clickToTalk: ClickToTalk {
        if Bumper.enabled {
            return Bumper.clickToTalk
        }
        return ClickToTalk.fromPosition(abTests.clickToTalk.value)
    }
    
    var boostSmokeTest: BoostSmokeTest {
        if Bumper.enabled {
            return Bumper.boostSmokeTest
        }
        return .control //BoostSmokeTest.fromPosition(abTests.boostSmokeTest.value)
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

    var sectionedFeed: SectionedDiscoveryFeed {
        if Bumper.enabled {
            return Bumper.sectionedDiscoveryFeed
        }
        if abTests.sectionedFeedIsActive {
            return SectionedDiscoveryFeed.active
        } else {
            return SectionedDiscoveryFeed.fromPosition(sectionedFeedABTestIntValue)
        }
    }
    
    var sectionedFeedABTestIntValue: Int {
        return abTests.sectionedFeed.value
    }
    
    var newSearchAPI: NewSearchAPIEndPoint {
        if Bumper.enabled { return Bumper.newSearchAPIEndPoint }
        return NewSearchAPIEndPoint.fromPosition(abTests.newSearchAPI.value)
    }
}

// MARK: Products

extension FeatureFlags {

    var predictivePosting: PredictivePosting {
        if Bumper.enabled {
            return Bumper.predictivePosting
        }
        return PredictivePosting.fromPosition(abTests.predictivePosting.value)
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

    var turkeyFreePosting: TurkeyFreePosting {
        if Bumper.enabled {
            return Bumper.turkeyFreePosting
        }
        return TurkeyFreePosting.fromPosition(abTests.turkeyFreePosting.value)
    }

    var bulkPosting: BulkPosting {
        if Bumper.enabled {
            return Bumper.bulkPosting
        }
        return BulkPosting.fromPosition(abTests.bulkPosting.value)
    }

    var makeAnOfferButton: MakeAnOfferButton {
        if Bumper.enabled {
            return Bumper.makeAnOfferButton
        }
        return MakeAnOfferButton.fromPosition(abTests.makeAnOfferButton.value)
    }
}

// MARK: Money

extension PolymorphFeedAdsUSA {
    var isActive: Bool { return self == .active }
}

extension FeatureFlags {
    
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers {
        if Bumper.enabled {
            return Bumper.preventMessagesFromFeedToProUsers
        }
        return PreventMessagesFromFeedToProUsers.fromPosition(abTests.preventMessagesFromFeedToProUsers.value)
    }
    
    var multiAdRequestInChatSectionForUS: MultiAdRequestInChatSectionForUS {
        if Bumper.enabled {
            return Bumper.multiAdRequestInChatSectionForUS
        }
        return MultiAdRequestInChatSectionForUS.fromPosition(abTests.multiAdRequestInChatSectionForUS.value)
    }
    
    var multiAdRequestInChatSectionForTR: MultiAdRequestInChatSectionForTR {
        if Bumper.enabled {
            return Bumper.multiAdRequestInChatSectionForTR
        }
        return MultiAdRequestInChatSectionForTR.fromPosition(abTests.multiAdRequestInChatSectionForTR.value)
    }
    
    var multiAdRequestInChatSectionAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            return multiAdRequestInChatSectionForUS.isActive ? EnvironmentProxy.sharedInstance.chatSectionAdUnitForOldUsersUS : nil
        }
        switch sensorLocationCountryCode {
        case .usa?:
            return multiAdRequestInChatSectionForUS.isActive ? EnvironmentProxy.sharedInstance.chatSectionAdUnitForOldUsersUS : nil
        case .turkey?:
            return multiAdRequestInChatSectionForTR.isActive ? EnvironmentProxy.sharedInstance.chatSectionAdUnitForOldUsersTR : nil
        default:
            return nil
        }
    }

    var bumpPromoAfterSellNoLimit: BumpPromoAfterSellNoLimit {
        if Bumper.enabled {
            return Bumper.bumpPromoAfterSellNoLimit
        }
        return BumpPromoAfterSellNoLimit.fromPosition(abTests.bumpPromoAfterSellNoLimit.value)
    }
    
    var polymorphFeedAdsUSA: PolymorphFeedAdsUSA {
        if Bumper.enabled {
            return Bumper.polymorphFeedAdsUSA
        }
        return PolymorphFeedAdsUSA.fromPosition(abTests.polymorphFeedAdsUSA.value)
        
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
    
    var randomImInterestedMessages: RandomImInterestedMessages {
        if Bumper.enabled {
            return Bumper.randomImInterestedMessages
        }
        return RandomImInterestedMessages.fromPosition(abTests.randomImInterestedMessages.value)
    }
    
    var imInterestedInProfile: ImInterestedInProfile {
        if Bumper.enabled {
            return Bumper.imInterestedInProfile
        }
        return ImInterestedInProfile.fromPosition(abTests.imInterestedInProfile.value)
    }
    
    var shareAfterScreenshot: ShareAfterScreenshot {
        if Bumper.enabled {
            return Bumper.shareAfterScreenshot
        }
        return ShareAfterScreenshot.fromPosition(abTests.shareAfterScreenshot.value)
    }

    var affiliationEnabled: AffiliationEnabled {
        if Bumper.enabled {
            return Bumper.affiliationEnabled
        }
        return AffiliationEnabled.fromPosition(abTests.affiliationCampaign.value)
    }
    
    var imageSizesNotificationCenter: ImageSizesNotificationCenter {
        if Bumper.enabled {
            return Bumper.imageSizesNotificationCenter
        }
        return ImageSizesNotificationCenter.fromPosition(abTests.imageSizesNotificationCenter.value)
    }
    
    var blockingSignUp: BlockingSignUp {
        if Bumper.enabled {
            return Bumper.blockingSignUp
        }
        return BlockingSignUp.fromPosition(abTests.blockingSignUp.value)
    }

    var rx_affiliationEnabled: Observable<AffiliationEnabled> {
        let old = affiliationEnabled
        return syncedData.filter { $0 }.map { [weak self] synced in
            return self?.affiliationEnabled ?? old
        }
    }
}
