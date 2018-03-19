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

enum PostingFlowType: String {
    case standard
    case turkish
}

enum BumpPriceVariationBucket: Int {
    case defaultValue = 0
    case minPriceIncreaseUSA = 2
    case vatDecreaseTR = 4
}

protocol FeatureFlaggeable: class {

    var trackingData: Observable<[(String, ABGroupType)]?> { get }
    var syncedData: Observable<Bool> { get }
    func variablesUpdated()

    var showNPSSurvey: Bool { get }
    var surveyUrl: String { get }
    var surveyEnabled: Bool { get }

    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var userReviewsReportEnabled: Bool { get }
    var dynamicQuickAnswers: DynamicQuickAnswers { get }
    var searchAutocomplete: SearchAutocomplete { get }
    var realEstateEnabled: RealEstateEnabled { get }
    var requestTimeOut: RequestsTimeOut { get }
    var homeRelatedEnabled: HomeRelatedEnabled { get }
    var taxonomiesAndTaxonomyChildrenInFeed : TaxonomiesAndTaxonomyChildrenInFeed { get }
    var showClockInDirectAnswer : ShowClockInDirectAnswer { get }
    var newItemPage: NewItemPage { get }
    var showPriceStepRealEstatePosting: ShowPriceStepRealEstatePosting { get }
    var allowCallsForProfessionals: AllowCallsForProfessionals { get }
    var mostSearchedDemandedItems: MostSearchedDemandedItems { get }
    var realEstateImprovements: RealEstateImprovements { get }
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio { get }
    var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting { get }
    var realEstateNewCopy: RealEstateNewCopy { get }
    var dummyUsersInfoProfile: DummyUsersInfoProfile { get }
    var showInactiveConversations: Bool { get }
    var increaseMinPriceBumps: IncreaseMinPriceBumps { get }
    var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage { get }
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers { get }
    var emojiSizeIncrement: EmojiSizeIncrement { get }
    var showBumpUpBannerOnNotValidatedListings: ShowBumpUpBannerOnNotValidatedListings { get }
    var newUserProfileView: NewUserProfileView { get }
    var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation { get }
    var searchImprovements: SearchImprovements { get }
    var showChatSafetyTips: Bool { get }
    var onboardingIncentivizePosting: OnboardingIncentivizePosting { get }
    var discardedProducts: DiscardedProducts { get }
    var promoteBumpInEdit: PromoteBumpInEdit { get }
    var userIsTyping: UserIsTyping { get }
    var servicesCategoryEnabled: ServicesCategoryEnabled { get }
    var increaseNumberOfPictures: IncreaseNumberOfPictures { get }
    var machineLearningMVP: MachineLearningMVP { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var postingFlowType: PostingFlowType { get }
    var locationRequiresManualChangeSuggestion: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
    var moreInfoDFPAdUnitId: String { get }
    var feedDFPAdUnitId: String? { get }
    var bumpPriceVariationBucket: BumpPriceVariationBucket { get }
    func collectionsAllowedFor(countryCode: String?) -> Bool
    var shouldChangeChatNowCopy: Bool { get }
    var copyForChatNowInTurkey: CopyForChatNowInTurkey { get }
    
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
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

extension AllowCallsForProfessionals {
    var isActive: Bool { get { return self == .control || self == .baseline } }
}

extension MostSearchedDemandedItems {
    var isActive: Bool {
        get {
            return self == .cameraBadge ||
                self == .trendingButtonExpandableMenu ||
                self == .subsetAboveExpandableMenu
        }
    }
}

extension RealEstateEnabled {
    var isActive: Bool { get { return self == .active } }
}

extension RealEstateImprovements {
    var isActive: Bool { get { return self == .active } }
}

extension ShowAdsInFeedWithRatio {
    var isActive: Bool { get { return self != .control && self != .baseline } }
}

extension NoAdsInFeedForNewUsers {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        get {
            return self == .adsEverywhere || self == .adsForNewUsersOnlyInFeed
        }
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        get {
            return self == .adsEverywhere || self == .adsForNewUsersOnlyInFeed || self == .noAdsForNewUsers
        }
    }
    var shouldShowAdsInFeed: Bool {
        get {
            return shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
        }
    }
    private var shouldShowAdsInMoreInfoForNewUsers: Bool {
        get {
            return self == .control || self == .baseline || self == .adsEverywhere
        }
    }
    private var shouldShowAdsInMoreInfoForOldUsers: Bool {
        get {
            return true
        }
    }
    var shouldShowAdsInMoreInfo: Bool {
        get {
            return shouldShowAdsInMoreInfoForNewUsers || shouldShowAdsInMoreInfoForOldUsers
        }
    }


    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(Constants.newUserTimeThresholdForAds) {
            // New User
            return shouldShowAdsInFeedForNewUsers
        } else {
            // Old user
            return shouldShowAdsInFeedForOldUsers
        }
    }

    func shouldShowAdsInMoreInfoForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInMoreInfoForOldUsers }
        if creationDate.isNewerThan(Constants.newUserTimeThresholdForAds) {
            // New User
            return shouldShowAdsInMoreInfoForNewUsers
        } else {
            // Old user
            return shouldShowAdsInMoreInfoForOldUsers
        }
    }
}

extension RemoveCategoryWhenClosingPosting {
    var isActive: Bool { get { return self == .active } }
}

extension RealEstateNewCopy {
    var isActive: Bool { get { return self == .active } }
}

extension DummyUsersInfoProfile {
    var isActive: Bool { get { return self == .active } }
}

extension ShowBumpUpBannerOnNotValidatedListings {
    var isActive: Bool { get { return self == .active } }
}

extension IncreaseMinPriceBumps {
    var isActive: Bool { get { return self == .active } }
}
extension TurkeyBumpPriceVATAdaptation {
    var isActive: Bool { get { return self == .active } }
}

extension DiscardedProducts {
    var isActive: Bool { get { return self == .active } }
}

extension OnboardingIncentivizePosting {
    var isActive: Bool { get { return self == .blockingPosting } }
}
extension PromoteBumpInEdit {
    var isActive: Bool { get { return self != .control && self != .baseline } }
}

extension UserIsTyping {
    var isActive: Bool { get { return self == .active } }
}
extension ServicesCategoryEnabled {
    var isActive: Bool { get { return self == .active } }
}
extension NewItemPage {
    var isActive: Bool { get { return self == .active } }
}
extension IncreaseNumberOfPictures {
    var isActive: Bool { get { return self == .active } }
}

extension CopyForChatNowInTurkey {
    var variantString: String { get {
        switch self {
        case .control:
            return LGLocalizedString.bumpUpProductCellChatNowButton
        case .variantA:
            return LGLocalizedString.bumpUpProductCellChatNowButtonA
        case .variantB:
            return LGLocalizedString.bumpUpProductCellChatNowButtonB
        case .variantC:
            return LGLocalizedString.bumpUpProductCellChatNowButtonC
        case .variantD:
            return LGLocalizedString.bumpUpProductCellChatNowButtonD
        }
    } }
}

extension MachineLearningMVP {
    var isActive: Bool { get { return self == .active } }
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

    var trackingData: Observable<[(String, ABGroupType)]?> {
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
    
    var searchAutocomplete: SearchAutocomplete {
        if Bumper.enabled {
            return Bumper.searchAutocomplete
        }
        return SearchAutocomplete.fromPosition(abTests.searchAutocomplete.value)
    }

    var realEstateEnabled: RealEstateEnabled
    {
        if Bumper.enabled {
            return Bumper.realEstateEnabled
        }
        return RealEstateEnabled.fromPosition(abTests.realEstateEnabled.value)
    }
    
    var homeRelatedEnabled: HomeRelatedEnabled {
        if Bumper.enabled {
            return Bumper.homeRelatedEnabled
        }
        return HomeRelatedEnabled.fromPosition(abTests.homeRelatedEnabled.value)
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
        return ShowPriceStepRealEstatePosting.fromPosition(abTests.showPriceStepRealEstatePosting.value)
    }
    
    var showClockInDirectAnswer: ShowClockInDirectAnswer {
        if Bumper.enabled {
            return Bumper.showClockInDirectAnswer
        }
        return ShowClockInDirectAnswer.fromPosition(abTests.showClockInDirectAnswer.value)
    }

    var allowCallsForProfessionals: AllowCallsForProfessionals {
        if Bumper.enabled {
            return Bumper.allowCallsForProfessionals
        }
        return AllowCallsForProfessionals.fromPosition(abTests.allowCallsForProfessionals.value)
    }
    
    var mostSearchedDemandedItems: MostSearchedDemandedItems {
        if Bumper.enabled {
            return Bumper.mostSearchedDemandedItems
        }
        return MostSearchedDemandedItems.fromPosition(abTests.mostSearchedDemandedItems.value)
    }
    
    
    var realEstateImprovements: RealEstateImprovements {
        if Bumper.enabled {
            return Bumper.realEstateImprovements
        }
        return RealEstateImprovements.fromPosition(abTests.realEstateImprovements.value)
    }
    
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        if Bumper.enabled {
            return Bumper.showAdsInFeedWithRatio
        }
        return ShowAdsInFeedWithRatio.fromPosition(abTests.showAdsInFeedWithRatio.value)
    }
    
    var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting {
        if Bumper.enabled {
            return Bumper.removeCategoryWhenClosingPosting
        }
        return RemoveCategoryWhenClosingPosting.fromPosition(abTests.removeCategoryWhenClosingPosting.value)
    }
    
    var realEstateNewCopy: RealEstateNewCopy {
        if Bumper.enabled {
            return Bumper.realEstateNewCopy
        }
        return RealEstateNewCopy.fromPosition(abTests.realEstateNewCopy.value)
    }
    
    var dummyUsersInfoProfile: DummyUsersInfoProfile {
        if Bumper.enabled {
            return Bumper.dummyUsersInfoProfile
        }
        return DummyUsersInfoProfile.fromPosition(abTests.dummyUsersInfoProfile.value)
    }
    
    var showInactiveConversations: Bool {
        if Bumper.enabled {
            return Bumper.showInactiveConversations
        }
        return abTests.showInactiveConversations.value
    }

    var increaseMinPriceBumps: IncreaseMinPriceBumps {
        if Bumper.enabled {
            return Bumper.increaseMinPriceBumps
        }
        return IncreaseMinPriceBumps.fromPosition(abTests.increaseMinPriceBumps.value)
    }
    
    var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage {
        if Bumper.enabled {
            return Bumper.showSecurityMeetingChatMessage
        }
        return ShowSecurityMeetingChatMessage.fromPosition(abTests.showSecurityMeetingChatMessage.value)
    }

    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers {
        if Bumper.enabled {
            return Bumper.noAdsInFeedForNewUsers
        }
        return NoAdsInFeedForNewUsers.fromPosition(abTests.noAdsInFeedForNewUsers.value)
    }
    
    var emojiSizeIncrement: EmojiSizeIncrement {
        if Bumper.enabled {
            return Bumper.emojiSizeIncrement
        }
        return EmojiSizeIncrement.fromPosition(abTests.emojiSizeIncrement.value)
    }

    var showBumpUpBannerOnNotValidatedListings: ShowBumpUpBannerOnNotValidatedListings {
        if Bumper.enabled {
            return Bumper.showBumpUpBannerOnNotValidatedListings
        }
        return ShowBumpUpBannerOnNotValidatedListings.fromPosition(abTests.showBumpUpBannerOnNotValidatedListings.value)
    }

    var searchImprovements: SearchImprovements {
        if Bumper.enabled {
            return Bumper.searchImprovements
        }
        return SearchImprovements.fromPosition(abTests.searchImprovements.value)
    }
    
    var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        if Bumper.enabled {
            return Bumper.onboardingIncentivizePosting
        }
        return OnboardingIncentivizePosting.fromPosition(abTests.onboardingIncentivizePosting.value)
    }
    
    var discardedProducts: DiscardedProducts {
        if Bumper.enabled {
            return Bumper.discardedProducts
        }
        return DiscardedProducts.fromPosition(abTests.discardedProducts.value)
    }

    var userIsTyping: UserIsTyping {
        if Bumper.enabled {
            return Bumper.userIsTyping
        }
        return UserIsTyping.fromPosition(abTests.userIsTyping.value)
    }
    
    var machineLearningMVP: MachineLearningMVP {
        if Bumper.enabled {
            return Bumper.machineLearningMVP
        }
        return MachineLearningMVP.fromPosition(abTests.machineLearningMVP.value)
    }

    var newUserProfileView: NewUserProfileView {
        if Bumper.enabled {
            return Bumper.newUserProfileView
        }
        return NewUserProfileView.fromPosition(abTests.newUserProfileView.value)
    }
    
    var showChatSafetyTips: Bool {
        if Bumper.enabled {
            return Bumper.showChatSafetyTips
        }
        return abTests.showChatSafetyTips.value
    }

    var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation {
        if Bumper.enabled {
            return Bumper.turkeyBumpPriceVATAdaptation
        }
        return TurkeyBumpPriceVATAdaptation.fromPosition(abTests.turkeyBumpPriceVATAdaptation.value)
    }

    var servicesCategoryEnabled: ServicesCategoryEnabled {
        if Bumper.enabled {
            return Bumper.servicesCategoryEnabled
        }
        return ServicesCategoryEnabled.fromPosition(abTests.servicesCategoryEnabled.value)
    }

    var promoteBumpInEdit: PromoteBumpInEdit {
        if Bumper.enabled {
            return Bumper.promoteBumpInEdit
        }
        return PromoteBumpInEdit.fromPosition(abTests.promoteBumpInEdit.value)
    }
    
    var increaseNumberOfPictures: IncreaseNumberOfPictures {
        if Bumper.enabled {
            return Bumper.increaseNumberOfPictures
        }
        return IncreaseNumberOfPictures.fromPosition(abTests.increaseNumberOfPictures.value)
    }

    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        switch locationCountryCode {
        case .turkey?:
            return false
        default:
            return true
        }
    }
    
    var postingFlowType: PostingFlowType {
        if Bumper.enabled {
            return Bumper.realEstateFlowType == .standard ? .standard : .turkish
        }
        switch locationCountryCode {
        case .turkey?:
            return .turkish
        default:
            return .standard
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

    var moreInfoDFPAdUnitId: String {
        switch sensorLocationCountryCode {
        case .usa?:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFPUSA
        default:
            return EnvironmentProxy.sharedInstance.moreInfoAdUnitIdDFP
        }
    }

    var feedDFPAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            switch showAdsInFeedWithRatio {
            case .baseline, .control:
                return noAdsInFeedForNewUsers.shouldShowAdsInFeed ? EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio : nil
            case .ten:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA10Ratio
            case .fifteen:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA15Ratio
            case .twenty:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio
            }
        }
        switch sensorLocationCountryCode {
        case .usa?:
            switch showAdsInFeedWithRatio {
            case .baseline, .control:
                return noAdsInFeedForNewUsers.shouldShowAdsInFeed ? EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio : nil
            case .ten:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA10Ratio
            case .fifteen:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA15Ratio
            case .twenty:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdDFPUSA20Ratio
            }
        default:
            return nil
        }
    }

    /**
     This var is used to inform money BE of the ABtests realated to variations in bump prices
     */
    var bumpPriceVariationBucket: BumpPriceVariationBucket {
        if Bumper.enabled {
            if increaseMinPriceBumps.isActive {
                return .minPriceIncreaseUSA
            } else if turkeyBumpPriceVATAdaptation.isActive {
                return .vatDecreaseTR
            } else {
                return .defaultValue
            }
        }
        switch sensorLocationCountryCode {
        case .usa?:
            switch increaseMinPriceBumps {
            case .control, .baseline:
                return .defaultValue
            case .active:
                return .minPriceIncreaseUSA
            }
        case .turkey?:
            switch turkeyBumpPriceVATAdaptation {
            case .control, .baseline:
                return .defaultValue
            case .active:
                return .vatDecreaseTR
            }
        default:
            return .defaultValue
        }
    }
    
    var shouldChangeChatNowCopy: Bool {
        if Bumper.enabled {
            return true
        }
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return true
        default:
            return false
        }
    }
    
    var copyForChatNowInTurkey: CopyForChatNowInTurkey {
        if Bumper.enabled {
            return Bumper.copyForChatNowInTurkey
        }
        return CopyForChatNowInTurkey.fromPosition(abTests.copyForChatNowInTurkey.value)
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
