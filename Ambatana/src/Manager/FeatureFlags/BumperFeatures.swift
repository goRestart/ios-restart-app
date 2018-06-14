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
        flags.append(RealEstateEnabled.self)
        flags.append(RequestsTimeOut.self)
        flags.append(TaxonomiesAndTaxonomyChildrenInFeed.self)
        flags.append(DeckItemPage.self)
        flags.append(ShowClockInDirectAnswer.self)
        flags.append(MostSearchedDemandedItems.self)
        flags.append(ShowAdsInFeedWithRatio.self)
        flags.append(RealEstateFlowType.self)
        flags.append(RemoveCategoryWhenClosingPosting.self)
        flags.append(RealEstateNewCopy.self)
        flags.append(DummyUsersInfoProfile.self)
        flags.append(ShowInactiveConversations.self)
        flags.append(NoAdsInFeedForNewUsers.self)
        flags.append(SearchImprovements.self)
        flags.append(RelaxedSearch.self)
        flags.append(ShowChatSafetyTips.self)
        flags.append(OnboardingIncentivizePosting.self)
        flags.append(UserIsTyping.self)
        flags.append(BumpUpBoost.self)
        flags.append(CopyForChatNowInTurkey.self)
        flags.append(IncreaseNumberOfPictures.self)
        flags.append(RealEstateTutorial.self)
        flags.append(RealEstatePromoCell.self)
        flags.append(ChatNorris.self)
        flags.append(AddPriceTitleDistanceToListings.self)
        flags.append(MarkAllConversationsAsRead.self)
        flags.append(ShowProTagUserProfile.self)
        flags.append(SummaryAsFirstStep.self)
        flags.append(ShowAdvancedReputationSystem.self)
        flags.append(FeedAdsProviderForUS.self)
        flags.append(CopyForChatNowInEnglish.self)
        flags.append(FeedAdsProviderForTR.self)
        flags.append(SearchCarsIntoNewBackend.self)
        flags.append(SectionedMainFeed.self)
        flags.append(FilterSearchCarSellerType.self)
        flags.append(ShowExactLocationForPros.self)
        flags.append(ShowPasswordlessLogin.self)
        flags.append(CopyForSellFasterNowInEnglish.self)
        flags.append(CreateUpdateCarsIntoNewBackend.self)
        flags.append(EmergencyLocate.self)
        flags.append(RealEstateMap.self)
        flags.append(IAmInterestedFeed.self)
        flags.append(ChatConversationsListWithoutTabs.self)
        flags.append(PersonalizedFeed.self)
        flags.append(ServicesCategoryOnSalchichasMenu.self)
        flags.append(SearchBoxImprovements.self)
        flags.append(GoogleAdxForTR.self)
        flags.append(MultiContactAfterSearch.self)
        flags.append(ShowServicesFeatures.self)
        flags.append(EmptySearchImprovements.self)
        flags.append(OffensiveReportAlert.self)
        flags.append(HighlightedIAmInterestedFeed.self)
        flags.append(FullScreenAdsWhenBrowsingForUS.self)
        flags.append(VideoPosting.self)
        flags.append(PredictivePosting.self)
        flags.append(PreventMessagesFromFeedToProUsers.self)
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

    static var realEstateEnabled: RealEstateEnabled {
        guard let value = Bumper.value(for: RealEstateEnabled.key) else { return .control }
        return RealEstateEnabled(rawValue: value) ?? .control 
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

    static var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers {
        guard let value = Bumper.value(for: NoAdsInFeedForNewUsers.key) else { return .control }
        return NoAdsInFeedForNewUsers(rawValue: value) ?? .control 
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

    static var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        guard let value = Bumper.value(for: OnboardingIncentivizePosting.key) else { return .control }
        return OnboardingIncentivizePosting(rawValue: value) ?? .control 
    }

    static var userIsTyping: UserIsTyping {
        guard let value = Bumper.value(for: UserIsTyping.key) else { return .control }
        return UserIsTyping(rawValue: value) ?? .control 
    }

    static var bumpUpBoost: BumpUpBoost {
        guard let value = Bumper.value(for: BumpUpBoost.key) else { return .control }
        return BumpUpBoost(rawValue: value) ?? .control 
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

    static var realEstatePromoCell: RealEstatePromoCell {
        guard let value = Bumper.value(for: RealEstatePromoCell.key) else { return .control }
        return RealEstatePromoCell(rawValue: value) ?? .control 
    }

    static var chatNorris: ChatNorris {
        guard let value = Bumper.value(for: ChatNorris.key) else { return .control }
        return ChatNorris(rawValue: value) ?? .control 
    }

    static var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings {
        guard let value = Bumper.value(for: AddPriceTitleDistanceToListings.key) else { return .control }
        return AddPriceTitleDistanceToListings(rawValue: value) ?? .control 
    }

    static var markAllConversationsAsRead: MarkAllConversationsAsRead {
        guard let value = Bumper.value(for: MarkAllConversationsAsRead.key) else { return .control }
        return MarkAllConversationsAsRead(rawValue: value) ?? .control 
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

    static var searchCarsIntoNewBackend: SearchCarsIntoNewBackend {
        guard let value = Bumper.value(for: SearchCarsIntoNewBackend.key) else { return .control }
        return SearchCarsIntoNewBackend(rawValue: value) ?? .control 
    }

    static var sectionedMainFeed: SectionedMainFeed {
        guard let value = Bumper.value(for: SectionedMainFeed.key) else { return .control }
        return SectionedMainFeed(rawValue: value) ?? .control 
    }

    static var filterSearchCarSellerType: FilterSearchCarSellerType {
        guard let value = Bumper.value(for: FilterSearchCarSellerType.key) else { return .control }
        return FilterSearchCarSellerType(rawValue: value) ?? .control 
    }

    static var showExactLocationForPros: Bool {
        guard let value = Bumper.value(for: ShowExactLocationForPros.key) else { return true }
        return ShowExactLocationForPros(rawValue: value)?.asBool ?? true
    }

    static var showPasswordlessLogin: ShowPasswordlessLogin {
        guard let value = Bumper.value(for: ShowPasswordlessLogin.key) else { return .control }
        return ShowPasswordlessLogin(rawValue: value) ?? .control 
    }

    static var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish {
        guard let value = Bumper.value(for: CopyForSellFasterNowInEnglish.key) else { return .control }
        return CopyForSellFasterNowInEnglish(rawValue: value) ?? .control 
    }

    static var createUpdateCarsIntoNewBackend: CreateUpdateCarsIntoNewBackend {
        guard let value = Bumper.value(for: CreateUpdateCarsIntoNewBackend.key) else { return .control }
        return CreateUpdateCarsIntoNewBackend(rawValue: value) ?? .control 
    }

    static var emergencyLocate: EmergencyLocate {
        guard let value = Bumper.value(for: EmergencyLocate.key) else { return .control }
        return EmergencyLocate(rawValue: value) ?? .control 
    }

    static var realEstateMap: RealEstateMap {
        guard let value = Bumper.value(for: RealEstateMap.key) else { return .control }
        return RealEstateMap(rawValue: value) ?? .control 
    }

    static var iAmInterestedFeed: IAmInterestedFeed {
        guard let value = Bumper.value(for: IAmInterestedFeed.key) else { return .control }
        return IAmInterestedFeed(rawValue: value) ?? .control 
    }

    static var chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs {
        guard let value = Bumper.value(for: ChatConversationsListWithoutTabs.key) else { return .control }
        return ChatConversationsListWithoutTabs(rawValue: value) ?? .control 
    }

    static var personalizedFeed: PersonalizedFeed {
        guard let value = Bumper.value(for: PersonalizedFeed.key) else { return .control }
        return PersonalizedFeed(rawValue: value) ?? .control 
    }

    static var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu {
        guard let value = Bumper.value(for: ServicesCategoryOnSalchichasMenu.key) else { return .control }
        return ServicesCategoryOnSalchichasMenu(rawValue: value) ?? .control 
    }

    static var searchBoxImprovements: SearchBoxImprovements {
        guard let value = Bumper.value(for: SearchBoxImprovements.key) else { return .control }
        return SearchBoxImprovements(rawValue: value) ?? .control 
    }

    static var googleAdxForTR: GoogleAdxForTR {
        guard let value = Bumper.value(for: GoogleAdxForTR.key) else { return .control }
        return GoogleAdxForTR(rawValue: value) ?? .control 
    }

    static var multiContactAfterSearch: MultiContactAfterSearch {
        guard let value = Bumper.value(for: MultiContactAfterSearch.key) else { return .control }
        return MultiContactAfterSearch(rawValue: value) ?? .control 
    }

    static var showServicesFeatures: ShowServicesFeatures {
        guard let value = Bumper.value(for: ShowServicesFeatures.key) else { return .control }
        return ShowServicesFeatures(rawValue: value) ?? .control 
    }

    static var emptySearchImprovements: EmptySearchImprovements {
        guard let value = Bumper.value(for: EmptySearchImprovements.key) else { return .control }
        return EmptySearchImprovements(rawValue: value) ?? .control 
    }

    static var offensiveReportAlert: OffensiveReportAlert {
        guard let value = Bumper.value(for: OffensiveReportAlert.key) else { return .control }
        return OffensiveReportAlert(rawValue: value) ?? .control 
    }

    static var highlightedIAmInterestedFeed: HighlightedIAmInterestedFeed {
        guard let value = Bumper.value(for: HighlightedIAmInterestedFeed.key) else { return .control }
        return HighlightedIAmInterestedFeed(rawValue: value) ?? .control 
    }

    static var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS {
        guard let value = Bumper.value(for: FullScreenAdsWhenBrowsingForUS.key) else { return .control }
        return FullScreenAdsWhenBrowsingForUS(rawValue: value) ?? .control 
    }

    static var videoPosting: VideoPosting {
        guard let value = Bumper.value(for: VideoPosting.key) else { return .control }
        return VideoPosting(rawValue: value) ?? .control 
    }

    static var predictivePosting: PredictivePosting {
        guard let value = Bumper.value(for: PredictivePosting.key) else { return .control }
        return PredictivePosting(rawValue: value) ?? .control 
    }

    static var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers {
        guard let value = Bumper.value(for: PreventMessagesFromFeedToProUsers.key) else { return .control }
        return PreventMessagesFromFeedToProUsers(rawValue: value) ?? .control 
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

enum BumpUpBoost: String, BumperFeature  {
    case control, baseline, sendTop5Mins, sendTop1hour, boostListing1hour, cheaperBoost5Mins
    static var defaultValue: String { return BumpUpBoost.control.rawValue }
    static var enumValues: [BumpUpBoost] { return [.control, .baseline, .sendTop5Mins, .sendTop1hour, .boostListing1hour, .cheaperBoost5Mins]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Ability to boost ongoing bump ups" } 
    static func fromPosition(_ position: Int) -> BumpUpBoost {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .sendTop5Mins
            case 3: return .sendTop1hour
            case 4: return .boostListing1hour
            case 5: return .cheaperBoost5Mins
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

enum RealEstatePromoCell: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstatePromoCell.control.rawValue }
    static var enumValues: [RealEstatePromoCell] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Real Estate - Show promo cell instead of top banner" } 
    static func fromPosition(_ position: Int) -> RealEstatePromoCell {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ChatNorris: String, BumperFeature  {
    case control, baseline, redButton, whiteButton, greenButton
    static var defaultValue: String { return ChatNorris.control.rawValue }
    static var enumValues: [ChatNorris] { return [.control, .baseline, .redButton, .whiteButton, .greenButton]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show the create meeting option in chat detail view." } 
    static func fromPosition(_ position: Int) -> ChatNorris {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .redButton
            case 3: return .whiteButton
            case 4: return .greenButton
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
    case control, baseline, active
    static var defaultValue: String { return MarkAllConversationsAsRead.control.rawValue }
    static var enumValues: [MarkAllConversationsAsRead] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a button to mark all conversations as read" } 
    static func fromPosition(_ position: Int) -> MarkAllConversationsAsRead {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
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
    case control, baseline, googleAdxForAllUsers, googleAdxForOldUsers, moPubAdsForAllUsers, moPubAdsForOldUsers
    static var defaultValue: String { return FeedAdsProviderForUS.control.rawValue }
    static var enumValues: [FeedAdsProviderForUS] { return [.control, .baseline, .googleAdxForAllUsers, .googleAdxForOldUsers, .moPubAdsForAllUsers, .moPubAdsForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Change logic for showing ads with diferent ads providers in the US" } 
    static func fromPosition(_ position: Int) -> FeedAdsProviderForUS {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .googleAdxForAllUsers
            case 3: return .googleAdxForOldUsers
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

enum SearchCarsIntoNewBackend: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SearchCarsIntoNewBackend.control.rawValue }
    static var enumValues: [SearchCarsIntoNewBackend] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search cars into the new Search Car end point" } 
    static func fromPosition(_ position: Int) -> SearchCarsIntoNewBackend {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SectionedMainFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SectionedMainFeed.control.rawValue }
    static var enumValues: [SectionedMainFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "A new fully sectioned main feed" } 
    static func fromPosition(_ position: Int) -> SectionedMainFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum FilterSearchCarSellerType: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC, variantD
    static var defaultValue: String { return FilterSearchCarSellerType.control.rawValue }
    static var enumValues: [FilterSearchCarSellerType] { return [.control, .baseline, .variantA, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Include Search filter for Car Seller type" } 
    static func fromPosition(_ position: Int) -> FilterSearchCarSellerType {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            case 5: return .variantD
            default: return .control
        }
    }
}

enum ShowExactLocationForPros: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return ShowExactLocationForPros.yes.rawValue }
    static var enumValues: [ShowExactLocationForPros] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show exact location for professional delaers in listing detail map" } 
    var asBool: Bool { return self == .yes }
}

enum ShowPasswordlessLogin: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowPasswordlessLogin.control.rawValue }
    static var enumValues: [ShowPasswordlessLogin] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show Passwordless login option" } 
    static func fromPosition(_ position: Int) -> ShowPasswordlessLogin {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CopyForSellFasterNowInEnglish: String, BumperFeature  {
    case control, baseline, variantB, variantC, variantD
    static var defaultValue: String { return CopyForSellFasterNowInEnglish.control.rawValue }
    static var enumValues: [CopyForSellFasterNowInEnglish] { return [.control, .baseline, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try different copies for 'Sell faster now' banner in English" } 
    static func fromPosition(_ position: Int) -> CopyForSellFasterNowInEnglish {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum CreateUpdateCarsIntoNewBackend: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return CreateUpdateCarsIntoNewBackend.control.rawValue }
    static var enumValues: [CreateUpdateCarsIntoNewBackend] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Create/Update cars into the new endpoint" } 
    static func fromPosition(_ position: Int) -> CreateUpdateCarsIntoNewBackend {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EmergencyLocate: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EmergencyLocate.control.rawValue }
    static var enumValues: [EmergencyLocate] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Activate the Emergency Locate feature" } 
    static func fromPosition(_ position: Int) -> EmergencyLocate {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RealEstateMap: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateMap.control.rawValue }
    static var enumValues: [RealEstateMap] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show Real Estate Map" } 
    static func fromPosition(_ position: Int) -> RealEstateMap {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum IAmInterestedFeed: String, BumperFeature  {
    case control, baseline, hidden
    static var defaultValue: String { return IAmInterestedFeed.control.rawValue }
    static var enumValues: [IAmInterestedFeed] { return [.control, .baseline, .hidden]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show an I am interested button in the main feed" } 
    static func fromPosition(_ position: Int) -> IAmInterestedFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .hidden
            default: return .control
        }
    }
}

enum ChatConversationsListWithoutTabs: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ChatConversationsListWithoutTabs.control.rawValue }
    static var enumValues: [ChatConversationsListWithoutTabs] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Chat conversation list without tabs" } 
    static func fromPosition(_ position: Int) -> ChatConversationsListWithoutTabs {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum PersonalizedFeed: String, BumperFeature  {
    case control, baseline, personalized
    static var defaultValue: String { return PersonalizedFeed.control.rawValue }
    static var enumValues: [PersonalizedFeed] { return [.control, .baseline, .personalized]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Personalize the feed" } 
    static func fromPosition(_ position: Int) -> PersonalizedFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .personalized
            default: return .control
        }
    }
}

enum ServicesCategoryOnSalchichasMenu: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC
    static var defaultValue: String { return ServicesCategoryOnSalchichasMenu.control.rawValue }
    static var enumValues: [ServicesCategoryOnSalchichasMenu] { return [.control, .baseline, .variantA, .variantB, .variantC]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show services category on salchichas menu" } 
    static func fromPosition(_ position: Int) -> ServicesCategoryOnSalchichasMenu {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            default: return .control
        }
    }
}

enum SearchBoxImprovements: String, BumperFeature  {
    case control, baseline, changeCopy, biggerBox, changeCopyAndBoxSize
    static var defaultValue: String { return SearchBoxImprovements.control.rawValue }
    static var enumValues: [SearchBoxImprovements] { return [.control, .baseline, .changeCopy, .biggerBox, .changeCopyAndBoxSize]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Improve search box visibility by changing its size and copy" } 
    static func fromPosition(_ position: Int) -> SearchBoxImprovements {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .changeCopy
            case 3: return .biggerBox
            case 4: return .changeCopyAndBoxSize
            default: return .control
        }
    }
}

enum GoogleAdxForTR: String, BumperFeature  {
    case control, baseline, googleAdxForAllUsers, googleAdxForOldUsers
    static var defaultValue: String { return GoogleAdxForTR.control.rawValue }
    static var enumValues: [GoogleAdxForTR] { return [.control, .baseline, .googleAdxForAllUsers, .googleAdxForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Change logic for showing GoogleAdx in TR" } 
    static func fromPosition(_ position: Int) -> GoogleAdxForTR {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .googleAdxForAllUsers
            case 3: return .googleAdxForOldUsers
            default: return .control
        }
    }
}

enum MultiContactAfterSearch: String, BumperFeature  {
    case control, baseline, photoAndInfo, onlyPhoto
    static var defaultValue: String { return MultiContactAfterSearch.control.rawValue }
    static var enumValues: [MultiContactAfterSearch] { return [.control, .baseline, .photoAndInfo, .onlyPhoto]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "MultiContact After Search" } 
    static func fromPosition(_ position: Int) -> MultiContactAfterSearch {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .photoAndInfo
            case 3: return .onlyPhoto
            default: return .control
        }
    }
}

enum ShowServicesFeatures: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowServicesFeatures.control.rawValue }
    static var enumValues: [ShowServicesFeatures] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show services features (search & filters, posting, editing)" } 
    static func fromPosition(_ position: Int) -> ShowServicesFeatures {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EmptySearchImprovements: String, BumperFeature  {
    case control, baseline, popularNearYou, similarQueries, similarQueriesWhenFewResults, alwaysSimilar
    static var defaultValue: String { return EmptySearchImprovements.control.rawValue }
    static var enumValues: [EmptySearchImprovements] { return [.control, .baseline, .popularNearYou, .similarQueries, .similarQueriesWhenFewResults, .alwaysSimilar]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Improve empty search experience by proposing relavant listings" } 
    static func fromPosition(_ position: Int) -> EmptySearchImprovements {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .popularNearYou
            case 3: return .similarQueries
            case 4: return .similarQueriesWhenFewResults
            case 5: return .alwaysSimilar
            default: return .control
        }
    }
}

enum OffensiveReportAlert: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return OffensiveReportAlert.control.rawValue }
    static var enumValues: [OffensiveReportAlert] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Offensive Report alert active" } 
    static func fromPosition(_ position: Int) -> OffensiveReportAlert {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum HighlightedIAmInterestedFeed: String, BumperFeature  {
    case control, baseline, lightBottom, darkTop, darkBottom
    static var defaultValue: String { return HighlightedIAmInterestedFeed.control.rawValue }
    static var enumValues: [HighlightedIAmInterestedFeed] { return [.control, .baseline, .lightBottom, .darkTop, .darkBottom]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show an I am interested highlighted undo button in the main feed more" } 
    static func fromPosition(_ position: Int) -> HighlightedIAmInterestedFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .lightBottom
            case 3: return .darkTop
            case 4: return .darkBottom
            default: return .control
        }
    }
}

enum FullScreenAdsWhenBrowsingForUS: String, BumperFeature  {
    case control, baseline, adsForAllUsers, adsForOldUsers
    static var defaultValue: String { return FullScreenAdsWhenBrowsingForUS.control.rawValue }
    static var enumValues: [FullScreenAdsWhenBrowsingForUS] { return [.control, .baseline, .adsForAllUsers, .adsForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show full screen Interstitial while browsing through items" } 
    static func fromPosition(_ position: Int) -> FullScreenAdsWhenBrowsingForUS {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .adsForAllUsers
            case 3: return .adsForOldUsers
            default: return .control
        }
    }
}

enum VideoPosting: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return VideoPosting.control.rawValue }
    static var enumValues: [VideoPosting] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show video posting flow when pressing Other Items and Other Vehicles and Parts on salchichas menu" } 
    static func fromPosition(_ position: Int) -> VideoPosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum PredictivePosting: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return PredictivePosting.control.rawValue }
    static var enumValues: [PredictivePosting] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show predictive posting flow when pressing Other Items on salchichas menu" } 
    static func fromPosition(_ position: Int) -> PredictivePosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum PreventMessagesFromFeedToProUsers: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return PreventMessagesFromFeedToProUsers.control.rawValue }
    static var enumValues: [PreventMessagesFromFeedToProUsers] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "If buyer taps 'I'm interested' button in the feed and the listing is from a PRO user, show the phone number request screen" } 
    static func fromPosition(_ position: Int) -> PreventMessagesFromFeedToProUsers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

