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
    var userReviews: Bool = false
    var captchaTransparent: Bool = false
    var passiveBuyersShowKeyboard: Bool = false
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var productDetailNextRelated: Bool = false
    var carsVerticalEnabled: Bool = false
    var carsCategoryAfterPicture: Bool = false
    var newMarkAsSoldFlow: Bool = false
    var editLocationBubble: EditLocationBubble = .inactive
    var newCarsMultiRequesterEnabled: Bool = false
    var newCarouselNavigationEnabled: Bool = false
    var newOnboardingPhase1: Bool = false
    var searchParamDisc24: SearchParamDisc24 = .disc24a
    var suggestedSearches: SuggestedSearches = .control

    // Country dependant features
    var freePostingModeAllowed = false
    var locationRequiresManualChangeSuggestion = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false

    func commercialsAllowedFor(productCountryCode: String?) -> Bool {
        return false
    }

    func collectionsAllowedFor(countryCode: String?) -> Bool {
        return false
    }
}
