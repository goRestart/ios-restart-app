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
    var passiveBuyersShowKeyboard: Bool = false
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var newMarkAsSoldFlow: Bool = false
    var newCarsMultiRequesterEnabled: Bool = false
    var newOnboardingPhase1: Bool = false
    var searchParamDisc129: SearchParamDisc129 = .disc129a
    var inAppRatingIOS10: Bool = false
    var addSuperKeywordsOnFeed: AddSuperKeywordsOnFeed = .control
    var superKeywordsOnOnboarding: SuperKeywordsOnOnboarding = .control
    var copiesImprovementOnboarding: CopiesImprovementOnboarding = .control
    var bumpUpImprovementBanner: BumpUpImprovementBanner = .control
    var openGalleryInPosting: OpenGalleryInPosting = .control
    var tweaksCarPostingFlow: TweaksCarPostingFlow = .control
    var userReviewsReportEnabled: Bool = true
    var dynamicQuickAnswers: DynamicQuickAnswers = .control
    var locationDataSourceEndpoint: LocationDataSourceEndpoint = .control
    var appRatingDialogInactive: Bool = false
    var feedFilterRadiusValues: FeedFilterRadiusValues = .control
    var expandableCategorySelectionMenu: ExpandableCategorySelectionMenu = .control
    var defaultRadiusDistanceFeed: DefaultRadiusDistanceFeed = .control

    var searchAutocomplete: SearchAutocomplete = .control
    var newCarouselNavigationTapNextPhotoEnabled: NewCarouselTapNextPhotoNavigationEnabled = .control
    var realEstateEnabled: Bool = false
    var requestTimeOut: RequestsTimeOut = .thirty

    // Country dependant features
    var freePostingModeAllowed = false
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false

    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
}
