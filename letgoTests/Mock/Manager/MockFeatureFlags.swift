@testable import LetGoGodMode
import Foundation
import RxSwift

final class MockFeatureFlags: FeatureFlaggeable {


    var trackingData: Observable<[(String, ABGroup)]?> {
        return trackingDataVar.asObservable()
    }
    func variablesUpdated() {}
    let trackingDataVar = Variable<[(String, ABGroup)]?>(nil)

    var showNPSSurvey: Bool = false
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
    var mostSearchedDemandedItems: MostSearchedDemandedItems = .control
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers = .control
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio = .control
    var realEstateNewCopy: RealEstateNewCopy = .control
    var dummyUsersInfoProfile: DummyUsersInfoProfile = .control
    var searchImprovements: SearchImprovements = .control
    var relaxedSearch: RelaxedSearch = .control
    var bumpUpBoost: BumpUpBoost = .control
    var onboardingIncentivizePosting: OnboardingIncentivizePosting = .control
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings = .control
    var showProTagUserProfile: Bool = false
    var sectionedMainFeed: SectionedMainFeed = .control
    var showExactLocationForPros: Bool = true
    var highlightedIAmInterestedInFeed: HighlightedIAmInterestedFeed = .control
    
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
    var markAllConversationsAsRead: MarkAllConversationsAsRead = .control
    var chatNorris: ChatNorris = .control
    var chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs = .control
    
    // MARK:  Verticals
    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend = .control
    var filterSearchCarSellerType: FilterSearchCarSellerType = .control
    var realEstateMap: RealEstateMap = .control
    var showServicesFeatures: ShowServicesFeatures = .control
    
    // MARK: Discovery
    var personalizedFeed: PersonalizedFeed = .control
    var personalizedFeedABTestIntValue: Int? = nil
    var searchBoxImprovements: SearchBoxImprovements = .control
    var multiContactAfterSearch: MultiContactAfterSearch = .control
    var emptySearchImprovements: EmptySearchImprovements = .control
    
    //  MARK:  Products
    var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu = .control
    var predictivePosting: PredictivePosting = .control
    var videoPosting: VideoPosting = .control
    var simplifiedChatButton: SimplifiedChatButton = .control

    // MARK: Users
    var advancedReputationSystem: AdvancedReputationSystem = .control
    var showPasswordlessLogin: ShowPasswordlessLogin = .control
    var emergencyLocate: EmergencyLocate = .control
    var offensiveReportAlert: OffensiveReportAlert = .control
    
    // MARK: Money
    var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers = .control
}

