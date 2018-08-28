@testable import LetGoGodMode
import Foundation
import RxSwift

final class MockFeatureFlags: FeatureFlaggeable {
 
    var trackingData: Observable<[(String, ABGroup)]?> {
        return trackingDataVar.asObservable()
    }
    func variablesUpdated() {}
    let trackingDataVar = Variable<[(String, ABGroup)]?>(nil)

    var surveyUrl: String = ""
    var surveyEnabled: Bool = false

    var newCarsMultiRequesterEnabled: Bool = false
    var inAppRatingIOS10: Bool = false
    var userReviewsReportEnabled: Bool = true
    var deckItemPage: DeckItemPage = .control
    var realEstateEnabled: RealEstateEnabled = .control
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio = .control
    var realEstateNewCopy: RealEstateNewCopy = .control
    var searchImprovements: SearchImprovements = .control
    var relaxedSearch: RelaxedSearch = .control
    var showProTagUserProfile: Bool = false
    var sectionedMainFeed: SectionedMainFeed = .control
    var showExactLocationForPros: Bool = true
    
    // Country dependant features
    var freePostingModeAllowed = false
    var shouldHightlightFreeFilterInFeed = false

    var postingFlowType: PostingFlowType = .standard
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
    var moreInfoDFPAdUnitId = ""
    var feedDFPAdUnitId: String? = ""
    var shouldChangeChatNowCopyInTurkey = false
    var copyForChatNowInTurkey: CopyForChatNowInTurkey = .control
    var feedAdUnitId: String? = ""
    var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS = .control
    var fullScreenAdUnitId: String? = ""
    var appInstallAdsInFeed: AppInstallAdsInFeed = .control
    var appInstallAdsInFeedAdUnit: String? = ""
    var alwaysShowBumpBannerWithLoading: AlwaysShowBumpBannerWithLoading = .control
    var showSellFasterInProfileCells: ShowSellFasterInProfileCells = .control
    var bumpInEditCopys: BumpInEditCopys = .control
    var multiAdRequestMoreInfo: MultiAdRequestMoreInfo = .control
    var cachedFeed: CachedFeed = .control

    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
    var shareTypes: [ShareType] = []
    var copyForChatNowInEnglish: CopyForChatNowInEnglish = .control
    var shouldChangeChatNowCopyInEnglish = false
    var shouldChangeSellFasterNowCopyInEnglish = false
    var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish = .control
    var copyForSellFasterNowInTurkish: CopyForSellFasterNowInTurkish = .control

    // MARK: Chat
    var showInactiveConversations: Bool = false
    var showChatSafetyTips: Bool = false
    var chatNorris: ChatNorris = .control
    var showChatConnectionStatusBar: ShowChatConnectionStatusBar = .control
    var showChatHeaderWithoutUser: Bool = true
    var enableCTAMessageType: Bool = true
    var expressChatImprovement: ExpressChatImprovement = .control
    var smartQuickAnswers: SmartQuickAnswers = .control
    var openChatFromUserProfile: OpenChatFromUserProfile = .control
    
    // MARK:  Verticals
    var servicesPaymentFrequency: ServicesPaymentFrequency = .control
    var carExtraFieldsEnabled: CarExtraFieldsEnabled = .control
    var realEstateMapTooltip: RealEstateMapTooltip = .control
    var servicesUnifiedFilterScreen: ServicesUnifiedFilterScreen = .control
    var jobsAndServicesEnabled: EnableJobsAndServicesCategory = .control
    var carPromoCells: CarPromoCells = .control
    var realEstatePromoCells: RealEstatePromoCells = .control
    
    // MARK: Discovery
    var personalizedFeed: PersonalizedFeed = .control
    var personalizedFeedABTestIntValue: Int? = nil
    var multiContactAfterSearch: MultiContactAfterSearch = .control
    var emptySearchImprovements: EmptySearchImprovements = .control
    
    //  MARK:  Products
    var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu = .control
    var predictivePosting: PredictivePosting = .control
    var videoPosting: VideoPosting = .control
    var simplifiedChatButton: SimplifiedChatButton = .control
    var frictionlessShare: FrictionlessShare = .control
    var turkeyFreePosting: TurkeyFreePosting = .control

    // MARK: Users
    var showPasswordlessLogin: ShowPasswordlessLogin = .control
    var emergencyLocate: EmergencyLocate = .control
    var offensiveReportAlert: OffensiveReportAlert = .control
    var reportingFostaSesta: ReportingFostaSesta = .control
    var community: ShowCommunity = .control
    var advancedReputationSystem11: AdvancedReputationSystem11 = .control
    
    // MARK: Money
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers = .control
    
    // MARK: Retention
    var dummyUsersInfoProfile: DummyUsersInfoProfile = .control
    var onboardingIncentivizePosting: OnboardingIncentivizePosting = .control
    var notificationSettings: NotificationSettings = .control
    var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions = .control
    var engagementBadging: EngagementBadging = .control
    var searchAlertsDisableOldestIfMaximumReached: SearchAlertsDisableOldestIfMaximumReached = .control
    var notificationCenterRedesign: NotificationCenterRedesign = .control
    var randomImInterestedMessages: RandomImInterestedMessages = .control
}

