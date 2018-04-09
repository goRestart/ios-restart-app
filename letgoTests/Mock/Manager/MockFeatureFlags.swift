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

class MockFeatureFlags: FeatureFlaggeable {
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
    var dynamicQuickAnswers: DynamicQuickAnswers = .control
    var deckItemPage: DeckItemPage = .control
    var searchAutocomplete: SearchAutocomplete = .control
    var realEstateEnabled: RealEstateEnabled = .control
    var requestTimeOut: RequestsTimeOut = .thirty
    var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed = .control
    var showClockInDirectAnswer: ShowClockInDirectAnswer = .control
    var allowCallsForProfessionals: AllowCallsForProfessionals = .control
    var mostSearchedDemandedItems: MostSearchedDemandedItems = .control
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers = .control

    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio = .control
    var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting = .control
    var realEstateNewCopy: RealEstateNewCopy = .control
    var dummyUsersInfoProfile: DummyUsersInfoProfile = .control
    var showInactiveConversations: Bool = false
    var increaseMinPriceBumps: IncreaseMinPriceBumps = .control
    var showBumpUpBannerOnNotValidatedListings: ShowBumpUpBannerOnNotValidatedListings = .control
    var newUserProfileView: NewUserProfileView = .control
    var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation = .control
    var searchImprovements: SearchImprovements = .control
    var relaxedSearch: RelaxedSearch = .control
    var showChatSafetyTips: Bool = false
    var discardedProducts: DiscardedProducts = .control
    var promoteBumpInEdit: PromoteBumpInEdit = .control
    var userIsTyping: UserIsTyping = .control
    var servicesCategoryEnabled: ServicesCategoryEnabled = .control
    var increaseNumberOfPictures: IncreaseNumberOfPictures = .control
    var onboardingIncentivizePosting: OnboardingIncentivizePosting = .control
    var machineLearningMVP: MachineLearningMVP = .control
    var chatNorris: ChatNorris = .control
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings = .control
    var showProTagUserProfile: Bool = false
    var markAllConversationsAsRead: Bool = false
    var realEstateTutorial: RealEstateTutorial = .control
    var summaryAsFirstStep: SummaryAsFirstStep = .control
    var showAdvancedReputationSystem: ShowAdvancedReputationSystem = .control
    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend = .control

    // Country dependant features
    var freePostingModeAllowed = false
    var postingFlowType: PostingFlowType = .standard
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
    var moreInfoDFPAdUnitId = ""
    var feedDFPAdUnitId: String? = ""
    var bumpPriceVariationBucket: BumpPriceVariationBucket = .defaultValue
    var shouldChangeChatNowCopyInTurkey = false
    var copyForChatNowInTurkey: CopyForChatNowInTurkey = .control
    var feedAdsProviderForUS: FeedAdsProviderForUS = .control
    var feedMoPubAdUnitId: String? = ""
    var feedAdsProviderForTR: FeedAdsProviderForTR = .control
    
    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
    var shareTypes: [ShareType] = []
    var copyForChatNowInEnglish: CopyForChatNowInEnglish = .control
    var shouldChangeChatNowCopyInEnglish = false
    
}
