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

    var trackingData: Observable<[(String, ABGroup)]?> { get }
    var syncedData: Observable<Bool> { get }
    func variablesUpdated()

    var showNPSSurvey: Bool { get }
    var surveyUrl: String { get }
    var surveyEnabled: Bool { get }

    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var userReviewsReportEnabled: Bool { get }
    var searchAutocomplete: SearchAutocomplete { get }
    var realEstateEnabled: RealEstateEnabled { get }
    var requestTimeOut: RequestsTimeOut { get }
    var taxonomiesAndTaxonomyChildrenInFeed : TaxonomiesAndTaxonomyChildrenInFeed { get }
    var showClockInDirectAnswer : ShowClockInDirectAnswer { get }
    var deckItemPage: DeckItemPage { get }
    var allowCallsForProfessionals: AllowCallsForProfessionals { get }
    var mostSearchedDemandedItems: MostSearchedDemandedItems { get }
    var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio { get }
    var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting { get }
    var realEstateNewCopy: RealEstateNewCopy { get }
    var dummyUsersInfoProfile: DummyUsersInfoProfile { get }
    var showInactiveConversations: Bool { get }
    var increaseMinPriceBumps: IncreaseMinPriceBumps { get }
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers { get }
    var showBumpUpBannerOnNotValidatedListings: ShowBumpUpBannerOnNotValidatedListings { get }
    var newUserProfileView: NewUserProfileView { get }
    var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation { get }
    var searchImprovements: SearchImprovements { get }
    var relaxedSearch: RelaxedSearch { get }
    var showChatSafetyTips: Bool { get }
    var onboardingIncentivizePosting: OnboardingIncentivizePosting { get }
    var discardedProducts: DiscardedProducts { get }
    var promoteBumpInEdit: PromoteBumpInEdit { get }
    var userIsTyping: UserIsTyping { get }
    var bumpUpBoost: BumpUpBoost { get }
    var servicesCategoryEnabled: ServicesCategoryEnabled { get }
    var increaseNumberOfPictures: IncreaseNumberOfPictures { get }
    var realEstateTutorial: RealEstateTutorial { get }
    var machineLearningMVP: MachineLearningMVP { get }
    var chatNorris: ChatNorris { get }
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings { get }
    var markAllConversationsAsRead: Bool { get }
    var showProTagUserProfile: Bool { get }
    var summaryAsFirstStep: SummaryAsFirstStep { get }
    var showAdvancedReputationSystem: ShowAdvancedReputationSystem { get }
    var showExactLocationForPros: Bool { get }

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
    var shouldChangeChatNowCopyInTurkey: Bool { get }
    var copyForChatNowInTurkey: CopyForChatNowInTurkey { get }
    var shareTypes: [ShareType] { get }
    var feedAdsProviderForUS:  FeedAdsProviderForUS { get }
    var feedMoPubAdUnitId: String? { get }
    var shouldChangeChatNowCopyInEnglish: Bool { get }
    var copyForChatNowInEnglish: CopyForChatNowInEnglish { get }
    var feedAdsProviderForTR:  FeedAdsProviderForTR { get }
    var shouldShowIAmInterestedInFeed: IAmInterestedFeed { get }

    //  MARK: Verticals
    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend { get }
    var realEstatePromoCell: RealEstatePromoCell { get }
    var filterSearchCarSellerType: FilterSearchCarSellerType { get }

}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}

extension TaxonomiesAndTaxonomyChildrenInFeed {
    var isActive: Bool { return self == .active }
}

extension AllowCallsForProfessionals {
    var isActive: Bool { return self == .control || self == .baseline }
}

extension MostSearchedDemandedItems {
    var isActive: Bool {
        return self == .cameraBadge ||
            self == .trendingButtonExpandableMenu ||
            self == .subsetAboveExpandableMenu
    }
}

extension RealEstateEnabled {
    var isActive: Bool { return self == .active }
}

extension ShowAdsInFeedWithRatio {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension NoAdsInFeedForNewUsers {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .adsEverywhere || self == .adsForNewUsersOnlyInFeed
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .adsEverywhere || self == .adsForNewUsersOnlyInFeed || self == .noAdsForNewUsers
    }
    var shouldShowAdsInFeed: Bool {
        return shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    private var shouldShowAdsInMoreInfoForNewUsers: Bool {
        return self == .control || self == .baseline || self == .adsEverywhere
    }
    private var shouldShowAdsInMoreInfoForOldUsers: Bool {
        return true
    }
    var shouldShowAdsInMoreInfo: Bool {
        return shouldShowAdsInMoreInfoForNewUsers || shouldShowAdsInMoreInfoForOldUsers
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
    var isActive: Bool { return self == .active }
}

extension RealEstateNewCopy {
    var isActive: Bool { return self == .active }
}

extension DummyUsersInfoProfile {
    var isActive: Bool { return self == .active }
}

extension ShowBumpUpBannerOnNotValidatedListings {
    var isActive: Bool { return self == .active }
}

extension IncreaseMinPriceBumps {
    var isActive: Bool { return self == .active }
}
extension TurkeyBumpPriceVATAdaptation {
    var isActive: Bool { return self == .active }
}

extension DiscardedProducts {
    var isActive: Bool { return self == .active }
}

extension OnboardingIncentivizePosting {
    var isActive: Bool { return self == .blockingPosting || self == .blockingPostingSkipWelcome }
}

extension PromoteBumpInEdit {
    var isActive: Bool { return self != .control && self != .baseline }
}

extension UserIsTyping {
    var isActive: Bool { return self == .active }
}

extension ServicesCategoryEnabled {
    var isActive: Bool { return self == .active }
}

extension BumpUpBoost {
    var isActive: Bool { get { return self != .control && self != .baseline } }

    var boostBannerUIUpdateThreshold: TimeInterval? {
        switch self {
        case .control, .baseline:
            return nil
        case .boostListing1hour, .sendTop1hour:
            return Constants.oneHourTimeLimit
        case .sendTop5Mins, .cheaperBoost5Mins:
            return Constants.fiveMinutesTimeLimit
        }
    }
}

extension DeckItemPage {
    var isActive: Bool {get { return self == .active }}
}

extension IncreaseNumberOfPictures {
    var isActive: Bool { return self == .active }
}

extension AddPriceTitleDistanceToListings {
    var hideDetailInFeaturedArea: Bool {
        return self == .infoInImage
    }
    
    var showDetailInNormalCell: Bool {
        return self == .infoWithWhiteBackground
    }
    
    var showDetailInImage: Bool {
        return self == .infoInImage
    }
}

extension CopyForChatNowInTurkey {
    var isActive: Bool { return self != .control }
    
    var variantString: String {
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
    }
}

extension NewUserProfileView {
    var isActive: Bool { get { return self == .active } }
}

extension RealEstateTutorial {
    var isActive: Bool { return self != .baseline && self != .control }
}

extension RealEstatePromoCell {
    var isActive: Bool { return self == .active }
}

extension FilterSearchCarSellerType {
    var isActive: Bool { return self != .baseline && self != .control }
    
    var isMultiselection: Bool {
        return self == .variantA || self == .variantB
    }
}

extension MachineLearningMVP {
    var isActive: Bool { return self == .active }
    var isVideoPostingActive: Bool { return self == .videoPostingActive }
}

extension ChatNorris {
    var isActive: Bool { return self == .redButton || self == .whiteButton || self == .greenButton }
}

extension SummaryAsFirstStep {
    var isActive: Bool { return self == .active }
}

extension ShowAdvancedReputationSystem {
    var isActive: Bool { return self == .active }
}

extension ShowPasswordlessLogin{
    var isActive: Bool { return self == .active }
}

extension FeedAdsProviderForUS {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .moPubAdsForAllUsers
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    var shouldShowAdsInFeed: Bool {
        return  shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    
    var shouldShowMoPubAds : Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(Constants.newUserTimeThresholdForAds) {
            return shouldShowAdsInFeedForNewUsers
        } else {
            return shouldShowAdsInFeedForOldUsers
        }
    }
}

extension FeedAdsProviderForTR {
    private var shouldShowAdsInFeedForNewUsers: Bool {
        return self == .moPubAdsForAllUsers
    }
    private var shouldShowAdsInFeedForOldUsers: Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    var shouldShowAdsInFeed: Bool {
        return  shouldShowAdsInFeedForNewUsers || shouldShowAdsInFeedForOldUsers
    }
    
    var shouldShowMoPubAds : Bool {
        return self == .moPubAdsForOldUsers || self == .moPubAdsForAllUsers
    }
    
    func shouldShowAdsInFeedForUser(createdIn: Date?) -> Bool {
        guard let creationDate = createdIn else { return shouldShowAdsInFeedForOldUsers }
        if creationDate.isNewerThan(Constants.newUserTimeThresholdForAds) {
            return shouldShowAdsInFeedForNewUsers
        } else {
            return shouldShowAdsInFeedForOldUsers
        }
    }
}

extension SearchCarsIntoNewBackend {
    var isActive: Bool { return self == .active }
}

extension CopyForChatNowInEnglish {
    var isActive: Bool { get { return self != .control } }
    
    var variantString: String { get {
        switch self {
        case .control:
            return LGLocalizedString.bumpUpProductCellChatNowButton
        case .variantA:
            return LGLocalizedString.bumpUpProductCellChatNowButtonEnglishA
        case .variantB:
            return LGLocalizedString.bumpUpProductCellChatNowButtonEnglishB
        case .variantC:
            return LGLocalizedString.bumpUpProductCellChatNowButtonEnglishC
        case .variantD:
            return LGLocalizedString.bumpUpProductCellChatNowButtonEnglishD
        }
        } }
}

extension IAmInterestedFeed {
    var isVisible: Bool { return self == .control || self == .baseline }
}

final class FeatureFlags: FeatureFlaggeable {

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

    var trackingData: Observable<[(String, ABGroup)]?> {
        return abTests.trackingData.asObservable()
    }

    func variablesUpdated() {
        if Bumper.enabled {
            dao.save(timeoutForRequests: TimeInterval(Bumper.requestsTimeOut.timeout))
        } else {
            dao.save(timeoutForRequests: TimeInterval(abTests.requestsTimeOut.value))
            dao.save(newUserProfile: NewUserProfileView.fromPosition(abTests.newUserProfileView.value))
            dao.save(showAdvanceReputationSystem: ShowAdvancedReputationSystem.fromPosition(abTests.advancedReputationSystem.value))
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
    
    var searchAutocomplete: SearchAutocomplete {
        if Bumper.enabled {
            return Bumper.searchAutocomplete
        }
        return SearchAutocomplete.fromPosition(abTests.searchAutocomplete.value)
    }

    var realEstateEnabled: RealEstateEnabled {
        if Bumper.enabled {
            return Bumper.realEstateEnabled
        }
        return RealEstateEnabled.fromPosition(abTests.realEstateEnabled.value)
    }

    var deckItemPage: DeckItemPage {
        if Bumper.enabled {
            return Bumper.deckItemPage
        }
        return DeckItemPage.fromPosition(abTests.deckItemPage.value)
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
    
    var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers {
        if Bumper.enabled {
            return Bumper.noAdsInFeedForNewUsers
        }
        return NoAdsInFeedForNewUsers.fromPosition(abTests.noAdsInFeedForNewUsers.value)
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
    
    var relaxedSearch: RelaxedSearch {
        if Bumper.enabled {
            return Bumper.relaxedSearch
        }
        return RelaxedSearch.fromPosition(abTests.relaxedSearch.value)
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
    
    var realEstateTutorial: RealEstateTutorial {
        if Bumper.enabled {
            return Bumper.realEstateTutorial
        }
        return RealEstateTutorial.fromPosition(abTests.realEstateTutorial.value)
    }
    
    var realEstatePromoCell: RealEstatePromoCell {
        if Bumper.enabled {
            return Bumper.realEstatePromoCell
        }
        return RealEstatePromoCell.fromPosition(abTests.realEstatePromoCell.value)
    }
    
    var filterSearchCarSellerType: FilterSearchCarSellerType {
        if Bumper.enabled {
            return Bumper.filterSearchCarSellerType
        }
        return FilterSearchCarSellerType.fromPosition(abTests.filterSearchCarSellerType.value)
    }
    
    var machineLearningMVP: MachineLearningMVP {
        if Bumper.enabled {
            return Bumper.machineLearningMVP
        }
        return MachineLearningMVP.fromPosition(abTests.machineLearningMVP.value)
    }
    
    var markAllConversationsAsRead: Bool {
        if Bumper.enabled {
            return Bumper.markAllConversationsAsRead
        }
        return abTests.markAllConversationsAsRead.value
    }
    
    var newUserProfileView: NewUserProfileView {
        if Bumper.enabled {
            return Bumper.newUserProfileView
        } else {
            return dao.retrieveNewUserProfile() ?? NewUserProfileView.fromPosition(abTests.newUserProfileView.value)
        }
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
    
    var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings {
        if Bumper.enabled {
            return Bumper.addPriceTitleDistanceToListings
        }
        return AddPriceTitleDistanceToListings.fromPosition(abTests.addPriceTitleDistanceToListings.value)
    }

    var bumpUpBoost: BumpUpBoost {
        if Bumper.enabled {
            return Bumper.bumpUpBoost
        }
        return BumpUpBoost.fromPosition(abTests.bumpUpBoost.value)
    }

    var showProTagUserProfile: Bool {
        if Bumper.enabled {
            return Bumper.showProTagUserProfile
        }
        return abTests.showProTagUserProfile.value
    }

    var summaryAsFirstStep: SummaryAsFirstStep {
        if Bumper.enabled {
            return Bumper.summaryAsFirstStep
        }
        return SummaryAsFirstStep.fromPosition(abTests.summaryAsFirstStep.value)
    }

    var showAdvancedReputationSystem: ShowAdvancedReputationSystem {
        if Bumper.enabled {
            return Bumper.showAdvancedReputationSystem
        }
        let cached = dao.retrieveShowAdvanceReputationSystem()
        return cached ?? ShowAdvancedReputationSystem.fromPosition(abTests.advancedReputationSystem.value)
    }

    var searchCarsIntoNewBackend: SearchCarsIntoNewBackend {
        if Bumper.enabled {
            return Bumper.searchCarsIntoNewBackend
        }
        return SearchCarsIntoNewBackend.fromPosition(abTests.searchCarsIntoNewBackend.value)
    }

    var showExactLocationForPros: Bool {
        if Bumper.enabled {
            return Bumper.showExactLocationForPros
        }
        return abTests.showExactLocationForPros.value
    }

    var showPasswordlessLogin: ShowPasswordlessLogin {
        if Bumper.enabled {
            return Bumper.showPasswordlessLogin
        }
        return ShowPasswordlessLogin.fromPosition(abTests.showPasswordlessLogin.value)
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
    
    var shareTypes: [ShareType] {
       switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return [.whatsapp, .facebook, .email ,.fbMessenger, .twitter, .sms, .telegram]
        default:
            return [.sms, .email, .facebook, .fbMessenger, .twitter, .whatsapp, .telegram]
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

    var shouldChangeChatNowCopyInTurkey: Bool {
        if Bumper.enabled {
            return Bumper.copyForChatNowInTurkey.isActive
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
    
    var feedAdsProviderForUS: FeedAdsProviderForUS {
        if Bumper.enabled {
            return Bumper.feedAdsProviderForUS
        }
        return FeedAdsProviderForUS.fromPosition(abTests.feedAdsProviderForUS.value)
    }
    
    var feedMoPubAdUnitId: String? {
        if Bumper.enabled {
            // Bumper overrides country restriction
            switch feedAdsProviderForUS {
            case .moPubAdsForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForAllUsers
            case .moPubAdsForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForOldUsers
            default:
                switch feedAdsProviderForTR {
                case .moPubAdsForAllUsers:
                    return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForAllUsers
                case .moPubAdsForOldUsers:
                    return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForOldUsers
                default:
                    return nil
                }
            }
        }
        switch sensorLocationCountryCode {
        case .usa?:
            switch feedAdsProviderForUS {
            case .moPubAdsForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForAllUsers
            case .moPubAdsForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubUSAForOldUsers
            default:
                return nil
            }
        case .turkey?:
            switch feedAdsProviderForTR {
            case .moPubAdsForAllUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForAllUsers
            case .moPubAdsForOldUsers:
                return EnvironmentProxy.sharedInstance.feedAdUnitIdMoPubTRForOldUsers
            default:
                return nil
            }
            
        default:
            return nil
        }
    }

    var shouldChangeChatNowCopyInEnglish: Bool {
        if Bumper.enabled {
            return Bumper.copyForChatNowInEnglish.isActive
        }
        switch (localeCountryCode) {
        case .usa?:
            return true
        default:
            return false
        }
    }
    
    var copyForChatNowInEnglish: CopyForChatNowInEnglish {
        if Bumper.enabled {
            return Bumper.copyForChatNowInEnglish
        }
        return CopyForChatNowInEnglish.fromPosition(abTests.copyForChatNowInEnglish.value)
    }

    var shouldShowIAmInterestedInFeed: IAmInterestedFeed {
        if Bumper.enabled {
            return Bumper.iAmInterestedFeed
        }
        return IAmInterestedFeed.fromPosition(abTests.iAmInterestedInFeed.value)
    }
    
    var feedAdsProviderForTR: FeedAdsProviderForTR {
        if Bumper.enabled {
            return Bumper.feedAdsProviderForTR
        }
        return FeedAdsProviderForTR.fromPosition(abTests.feedAdsProviderForTR.value)
    }

    var chatNorris: ChatNorris {
        if Bumper.enabled {
            return Bumper.chatNorris
        }
        return  ChatNorris.fromPosition(abTests.chatNorris.value)
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
