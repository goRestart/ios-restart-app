//
//  BumperFeatures.swift
//  Letgo
//
//  GENERATED - DO NOT MODIFY - use flags_generator instead.
// 
//  Copyright © 2016 Letgo. All rights reserved.
//

import Foundation
import bumper

extension Bumper  {
    static func initialize() {
        var flags = [BumperFeature.Type]()
        flags.append(ShowNPSSurvey.self)
        flags.append(SurveyEnabled.self)
        flags.append(FreeBumpUpEnabled.self)
        flags.append(PricedBumpUpEnabled.self)
        flags.append(UserReviewsReportEnabled.self)
        flags.append(DynamicQuickAnswers.self)
        flags.append(RealEstateEnabled.self)
        flags.append(SearchAutocomplete.self)
        flags.append(RequestsTimeOut.self)
        flags.append(TaxonomiesAndTaxonomyChildrenInFeed.self)
        flags.append(DeckItemPage.self)
        flags.append(ShowClockInDirectAnswer.self)
        flags.append(MostSearchedDemandedItems.self)
        flags.append(AllowCallsForProfessionals.self)
        flags.append(ShowAdsInFeedWithRatio.self)
        flags.append(RealEstateFlowType.self)
        flags.append(RemoveCategoryWhenClosingPosting.self)
        flags.append(RealEstateNewCopy.self)
        flags.append(DummyUsersInfoProfile.self)
        flags.append(ShowInactiveConversations.self)
        flags.append(IncreaseMinPriceBumps.self)
        flags.append(ShowSecurityMeetingChatMessage.self)
        flags.append(NoAdsInFeedForNewUsers.self)
        flags.append(EmojiSizeIncrement.self)
        flags.append(ShowBumpUpBannerOnNotValidatedListings.self)
        flags.append(NewUserProfileView.self)
        flags.append(TurkeyBumpPriceVATAdaptation.self)
        flags.append(SearchImprovements.self)
        flags.append(RelaxedSearch.self)
        flags.append(ShowChatSafetyTips.self)
        flags.append(DiscardedProducts.self)
        flags.append(OnboardingIncentivizePosting.self)
        flags.append(PromoteBumpInEdit.self)
        flags.append(UserIsTyping.self)
        flags.append(ServicesCategoryEnabled.self)
        flags.append(CopyForChatNowInTurkey.self)
        flags.append(IncreaseNumberOfPictures.self)
        flags.append(RealEstateTutorial.self)
        flags.append(MachineLearningMVP.self)
        flags.append(AddPriceTitleDistanceToListings.self)
        flags.append(MarkAllConversationsAsRead.self)
        flags.append(ShowProTagUserProfile.self)
        flags.append(SummaryAsFirstStep.self)
        flags.append(ShowAdvancedReputationSystem.self)
        flags.append(FeedAdsProviderForUS.self)
        flags.append(CopyForChatNowInEnglish.self)
        flags.append(FeedAdsProviderForTR.self)
        Bumper.initialize(flags)
    } 

    static var showNPSSurvey: Bool {
        guard let value = Bumper.value(for: ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    }

    static var surveyEnabled: Bool {
        guard let value = Bumper.value(for: SurveyEnabled.key) else { return false }
        return SurveyEnabled(rawValue: value)?.asBool ?? false
    }

    static var freeBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: FreeBumpUpEnabled.key) else { return false }
        return FreeBumpUpEnabled(rawValue: value)?.asBool ?? false
    }

    static var pricedBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: PricedBumpUpEnabled.key) else { return false }
        return PricedBumpUpEnabled(rawValue: value)?.asBool ?? false
    }

    static var userReviewsReportEnabled: Bool {
        guard let value = Bumper.value(for: UserReviewsReportEnabled.key) else { return false }
        return UserReviewsReportEnabled(rawValue: value)?.asBool ?? false
    }

    static var dynamicQuickAnswers: DynamicQuickAnswers {
        guard let value = Bumper.value(for: DynamicQuickAnswers.key) else { return .control }
        return DynamicQuickAnswers(rawValue: value) ?? .control 
    }

    static var realEstateEnabled: RealEstateEnabled {
        guard let value = Bumper.value(for: RealEstateEnabled.key) else { return .control }
        return RealEstateEnabled(rawValue: value) ?? .control 
    }

    static var searchAutocomplete: SearchAutocomplete {
        guard let value = Bumper.value(for: SearchAutocomplete.key) else { return .control }
        return SearchAutocomplete(rawValue: value) ?? .control 
    }

    static var requestsTimeOut: RequestsTimeOut {
        guard let value = Bumper.value(for: RequestsTimeOut.key) else { return .baseline }
        return RequestsTimeOut(rawValue: value) ?? .baseline 
    }

    static var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed {
        guard let value = Bumper.value(for: TaxonomiesAndTaxonomyChildrenInFeed.key) else { return .control }
        return TaxonomiesAndTaxonomyChildrenInFeed(rawValue: value) ?? .control 
    }

    static var deckItemPage: DeckItemPage {
        guard let value = Bumper.value(for: DeckItemPage.key) else { return .control }
        return DeckItemPage(rawValue: value) ?? .control 
    }

    static var showClockInDirectAnswer: ShowClockInDirectAnswer {
        guard let value = Bumper.value(for: ShowClockInDirectAnswer.key) else { return .control }
        return ShowClockInDirectAnswer(rawValue: value) ?? .control 
    }

    static var mostSearchedDemandedItems: MostSearchedDemandedItems {
        guard let value = Bumper.value(for: MostSearchedDemandedItems.key) else { return .control }
        return MostSearchedDemandedItems(rawValue: value) ?? .control 
    }

    static var allowCallsForProfessionals: AllowCallsForProfessionals {
        guard let value = Bumper.value(for: AllowCallsForProfessionals.key) else { return .control }
        return AllowCallsForProfessionals(rawValue: value) ?? .control 
    }

    static var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        guard let value = Bumper.value(for: ShowAdsInFeedWithRatio.key) else { return .control }
        return ShowAdsInFeedWithRatio(rawValue: value) ?? .control 
    }

    static var realEstateFlowType: RealEstateFlowType {
        guard let value = Bumper.value(for: RealEstateFlowType.key) else { return .standard }
        return RealEstateFlowType(rawValue: value) ?? .standard 
    }

    static var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting {
        guard let value = Bumper.value(for: RemoveCategoryWhenClosingPosting.key) else { return .control }
        return RemoveCategoryWhenClosingPosting(rawValue: value) ?? .control 
    }

    static var realEstateNewCopy: RealEstateNewCopy {
        guard let value = Bumper.value(for: RealEstateNewCopy.key) else { return .control }
        return RealEstateNewCopy(rawValue: value) ?? .control 
    }

    static var dummyUsersInfoProfile: DummyUsersInfoProfile {
        guard let value = Bumper.value(for: DummyUsersInfoProfile.key) else { return .control }
        return DummyUsersInfoProfile(rawValue: value) ?? .control 
    }

    static var showInactiveConversations: Bool {
        guard let value = Bumper.value(for: ShowInactiveConversations.key) else { return false }
        return ShowInactiveConversations(rawValue: value)?.asBool ?? false
    }

    static var increaseMinPriceBumps: IncreaseMinPriceBumps {
        guard let value = Bumper.value(for: IncreaseMinPriceBumps.key) else { return .control }
        return IncreaseMinPriceBumps(rawValue: value) ?? .control 
    }

    static var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage {
        guard let value = Bumper.value(for: ShowSecurityMeetingChatMessage.key) else { return .control }
        return ShowSecurityMeetingChatMessage(rawValue: value) ?? .control 
    }

    static var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers {
        guard let value = Bumper.value(for: NoAdsInFeedForNewUsers.key) else { return .control }
        return NoAdsInFeedForNewUsers(rawValue: value) ?? .control 
    }

    static var emojiSizeIncrement: EmojiSizeIncrement {
        guard let value = Bumper.value(for: EmojiSizeIncrement.key) else { return .control }
        return EmojiSizeIncrement(rawValue: value) ?? .control 
    }

    static var showBumpUpBannerOnNotValidatedListings: ShowBumpUpBannerOnNotValidatedListings {
        guard let value = Bumper.value(for: ShowBumpUpBannerOnNotValidatedListings.key) else { return .control }
        return ShowBumpUpBannerOnNotValidatedListings(rawValue: value) ?? .control 
    }

    static var newUserProfileView: NewUserProfileView {
        guard let value = Bumper.value(for: NewUserProfileView.key) else { return .control }
        return NewUserProfileView(rawValue: value) ?? .control 
    }

    static var turkeyBumpPriceVATAdaptation: TurkeyBumpPriceVATAdaptation {
        guard let value = Bumper.value(for: TurkeyBumpPriceVATAdaptation.key) else { return .control }
        return TurkeyBumpPriceVATAdaptation(rawValue: value) ?? .control 
    }

    static var searchImprovements: SearchImprovements {
        guard let value = Bumper.value(for: SearchImprovements.key) else { return .control }
        return SearchImprovements(rawValue: value) ?? .control 
    }

    static var relaxedSearch: RelaxedSearch {
        guard let value = Bumper.value(for: RelaxedSearch.key) else { return .control }
        return RelaxedSearch(rawValue: value) ?? .control 
    }

    static var showChatSafetyTips: Bool {
        guard let value = Bumper.value(for: ShowChatSafetyTips.key) else { return false }
        return ShowChatSafetyTips(rawValue: value)?.asBool ?? false
    }

    static var discardedProducts: DiscardedProducts {
        guard let value = Bumper.value(for: DiscardedProducts.key) else { return .control }
        return DiscardedProducts(rawValue: value) ?? .control 
    }

    static var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        guard let value = Bumper.value(for: OnboardingIncentivizePosting.key) else { return .control }
        return OnboardingIncentivizePosting(rawValue: value) ?? .control 
    }

    static var promoteBumpInEdit: PromoteBumpInEdit {
        guard let value = Bumper.value(for: PromoteBumpInEdit.key) else { return .control }
        return PromoteBumpInEdit(rawValue: value) ?? .control 
    }

    static var userIsTyping: UserIsTyping {
        guard let value = Bumper.value(for: UserIsTyping.key) else { return .control }
        return UserIsTyping(rawValue: value) ?? .control 
    }

    static var servicesCategoryEnabled: ServicesCategoryEnabled {
        guard let value = Bumper.value(for: ServicesCategoryEnabled.key) else { return .control }
        return ServicesCategoryEnabled(rawValue: value) ?? .control 
    }

    static var copyForChatNowInTurkey: CopyForChatNowInTurkey {
        guard let value = Bumper.value(for: CopyForChatNowInTurkey.key) else { return .control }
        return CopyForChatNowInTurkey(rawValue: value) ?? .control 
    }

    static var increaseNumberOfPictures: IncreaseNumberOfPictures {
        guard let value = Bumper.value(for: IncreaseNumberOfPictures.key) else { return .control }
        return IncreaseNumberOfPictures(rawValue: value) ?? .control 
    }

    static var realEstateTutorial: RealEstateTutorial {
        guard let value = Bumper.value(for: RealEstateTutorial.key) else { return .control }
        return RealEstateTutorial(rawValue: value) ?? .control 
    }

    static var machineLearningMVP: MachineLearningMVP {
        guard let value = Bumper.value(for: MachineLearningMVP.key) else { return .control }
        return MachineLearningMVP(rawValue: value) ?? .control 
    }

    static var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings {
        guard let value = Bumper.value(for: AddPriceTitleDistanceToListings.key) else { return .control }
        return AddPriceTitleDistanceToListings(rawValue: value) ?? .control 
    }

    static var markAllConversationsAsRead: Bool {
        guard let value = Bumper.value(for: MarkAllConversationsAsRead.key) else { return false }
        return MarkAllConversationsAsRead(rawValue: value)?.asBool ?? false
    }

    static var showProTagUserProfile: Bool {
        guard let value = Bumper.value(for: ShowProTagUserProfile.key) else { return false }
        return ShowProTagUserProfile(rawValue: value)?.asBool ?? false
    }

    static var summaryAsFirstStep: SummaryAsFirstStep {
        guard let value = Bumper.value(for: SummaryAsFirstStep.key) else { return .control }
        return SummaryAsFirstStep(rawValue: value) ?? .control 
    }

    static var showAdvancedReputationSystem: ShowAdvancedReputationSystem {
        guard let value = Bumper.value(for: ShowAdvancedReputationSystem.key) else { return .control }
        return ShowAdvancedReputationSystem(rawValue: value) ?? .control 
    }

    static var feedAdsProviderForUS: FeedAdsProviderForUS {
        guard let value = Bumper.value(for: FeedAdsProviderForUS.key) else { return .control }
        return FeedAdsProviderForUS(rawValue: value) ?? .control 
    }

    static var copyForChatNowInEnglish: CopyForChatNowInEnglish {
        guard let value = Bumper.value(for: CopyForChatNowInEnglish.key) else { return .control }
        return CopyForChatNowInEnglish(rawValue: value) ?? .control 
    }

    static var feedAdsProviderForTR: FeedAdsProviderForTR {
        guard let value = Bumper.value(for: FeedAdsProviderForTR.key) else { return .control }
        return FeedAdsProviderForTR(rawValue: value) ?? .control 
    } 
}


enum ShowNPSSurvey: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowNPSSurvey.no.rawValue }
    static var enumValues: [ShowNPSSurvey] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show nps survey" } 
    var asBool: Bool { return self == .yes }
}

enum SurveyEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return SurveyEnabled.no.rawValue }
    static var enumValues: [SurveyEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show qualitative survey" } 
    var asBool: Bool { return self == .yes }
}

enum FreeBumpUpEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FreeBumpUpEnabled.no.rawValue }
    static var enumValues: [FreeBumpUpEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User can bump sharing" } 
    var asBool: Bool { return self == .yes }
}

enum PricedBumpUpEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PricedBumpUpEnabled.no.rawValue }
    static var enumValues: [PricedBumpUpEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User can bump paying" } 
    var asBool: Bool { return self == .yes }
}

enum UserReviewsReportEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return UserReviewsReportEnabled.no.rawValue }
    static var enumValues: [UserReviewsReportEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User reviews report enabled" } 
    var asBool: Bool { return self == .yes }
}

enum DynamicQuickAnswers: String, BumperFeature  {
    case control, baseline, dynamicNoKeyboard, dynamicWithKeyboard
    static var defaultValue: String { return DynamicQuickAnswers.control.rawValue }
    static var enumValues: [DynamicQuickAnswers] { return [.control, .baseline, .dynamicNoKeyboard, .dynamicWithKeyboard]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Random quick answers with different approaches" } 
    static func fromPosition(_ position: Int) -> DynamicQuickAnswers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .dynamicNoKeyboard
            case 3: return .dynamicWithKeyboard
            default: return .control
        }
    }
}

enum RealEstateEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateEnabled.control.rawValue }
    static var enumValues: [RealEstateEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Allow to see Real Estate category" } 
    static func fromPosition(_ position: Int) -> RealEstateEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SearchAutocomplete: String, BumperFeature  {
    case control, baseline, withCategories
    static var defaultValue: String { return SearchAutocomplete.control.rawValue }
    static var enumValues: [SearchAutocomplete] { return [.control, .baseline, .withCategories]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search suggestions with/without categories filtering." } 
    static func fromPosition(_ position: Int) -> SearchAutocomplete {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .withCategories
            default: return .control
        }
    }
}

enum RequestsTimeOut: String, BumperFeature  {
    case baseline, thirty, forty_five, sixty, hundred_and_twenty
    static var defaultValue: String { return RequestsTimeOut.baseline.rawValue }
    static var enumValues: [RequestsTimeOut] { return [.baseline, .thirty, .forty_five, .sixty, .hundred_and_twenty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "API requests timeout" } 
    static func fromPosition(_ position: Int) -> RequestsTimeOut {
        switch position { 
            case 0: return .baseline
            case 1: return .thirty
            case 2: return .forty_five
            case 3: return .sixty
            case 4: return .hundred_and_twenty
            default: return .baseline
        }
    }
}

enum TaxonomiesAndTaxonomyChildrenInFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return TaxonomiesAndTaxonomyChildrenInFeed.control.rawValue }
    static var enumValues: [TaxonomiesAndTaxonomyChildrenInFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Taxonomies and taxonomy children in feed as filter tags" } 
    static func fromPosition(_ position: Int) -> TaxonomiesAndTaxonomyChildrenInFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum DeckItemPage: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return DeckItemPage.control.rawValue }
    static var enumValues: [DeckItemPage] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Deck item page with card appearance and different navigation" } 
    static func fromPosition(_ position: Int) -> DeckItemPage {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowClockInDirectAnswer: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowClockInDirectAnswer.control.rawValue }
    static var enumValues: [ShowClockInDirectAnswer] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a clock until the message is delivered correctly" } 
    static func fromPosition(_ position: Int) -> ShowClockInDirectAnswer {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MostSearchedDemandedItems: String, BumperFeature  {
    case control, baseline, cameraBadge, trendingButtonExpandableMenu, subsetAboveExpandableMenu
    static var defaultValue: String { return MostSearchedDemandedItems.control.rawValue }
    static var enumValues: [MostSearchedDemandedItems] { return [.control, .baseline, .cameraBadge, .trendingButtonExpandableMenu, .subsetAboveExpandableMenu]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Display a list of top seller items that inspire users to post new items" } 
    static func fromPosition(_ position: Int) -> MostSearchedDemandedItems {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .cameraBadge
            case 3: return .trendingButtonExpandableMenu
            case 4: return .subsetAboveExpandableMenu
            default: return .control
        }
    }
}

enum AllowCallsForProfessionals: String, BumperFeature  {
    case control, baseline, inactive
    static var defaultValue: String { return AllowCallsForProfessionals.control.rawValue }
    static var enumValues: [AllowCallsForProfessionals] { return [.control, .baseline, .inactive]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Users can call professional sellers" } 
    static func fromPosition(_ position: Int) -> AllowCallsForProfessionals {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .inactive
            default: return .control
        }
    }
}

enum ShowAdsInFeedWithRatio: String, BumperFeature  {
    case control, baseline, ten, fifteen, twenty
    static var defaultValue: String { return ShowAdsInFeedWithRatio.control.rawValue }
    static var enumValues: [ShowAdsInFeedWithRatio] { return [.control, .baseline, .ten, .fifteen, .twenty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show ads in feed every X cells" } 
    static func fromPosition(_ position: Int) -> ShowAdsInFeedWithRatio {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .ten
            case 3: return .fifteen
            case 4: return .twenty
            default: return .control
        }
    }
}

enum RealEstateFlowType: String, BumperFeature  {
    case standard, turkish
    static var defaultValue: String { return RealEstateFlowType.standard.rawValue }
    static var enumValues: [RealEstateFlowType] { return [.standard, .turkish]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Real Estate Flow Type" } 
    static func fromPosition(_ position: Int) -> RealEstateFlowType {
        switch position { 
            case 0: return .standard
            case 1: return .turkish
            default: return .standard
        }
    }
}

enum RemoveCategoryWhenClosingPosting: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RemoveCategoryWhenClosingPosting.control.rawValue }
    static var enumValues: [RemoveCategoryWhenClosingPosting] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Remove category real estate if user closes posting" } 
    static func fromPosition(_ position: Int) -> RemoveCategoryWhenClosingPosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RealEstateNewCopy: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateNewCopy.control.rawValue }
    static var enumValues: [RealEstateNewCopy] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try real estate copy instead of housing" } 
    static func fromPosition(_ position: Int) -> RealEstateNewCopy {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum DummyUsersInfoProfile: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return DummyUsersInfoProfile.control.rawValue }
    static var enumValues: [DummyUsersInfoProfile] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Add info for dummy users in profile" } 
    static func fromPosition(_ position: Int) -> DummyUsersInfoProfile {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowInactiveConversations: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowInactiveConversations.no.rawValue }
    static var enumValues: [ShowInactiveConversations] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show button to access inactive conversations" } 
    var asBool: Bool { return self == .yes }
}

enum IncreaseMinPriceBumps: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return IncreaseMinPriceBumps.control.rawValue }
    static var enumValues: [IncreaseMinPriceBumps] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Charge min price of 1.99$ instead of 0.99$ on bumps" } 
    static func fromPosition(_ position: Int) -> IncreaseMinPriceBumps {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowSecurityMeetingChatMessage: String, BumperFeature  {
    case control, baseline, variant1, variant2
    static var defaultValue: String { return ShowSecurityMeetingChatMessage.control.rawValue }
    static var enumValues: [ShowSecurityMeetingChatMessage] { return [.control, .baseline, .variant1, .variant2]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show a disclaimer message on chat after a message from the interlocutor" } 
    static func fromPosition(_ position: Int) -> ShowSecurityMeetingChatMessage {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variant1
            case 3: return .variant2
            default: return .control
        }
    }
}

enum NoAdsInFeedForNewUsers: String, BumperFeature  {
    case control, baseline, adsEverywhere, noAdsForNewUsers, adsForNewUsersOnlyInFeed
    static var defaultValue: String { return NoAdsInFeedForNewUsers.control.rawValue }
    static var enumValues: [NoAdsInFeedForNewUsers] { return [.control, .baseline, .adsEverywhere, .noAdsForNewUsers, .adsForNewUsersOnlyInFeed]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Change logic for showing ads to new users (2 weeks old)" } 
    static func fromPosition(_ position: Int) -> NoAdsInFeedForNewUsers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .adsEverywhere
            case 3: return .noAdsForNewUsers
            case 4: return .adsForNewUsersOnlyInFeed
            default: return .control
        }
    }
}

enum EmojiSizeIncrement: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EmojiSizeIncrement.control.rawValue }
    static var enumValues: [EmojiSizeIncrement] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Increase the size of emojis the text is only emojis and < 4" } 
    static func fromPosition(_ position: Int) -> EmojiSizeIncrement {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowBumpUpBannerOnNotValidatedListings: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowBumpUpBannerOnNotValidatedListings.control.rawValue }
    static var enumValues: [ShowBumpUpBannerOnNotValidatedListings] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show the bump banner for listings pending validation" } 
    static func fromPosition(_ position: Int) -> ShowBumpUpBannerOnNotValidatedListings {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum NewUserProfileView: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NewUserProfileView.control.rawValue }
    static var enumValues: [NewUserProfileView] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Refactor of the User Profile view controller" } 
    static func fromPosition(_ position: Int) -> NewUserProfileView {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum TurkeyBumpPriceVATAdaptation: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return TurkeyBumpPriceVATAdaptation.control.rawValue }
    static var enumValues: [TurkeyBumpPriceVATAdaptation] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Change bump price scaling for listings in TR" } 
    static func fromPosition(_ position: Int) -> TurkeyBumpPriceVATAdaptation {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SearchImprovements: String, BumperFeature  {
    case control, baseline, mWE, mWERelaxedSynonyms, mWERelaxedSynonymsMM100, mWERelaxedSynonymsMM75, mWS, boostingScoreDistance, boostingDistance, boostingFreshness, boostingDistAndFreshness
    static var defaultValue: String { return SearchImprovements.control.rawValue }
    static var enumValues: [SearchImprovements] { return [.control, .baseline, .mWE, .mWERelaxedSynonyms, .mWERelaxedSynonymsMM100, .mWERelaxedSynonymsMM75, .mWS, .boostingScoreDistance, .boostingDistance, .boostingFreshness, .boostingDistAndFreshness]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search improvements related to multi word, boosting distance, score and freshness" } 
    static func fromPosition(_ position: Int) -> SearchImprovements {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .mWE
            case 3: return .mWERelaxedSynonyms
            case 4: return .mWERelaxedSynonymsMM100
            case 5: return .mWERelaxedSynonymsMM75
            case 6: return .mWS
            case 7: return .boostingScoreDistance
            case 8: return .boostingDistance
            case 9: return .boostingFreshness
            case 10: return .boostingDistAndFreshness
            default: return .control
        }
    }
}

enum RelaxedSearch: String, BumperFeature  {
    case control, baseline, relaxedQuery, relaxedQueryORFallback
    static var defaultValue: String { return RelaxedSearch.control.rawValue }
    static var enumValues: [RelaxedSearch] { return [.control, .baseline, .relaxedQuery, .relaxedQueryORFallback]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search improvements with relaxed queries" } 
    static func fromPosition(_ position: Int) -> RelaxedSearch {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .relaxedQuery
            case 3: return .relaxedQueryORFallback
            default: return .control
        }
    }
}

enum ShowChatSafetyTips: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowChatSafetyTips.no.rawValue }
    static var enumValues: [ShowChatSafetyTips] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show chat safety tips to new users" } 
    var asBool: Bool { return self == .yes }
}

enum DiscardedProducts: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return DiscardedProducts.control.rawValue }
    static var enumValues: [DiscardedProducts] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show users listings that have been discarded so they can be edited and reposted" } 
    static func fromPosition(_ position: Int) -> DiscardedProducts {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum OnboardingIncentivizePosting: String, BumperFeature  {
    case control, baseline, blockingPosting, blockingPostingSkipWelcome
    static var defaultValue: String { return OnboardingIncentivizePosting.control.rawValue }
    static var enumValues: [OnboardingIncentivizePosting] { return [.control, .baseline, .blockingPosting, .blockingPostingSkipWelcome]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Leads the user through the posting feature and onboarding improvements" } 
    static func fromPosition(_ position: Int) -> OnboardingIncentivizePosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .blockingPosting
            case 3: return .blockingPostingSkipWelcome
            default: return .control
        }
    }
}

enum PromoteBumpInEdit: String, BumperFeature  {
    case control, baseline, implicit, sellFaster, longRedText, bigIcon
    static var defaultValue: String { return PromoteBumpInEdit.control.rawValue }
    static var enumValues: [PromoteBumpInEdit] { return [.control, .baseline, .implicit, .sellFaster, .longRedText, .bigIcon]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Ad a switch to edit listing page to bump the listing" } 
    static func fromPosition(_ position: Int) -> PromoteBumpInEdit {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .implicit
            case 3: return .sellFaster
            case 4: return .longRedText
            case 5: return .bigIcon
            default: return .control
        }
    }
}

enum UserIsTyping: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return UserIsTyping.control.rawValue }
    static var enumValues: [UserIsTyping] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show user is typing status on chat" } 
    static func fromPosition(_ position: Int) -> UserIsTyping {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ServicesCategoryEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ServicesCategoryEnabled.control.rawValue }
    static var enumValues: [ServicesCategoryEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Allow to see Services category" } 
    static func fromPosition(_ position: Int) -> ServicesCategoryEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CopyForChatNowInTurkey: String, BumperFeature  {
    case control, variantA, variantB, variantC, variantD
    static var defaultValue: String { return CopyForChatNowInTurkey.control.rawValue }
    static var enumValues: [CopyForChatNowInTurkey] { return [.control, .variantA, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try different copies for Chat now button in Turkey" } 
    static func fromPosition(_ position: Int) -> CopyForChatNowInTurkey {
        switch position { 
            case 0: return .control
            case 1: return .variantA
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum IncreaseNumberOfPictures: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return IncreaseNumberOfPictures.control.rawValue }
    static var enumValues: [IncreaseNumberOfPictures] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Allow to include up to 10 pictures on listings" } 
    static func fromPosition(_ position: Int) -> IncreaseNumberOfPictures {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RealEstateTutorial: String, BumperFeature  {
    case control, baseline, oneScreen, twoScreens, threeScreens, onlyBadge
    static var defaultValue: String { return RealEstateTutorial.control.rawValue }
    static var enumValues: [RealEstateTutorial] { return [.control, .baseline, .oneScreen, .twoScreens, .threeScreens, .onlyBadge]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show real estate tutorial when user see Real estate category for first time" } 
    static func fromPosition(_ position: Int) -> RealEstateTutorial {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .oneScreen
            case 3: return .twoScreens
            case 4: return .threeScreens
            case 5: return .onlyBadge
            default: return .control
        }
    }
}

enum MachineLearningMVP: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MachineLearningMVP.control.rawValue }
    static var enumValues: [MachineLearningMVP] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show machine learning posting flow when pressing Other Items on salchichas menu" } 
    static func fromPosition(_ position: Int) -> MachineLearningMVP {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AddPriceTitleDistanceToListings: String, BumperFeature  {
    case control, baseline, infoInImage, infoWithWhiteBackground
    static var defaultValue: String { return AddPriceTitleDistanceToListings.control.rawValue }
    static var enumValues: [AddPriceTitleDistanceToListings] { return [.control, .baseline, .infoInImage, .infoWithWhiteBackground]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Add price, title and distance to listings" } 
    static func fromPosition(_ position: Int) -> AddPriceTitleDistanceToListings {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .infoInImage
            case 3: return .infoWithWhiteBackground
            default: return .control
        }
    }
}

enum MarkAllConversationsAsRead: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return MarkAllConversationsAsRead.no.rawValue }
    static var enumValues: [MarkAllConversationsAsRead] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a button to mark all conversations as read" } 
    var asBool: Bool { return self == .yes }
}

enum ShowProTagUserProfile: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowProTagUserProfile.no.rawValue }
    static var enumValues: [ShowProTagUserProfile] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show Professional tag in user profile" } 
    var asBool: Bool { return self == .yes }
}

enum SummaryAsFirstStep: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SummaryAsFirstStep.control.rawValue }
    static var enumValues: [SummaryAsFirstStep] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show directly summary screen instead of Real estate steps" } 
    static func fromPosition(_ position: Int) -> SummaryAsFirstStep {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowAdvancedReputationSystem: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowAdvancedReputationSystem.control.rawValue }
    static var enumValues: [ShowAdvancedReputationSystem] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show the new advance reputation system and Karma Score" } 
    static func fromPosition(_ position: Int) -> ShowAdvancedReputationSystem {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum FeedAdsProviderForUS: String, BumperFeature  {
    case control, baseline, bingAdsForAllUsers, bingAdsForOldUsers, moPubAdsForAllUsers, moPubAdsForOldUsers
    static var defaultValue: String { return FeedAdsProviderForUS.control.rawValue }
    static var enumValues: [FeedAdsProviderForUS] { return [.control, .baseline, .bingAdsForAllUsers, .bingAdsForOldUsers, .moPubAdsForAllUsers, .moPubAdsForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Change logic for showing ads with diferent ads providers in the US" } 
    static func fromPosition(_ position: Int) -> FeedAdsProviderForUS {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .bingAdsForAllUsers
            case 3: return .bingAdsForOldUsers
            case 4: return .moPubAdsForAllUsers
            case 5: return .moPubAdsForOldUsers
            default: return .control
        }
    }
}

enum CopyForChatNowInEnglish: String, BumperFeature  {
    case control, variantA, variantB, variantC, variantD
    static var defaultValue: String { return CopyForChatNowInEnglish.control.rawValue }
    static var enumValues: [CopyForChatNowInEnglish] { return [.control, .variantA, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try different copies for Chat now button in English" } 
    static func fromPosition(_ position: Int) -> CopyForChatNowInEnglish {
        switch position { 
            case 0: return .control
            case 1: return .variantA
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum FeedAdsProviderForTR: String, BumperFeature  {
    case control, baseline, moPubAdsForAllUsers, moPubAdsForOldUsers
    static var defaultValue: String { return FeedAdsProviderForTR.control.rawValue }
    static var enumValues: [FeedAdsProviderForTR] { return [.control, .baseline, .moPubAdsForAllUsers, .moPubAdsForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Change logic for showing ads with diferent ads providers in TR" } 
    static func fromPosition(_ position: Int) -> FeedAdsProviderForTR {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .moPubAdsForAllUsers
            case 3: return .moPubAdsForOldUsers
            default: return .control
        }
    }
}

