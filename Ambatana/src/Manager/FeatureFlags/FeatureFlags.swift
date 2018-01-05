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

    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var newCarsMultiRequesterEnabled: Bool { get }
    var inAppRatingIOS10: Bool { get }
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
    var taxonomiesAndTaxonomyChildrenInFeed : TaxonomiesAndTaxonomyChildrenInFeed { get }
    var showClockInDirectAnswer : ShowClockInDirectAnswer { get }
    var bumpUpPriceDifferentiation: BumpUpPriceDifferentiation { get }
    var newItemPage: NewItemPage { get }
    var showPriceStepRealEstatePosting: ShowPriceStepRealEstatePosting { get }
    var promoteBumpUpAfterSell: PromoteBumpUpAfterSell { get }
    var copyListingAnotherConfirmation: CopyListingAnotherConfirmation { get }
    var moreInfoAFShOrDFP: MoreInfoAFShOrDFP { get }
    var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage { get }
    var mostSearchedDemandedItems: MostSearchedDemandedItems { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var locationRequiresManualChangeSuggestion: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
    var moreInfoShoppingAdUnitId: String { get }
    var moreInfoDFPAdUnitId: String { get }
    func collectionsAllowedFor(countryCode: String?) -> Bool
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}

extension TweaksCarPostingFlow {
    var isActive: Bool { get { return self == .active } }
}

extension ExpandableCategorySelectionMenu {
    var isActive: Bool { get { return self == .expandableMenu } }
}

extension ShowPriceAfterSearchOrFilter {
    var isActive: Bool { get { return self == .priceOnSearchOrFilter } }
}

extension HomeRelatedEnabled {
    var isActive: Bool { get { return self == .active } }
}

extension TaxonomiesAndTaxonomyChildrenInFeed {
    var isActive: Bool { get { return self == .active } }
}

extension ShowPriceStepRealEstatePosting {
    var isActive: Bool { get { return self == .active } }
}

extension BumpUpPriceDifferentiation {
    var isActive: Bool { get { return self == .active } }
}

extension PromoteBumpUpAfterSell {
    var isActive: Bool { get { return self == .active } }
}

extension CopyListingAnotherConfirmation {
    var isActive: Bool { get { return self == .active } }
}

extension ShowSecurityMeetingChatMessage {
    var isActive: Bool { get { return self == .active } }
}

extension MostSearchedDemandedItems {
    var isActive: Bool {
        get {
            return self == .cameraBadge ||
                self == .trendingButtonExpandableMenu ||
                self == .subsetAboveExpandableMenu ||
                self == .subsetInsideExpandableMenu
        }
    }
}

class FeatureFlags: FeatureFlaggeable {

    static let sharedInstance: FeatureFlags = FeatureFlags()

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
    
    var showPriceStepRealEstatePosting: ShowPriceStepRealEstatePosting {
        if Bumper.enabled {
            return Bumper.showPriceStepRealEstatePosting
        }
        return .control
    }
    
    var showClockInDirectAnswer: ShowClockInDirectAnswer {
        if Bumper.enabled {
            return Bumper.showClockInDirectAnswer
        }
        return ShowClockInDirectAnswer.fromPosition(abTests.showClockInDirectAnswer.value)
    }

    var bumpUpPriceDifferentiation: BumpUpPriceDifferentiation {
        if Bumper.enabled {
            return Bumper.bumpUpPriceDifferentiation
        }
        return BumpUpPriceDifferentiation.fromPosition(abTests.bumpUpPriceDifferentiation.value)
    }

    var promoteBumpUpAfterSell: PromoteBumpUpAfterSell {
        if Bumper.enabled {
            return Bumper.promoteBumpUpAfterSell
        }
        return PromoteBumpUpAfterSell.fromPosition(abTests.promoteBumpUpAfterSell.value)
    }
    
    var copyListingAnotherConfirmation: CopyListingAnotherConfirmation {
        if Bumper.enabled {
            return Bumper.copyListingAnotherConfirmation
        }
        return CopyListingAnotherConfirmation.fromPosition(abTests.copyListingAnotherConfirmation.value)
    }

    var moreInfoAFShOrDFP: MoreInfoAFShOrDFP {
        if Bumper.enabled {
            return Bumper.moreInfoAFShOrDFP
        }
        return MoreInfoAFShOrDFP.fromPosition(abTests.moreInfoAFShOrDFP.value)
    }
    
    var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage {
        if Bumper.enabled {
            return Bumper.showSecurityMeetingChatMessage
        }
        return ShowSecurityMeetingChatMessage.fromPosition(abTests.showSecurityMeetingChatMessage.value)
    }
    
    var mostSearchedDemandedItems: MostSearchedDemandedItems {
        if Bumper.enabled {
            return Bumper.mostSearchedDemandedItems
        }
        return MostSearchedDemandedItems.fromPosition(abTests.mostSearchedDemandedItems.value)
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

    var moreInfoShoppingAdUnitId: String {
        switch sensorLocationCountryCode {
        case .usa?:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdShoppingUSA
        default:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdShopping
        }
    }

    var moreInfoDFPAdUnitId: String {
        switch sensorLocationCountryCode {
        case .usa?:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFPUSA
        default:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFP
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

    private var sensorLocationCountryCode: CountryCode? {
        guard let countryCode = locationManager.currentAutoLocation?.countryCode else { return nil }
        return CountryCode(string: countryCode)
    }
}
