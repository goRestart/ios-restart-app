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

    var trackingData: Observable<[String]?> {
        return trackingDataVar.asObservable()
    }
    func variablesUpdated() {}
    let trackingDataVar = Variable<[String]?>(nil)

    var showNPSSurvey: Bool = false
    var surveyUrl: String = ""
    var surveyEnabled: Bool = false

    var websocketChat: Bool = false
    var captchaTransparent: Bool = false
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var newCarsMultiRequesterEnabled: Bool = false
    var inAppRatingIOS10: Bool = false
    var addSuperKeywordsOnFeed: AddSuperKeywordsOnFeed = .control
    var tweaksCarPostingFlow: TweaksCarPostingFlow = .control
    var userReviewsReportEnabled: Bool = true
    var dynamicQuickAnswers: DynamicQuickAnswers = .control
    var locationDataSourceEndpoint: LocationDataSourceEndpoint = .control
    var appRatingDialogInactive: Bool = false
    var expandableCategorySelectionMenu: ExpandableCategorySelectionMenu = .control
    var defaultRadiusDistanceFeed: DefaultRadiusDistanceFeed = .control
    var newItemPage: NewItemPage = .control

    var searchAutocomplete: SearchAutocomplete = .control
    var realEstateEnabled: Bool = false
    var showPriceAfterSearchOrFilter: ShowPriceAfterSearchOrFilter = .control
    var requestTimeOut: RequestsTimeOut = .thirty
    var newBumpUpExplanation: NewBumpUpExplanation = .control
    var homeRelatedEnabled: HomeRelatedEnabled = .control
    var hideChatButtonOnFeaturedCells: HideChatButtonOnFeaturedCells = .control
    var featuredRibbonImprovementInDetail: FeaturedRibbonImprovementInDetail = .control
    var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed = .control
    var showClockInDirectAnswer: ShowClockInDirectAnswer = .control

    // Country dependant features
    var freePostingModeAllowed = false
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false


    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
}
