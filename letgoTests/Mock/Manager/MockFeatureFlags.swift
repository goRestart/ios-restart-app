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

    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var newCarsMultiRequesterEnabled: Bool = false
    var inAppRatingIOS10: Bool = false
    var userReviewsReportEnabled: Bool = true
    var deckItemPage: DeckItemPage = .control
    var realEstateEnabled: RealEstateEnabled = .control
    var requestTimeOut: RequestsTimeOut = .thirty
    var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed = .control
    var showClockInDirectAnswer: ShowClockInDirectAnswer = .control
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers = .control
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio = .control
    var realEstateNewCopy: RealEstateNewCopy = .control
    var searchImprovements: SearchImprovements = .control
    var relaxedSearch: RelaxedSearch = .control
    var bumpUpBoost: BumpUpBoost = .control
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings = .control
    var showProTagUserProfile: Bool = false
    var sectionedMainFeed: SectionedMainFeed = .control
    var showExactLocationForPros: Bool = true
    
    // Country dependant features
    var freePostingModeAllowed = false
    var postingFlowType: PostingFlowType = .standard
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
    var moreInfoDFPAdUnitId = ""
    var feedDFPAdUnitId: String? = ""
    var shouldChangeChatNowCopyInTurkey = false
    var copyForChatNowInTurkey: CopyForChatNowInTurkey = .control
    var feedAdsProviderForUS: FeedAdsProviderForUS = .control
    var feedAdUnitId: String? = ""
    var feedAdsProviderForTR: FeedAdsProviderForTR = .control
    var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS = .control
    var fullScreenAdUnitId: String? = ""
    var appInstallAdsInFeed: AppInstallAdsInFeed = .control
    var appInstallAdsInFeedAdUnit: String? = ""
    
    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
    var shareTypes: [ShareType] = []
    var copyForChatNowInEnglish: CopyForChatNowInEnglish = .control
    var shouldChangeChatNowCopyInEnglish = false
    var shouldChangeSellFasterNowCopyInEnglish = false
    var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish = .control
    var shouldShowIAmInterestedInFeed: IAmInterestedFeed = .control
    var googleAdxForTR: GoogleAdxForTR = .control

    // MARK: Chat
    var showInactiveConversations: Bool = false
    var showChatSafetyTips: Bool = false
    var userIsTyping: UserIsTyping = .control
    var chatNorris: ChatNorris = .control
    var chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs = .control
    var showChatConnectionStatusBar: ShowChatConnectionStatusBar = .control
    var showChatHeaderWithoutListingForAssistant: Bool = true
    var showChatHeaderWithoutUser: Bool = true
    var enableCTAMessageType: Bool = true
    var expressChatImprovement: ExpressChatImprovement = .control
    
    // MARK:  Verticals
    var realEstateMap: RealEstateMap = .control
    var showServicesFeatures: ShowServicesFeatures = .control
    var carExtraFieldsEnabled: CarExtraFieldsEnabled = .control
    var realEstateMapTooltip: RealEstateMapTooltip = .control
    var servicesUnifiedFilterScreen: ServicesUnifiedFilterScreen = .control
    
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

    // MARK: Users
    var advancedReputationSystem: AdvancedReputationSystem = .control
    var showPasswordlessLogin: ShowPasswordlessLogin = .control
    var emergencyLocate: EmergencyLocate = .control
    var offensiveReportAlert: OffensiveReportAlert = .control
    var reportingFostaSesta: ReportingFostaSesta = .control
    var community: ShowCommunity = .control
    
    // MARK: Money
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers = .control
    
    // MARK: Retention
    var dummyUsersInfoProfile: DummyUsersInfoProfile = .control
    var onboardingIncentivizePosting: OnboardingIncentivizePosting = .control
    var highlightedIAmInterestedInFeed: HighlightedIAmInterestedFeed = .control
    var notificationSettings: NotificationSettings = .control
    var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions = .control
    var engagementBadging: EngagementBadging = .control
}

