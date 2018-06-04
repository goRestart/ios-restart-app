//
//  MockFeatureFlags.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

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
    var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting = .control
    var realEstateNewCopy: RealEstateNewCopy = .control
    var dummyUsersInfoProfile: DummyUsersInfoProfile = .control
    var showInactiveConversations: Bool = false
    var increaseMinPriceBumps: IncreaseMinPriceBumps = .control
    var newUserProfileView: NewUserProfileView = .control
    var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation = .control
    var searchImprovements: SearchImprovements = .control
    var relaxedSearch: RelaxedSearch = .control
    var showChatSafetyTips: Bool = false
    var discardedProducts: DiscardedProducts = .control
    var userIsTyping: UserIsTyping = .control
    var bumpUpBoost: BumpUpBoost = .control
    var servicesCategoryEnabled: ServicesCategoryEnabled = .control
    var increaseNumberOfPictures: IncreaseNumberOfPictures = .control
    var onboardingIncentivizePosting: OnboardingIncentivizePosting = .control
    var chatNorris: ChatNorris = .control
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings = .control
    var showProTagUserProfile: Bool = false
    var markAllConversationsAsRead: MarkAllConversationsAsRead = .control
    var realEstateTutorial: RealEstateTutorial = .control
    var summaryAsFirstStep: SummaryAsFirstStep = .control
    var showAdvancedReputationSystem: ShowAdvancedReputationSystem = .control
    var showExactLocationForPros: Bool = true
    var showPasswordlessLogin: ShowPasswordlessLogin = .control
    var emergencyLocate: EmergencyLocate = .control

    var searchAlerts: SearchAlerts = .control
    
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
    
    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
    var shareTypes: [ShareType] = []
    var copyForChatNowInEnglish: CopyForChatNowInEnglish = .control
    var shouldChangeChatNowCopyInEnglish = false
    var shouldChangeSellFasterNowCopyInEnglish = false
    var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish = .control
    var shouldShowIAmInterestedInFeed: IAmInterestedFeed = .control

    //  MARK:  Verticals
    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend = .control
    var realEstatePromoCell: RealEstatePromoCell = .control
    var filterSearchCarSellerType: FilterSearchCarSellerType = .control
    var createUpdateIntoNewBackend: CreateUpdateCarsIntoNewBackend = .control
    var realEstateMap: RealEstateMap = .control

    //  MARK:  Products
    var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu = .control
    var predictivePosting: PredictivePosting = .control
    var videoPosting: VideoPosting = .control
}

