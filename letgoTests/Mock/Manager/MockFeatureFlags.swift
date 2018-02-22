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
    var trackingData: Observable<[(String, ABGroupType)]?> {
        return trackingDataVar.asObservable()
    }
    func variablesUpdated() {}
    let trackingDataVar = Variable<[(String, ABGroupType)]?>(nil)

    var showNPSSurvey: Bool = false
    var surveyUrl: String = ""
    var surveyEnabled: Bool = false

    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var newCarsMultiRequesterEnabled: Bool = false
    var inAppRatingIOS10: Bool = false
    var userReviewsReportEnabled: Bool = true
    var dynamicQuickAnswers: DynamicQuickAnswers = .control
    var newItemPage: NewItemPage = .control
    var searchAutocomplete: SearchAutocomplete = .control
    var realEstateEnabled: RealEstateEnabled = .control
    var showPriceAfterSearchOrFilter: ShowPriceAfterSearchOrFilter = .control
    var requestTimeOut: RequestsTimeOut = .thirty
    var homeRelatedEnabled: HomeRelatedEnabled = .control
    var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed = .control
    var showPriceStepRealEstatePosting: ShowPriceStepRealEstatePosting = .control
    var showClockInDirectAnswer: ShowClockInDirectAnswer = .control
    var allowCallsForProfessionals: AllowCallsForProfessionals = .control
    var moreInfoAFShOrDFP: MoreInfoAFShOrDFP = .control
    var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage = .control
    var mostSearchedDemandedItems: MostSearchedDemandedItems = .control
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers = .control

    var realEstateImprovements: RealEstateImprovements = .control
    var realEstatePromos: RealEstatePromos = .control
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio = .control
    var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting = .control
    var realEstateNewCopy: RealEstateNewCopy = .control
    var dummyUsersInfoProfile: DummyUsersInfoProfile = .control
    var showInactiveConversations: Bool = false
    var mainFeedAspectRatio: MainFeedAspectRatio = .control
    var increaseMinPriceBumps: IncreaseMinPriceBumps = .control
    var emojiSizeIncrement: EmojiSizeIncrement = .control
    var showBumpUpBannerOnNotValidatedListings: ShowBumpUpBannerOnNotValidatedListings = .control
    var newUserProfileView: NewUserProfileView = .control
    var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation = .control

    // Country dependant features
    var freePostingModeAllowed = false
    var postingFlowType: PostingFlowType = .standard
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
    var moreInfoShoppingAdUnitId = ""
    var moreInfoDFPAdUnitId = ""
    var feedDFPAdUnitId: String? = ""
    var bumpPriceVariationBucket: Int = 0
    
    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
}
