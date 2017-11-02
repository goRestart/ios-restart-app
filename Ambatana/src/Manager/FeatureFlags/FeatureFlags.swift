//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreTelephony
import bumper
import RxSwift

protocol FeatureFlaggeable: class {

    var trackingData: Observable<[String]?> { get }
    var syncedData: Observable<Bool> { get }
    func variablesUpdated()

    var showNPSSurvey: Bool { get }
    var surveyUrl: String { get }
    var surveyEnabled: Bool { get }

    var websocketChat: Bool { get }
    var captchaTransparent: Bool { get }
    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var newCarsMultiRequesterEnabled: Bool { get }
    var inAppRatingIOS10: Bool { get }
    var addSuperKeywordsOnFeed: AddSuperKeywordsOnFeed { get }
    var tweaksCarPostingFlow: TweaksCarPostingFlow { get }
    var userReviewsReportEnabled: Bool { get }
    var dynamicQuickAnswers: DynamicQuickAnswers { get }
    var appRatingDialogInactive: Bool { get }
    var expandableCategorySelectionMenu: ExpandableCategorySelectionMenu { get }
    var defaultRadiusDistanceFeed: DefaultRadiusDistanceFeed { get }
    var locationDataSourceEndpoint: LocationDataSourceEndpoint { get }
    var searchAutocomplete: SearchAutocomplete { get }
    var realEstateEnabled: Bool { get }
    var showPriceAfterSearchOrFilter: ShowPriceAfterSearchOrFilter { get }
    var requestTimeOut: RequestsTimeOut { get }
    var newBumpUpExplanation: NewBumpUpExplanation { get }
    var homeRelatedEnabled: HomeRelatedEnabled { get }
    var hideChatButtonOnFeaturedCells: HideChatButtonOnFeaturedCells { get }
    var featuredRibbonImprovementInDetail: FeaturedRibbonImprovementInDetail { get }
    var taxonomiesAndTaxonomyChildrenInFeed : TaxonomiesAndTaxonomyChildrenInFeed { get }
    var showClockInDirectAnswer : ShowClockInDirectAnswer { get }
    var newItemPage: NewItemPage { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var locationRequiresManualChangeSuggestion: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
    func collectionsAllowedFor(countryCode: String?) -> Bool
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}

extension AddSuperKeywordsOnFeed {
    var isActive: Bool {
        switch self {
        case .control, .baseline:
            return false
        case .active:
            return true
        }
    }
}
extension TweaksCarPostingFlow {
    var isActive: Bool {
        switch self {
        case .control, .baseline:
            return false
        case .active:
            return true
        }
    }
}

extension ExpandableCategorySelectionMenu {
    var isActive: Bool {
        switch self {
        case .control, .baseline:
            return false
        case .expandableMenu:
            return true
        }
    }
}

extension ShowPriceAfterSearchOrFilter {
    var isActive: Bool {
        switch self {
        case .control, .baseline:
            return false
        case .priceOnSearchOrFilter:
            return true
        }
    }
}

extension HomeRelatedEnabled {
    var isActive: Bool { get { return self == .active } }
}

extension TaxonomiesAndTaxonomyChildrenInFeed {
    var isActive: Bool { get { return self == .active } }
}

class FeatureFlags: FeatureFlaggeable {
    static let sharedInstance: FeatureFlags = FeatureFlags()

    let websocketChat: Bool
    let requestTimeOut: RequestsTimeOut

    private let locale: Locale
    private let locationManager: LocationManager
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
        if Bumper.enabled {
            self.websocketChat = Bumper.websocketChat
        } else {
            self.websocketChat = dao.retrieveWebsocketChatEnabled() ?? abTests.websocketChat.value
        }

        if Bumper.enabled {
            self.requestTimeOut = Bumper.requestsTimeOut
        } else {
            self.requestTimeOut = RequestsTimeOut.buildFromTimeout(dao.retrieveTimeoutForRequests())
                ?? RequestsTimeOut.fromPosition(abTests.requestsTimeOut.value)
        }

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

    var trackingData: Observable<[String]?> {
        return abTests.trackingData.asObservable()
    }

    func variablesUpdated() {
        dao.save(websocketChatEnabled: abTests.websocketChat.value)
        if Bumper.enabled {
            dao.save(timeoutForRequests: TimeInterval(Bumper.requestsTimeOut.timeout))
        } else {
            dao.save(timeoutForRequests: TimeInterval(abTests.requestsTimeOut.value))
        }
        abTests.variablesUpdated()
    }

    var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return abTests.showNPSSurvey.value
    }

    var surveyUrl: String {
        if Bumper.enabled {
            return Bumper.surveyEnabled ? Constants.surveyDefaultTestUrl : ""
        }
        return abTests.surveyURL.value
    }

    var surveyEnabled: Bool {
        if Bumper.enabled {
            return Bumper.surveyEnabled
        }
        return abTests.surveyEnabled.value
    }

    var captchaTransparent: Bool {
        if Bumper.enabled {
            return Bumper.captchaTransparent
        }
        return abTests.captchaTransparent.value
    }

    var freeBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.freeBumpUpEnabled
        }
        return abTests.freeBumpUpEnabled.value
    }

    var pricedBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.pricedBumpUpEnabled
        }
        return abTests.pricedBumpUpEnabled.value
    }

    var newCarsMultiRequesterEnabled: Bool {
        if Bumper.enabled {
            return Bumper.newCarsMultiRequesterEnabled
        }
        return abTests.newCarsMultiRequesterEnabled.value
    }

    var inAppRatingIOS10: Bool {
        if Bumper.enabled {
            return Bumper.inAppRatingIOS10
        }
        return abTests.inAppRatingIOS10.value
    }

    var addSuperKeywordsOnFeed: AddSuperKeywordsOnFeed {
        if Bumper.enabled {
            return Bumper.addSuperKeywordsOnFeed
        }
        return AddSuperKeywordsOnFeed.fromPosition(abTests.addSuperKeywordsOnFeed.value)
    }

    var tweaksCarPostingFlow: TweaksCarPostingFlow {
        if Bumper.enabled {
            return Bumper.tweaksCarPostingFlow
        }
        return TweaksCarPostingFlow.fromPosition(abTests.tweaksCarPostingFlow.value)
    }

    var userReviewsReportEnabled: Bool {
        if Bumper.enabled {
            return Bumper.userReviewsReportEnabled
        }
        return abTests.userReviewsReportEnabled.value
    }

    var dynamicQuickAnswers: DynamicQuickAnswers {
        if Bumper.enabled {
            return Bumper.dynamicQuickAnswers
        }
        return DynamicQuickAnswers.fromPosition(abTests.dynamicQuickAnswers.value)
    }

    var appRatingDialogInactive: Bool {
        if Bumper.enabled {
            return Bumper.appRatingDialogInactive
        }
        return abTests.appRatingDialogInactive.value
    }

    var expandableCategorySelectionMenu: ExpandableCategorySelectionMenu {
        if Bumper.enabled {
            return Bumper.expandableCategorySelectionMenu
        }
        return ExpandableCategorySelectionMenu.fromPosition(abTests.expandableCategorySelectionMenu.value)
    }

    var locationDataSourceEndpoint: LocationDataSourceEndpoint {
        if Bumper.enabled {
            return Bumper.locationDataSourceEndpoint
        }
        return LocationDataSourceEndpoint.fromPosition(abTests.locationDataSourceType.value)
    }

    var defaultRadiusDistanceFeed: DefaultRadiusDistanceFeed {
        if Bumper.enabled {
            return Bumper.defaultRadiusDistanceFeed
        }
        return DefaultRadiusDistanceFeed.fromPosition(abTests.defaultRadiusDistanceFeed.value)
    }
    
    var searchAutocomplete: SearchAutocomplete {
        if Bumper.enabled {
            return Bumper.searchAutocomplete
        }
        return SearchAutocomplete.fromPosition(abTests.searchAutocomplete.value)
    }

    var realEstateEnabled: Bool {
        if Bumper.enabled {
            return Bumper.realEstateEnabled
        }
        return abTests.realEstateEnabled.value
    }
    
    var showPriceAfterSearchOrFilter: ShowPriceAfterSearchOrFilter {
        if Bumper.enabled {
            return Bumper.showPriceAfterSearchOrFilter
        }
        return ShowPriceAfterSearchOrFilter.fromPosition(abTests.showPriceAfterSearchOrFilter.value)
    }
    
    var newBumpUpExplanation: NewBumpUpExplanation {
        if Bumper.enabled {
            return Bumper.newBumpUpExplanation
        }
        return NewBumpUpExplanation.fromPosition(abTests.newBumpUpExplanation.value)
    }

    var homeRelatedEnabled: HomeRelatedEnabled {
        if Bumper.enabled {
            return Bumper.homeRelatedEnabled
        }
        return HomeRelatedEnabled.fromPosition(abTests.homeRelatedEnabled.value)
    }

    var hideChatButtonOnFeaturedCells: HideChatButtonOnFeaturedCells {
        if Bumper.enabled {
            return Bumper.hideChatButtonOnFeaturedCells
        }
        return HideChatButtonOnFeaturedCells.fromPosition(abTests.hideChatButtonOnFeaturedCells.value)
    }

    var featuredRibbonImprovementInDetail: FeaturedRibbonImprovementInDetail {
        if Bumper.enabled {
            return Bumper.featuredRibbonImprovementInDetail
        }
        return FeaturedRibbonImprovementInDetail.fromPosition(abTests.featuredRibbonImprovementInDetail.value)
    }

    var newItemPage: NewItemPage {
        if Bumper.enabled {
            return Bumper.newItemPage
        }
        return NewItemPage.fromPosition(abTests.newItemPage.value)
    }
    
    var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed {
        if Bumper.enabled {
            return Bumper.taxonomiesAndTaxonomyChildrenInFeed
        }
        return TaxonomiesAndTaxonomyChildrenInFeed.fromPosition(abTests.taxonomiesAndTaxonomyChildrenInFeed.value)
    }
    
    var showClockInDirectAnswer: ShowClockInDirectAnswer {
        if Bumper.enabled {
            return Bumper.showClockInDirectAnswer
        }
        return ShowClockInDirectAnswer.fromPosition(abTests.showClockInDirectAnswer.value)
    }


    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return false
        default:
            return true
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

    // MARK: - Private

    private var locationCountryCode: CountryCode? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return CountryCode(string: countryCode)
    }

    private var localeCountryCode: CountryCode? {
        return CountryCode(string: locale.lg_countryCode)
    }
}
