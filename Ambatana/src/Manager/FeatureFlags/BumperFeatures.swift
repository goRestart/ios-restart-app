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
#if (RX_BUMPER)
import RxSwift
#endif

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
        flags.append(ChatNorris.self)
        flags.append(AddPriceTitleDistanceToListings.self)
        flags.append(MarkAllConversationsAsRead.self)
        flags.append(ShowProTagUserProfile.self)
        flags.append(FeedAdsProviderForUS.self)
        flags.append(CopyForChatNowInEnglish.self)
        flags.append(FeedAdsProviderForTR.self)
        flags.append(SearchCarsIntoNewBackend.self)
        flags.append(SectionedMainFeed.self)
        flags.append(FilterSearchCarSellerType.self)
        flags.append(ShowExactLocationForPros.self)
        flags.append(ShowPasswordlessLogin.self)
        flags.append(CopyForSellFasterNowInEnglish.self)
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
        flags.append(SimplifiedChatButton.self)
        flags.append(ShowChatConnectionStatusBar.self)
        flags.append(AdvancedReputationSystem.self)
        flags.append(NotificationSettings.self)
        flags.append(EmptyStateErrorResearchActive.self)
        Bumper.initialize(flags)
    } 

    static var showNPSSurvey: Bool {
        guard let value = Bumper.value(for: ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showNPSSurveyObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowNPSSurvey.key).map {
            ShowNPSSurvey(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var surveyEnabled: Bool {
        guard let value = Bumper.value(for: SurveyEnabled.key) else { return false }
        return SurveyEnabled(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var surveyEnabledObservable: Observable<Bool> {
        return Bumper.observeValue(for: SurveyEnabled.key).map {
            SurveyEnabled(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var freeBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: FreeBumpUpEnabled.key) else { return false }
        return FreeBumpUpEnabled(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var freeBumpUpEnabledObservable: Observable<Bool> {
        return Bumper.observeValue(for: FreeBumpUpEnabled.key).map {
            FreeBumpUpEnabled(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var pricedBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: PricedBumpUpEnabled.key) else { return false }
        return PricedBumpUpEnabled(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var pricedBumpUpEnabledObservable: Observable<Bool> {
        return Bumper.observeValue(for: PricedBumpUpEnabled.key).map {
            PricedBumpUpEnabled(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var userReviewsReportEnabled: Bool {
        guard let value = Bumper.value(for: UserReviewsReportEnabled.key) else { return false }
        return UserReviewsReportEnabled(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var userReviewsReportEnabledObservable: Observable<Bool> {
        return Bumper.observeValue(for: UserReviewsReportEnabled.key).map {
            UserReviewsReportEnabled(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var realEstateEnabled: RealEstateEnabled {
        guard let value = Bumper.value(for: RealEstateEnabled.key) else { return .control }
        return RealEstateEnabled(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstateEnabledObservable: Observable<RealEstateEnabled> {
        return Bumper.observeValue(for: RealEstateEnabled.key).map {
            RealEstateEnabled(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var requestsTimeOut: RequestsTimeOut {
        guard let value = Bumper.value(for: RequestsTimeOut.key) else { return .baseline }
        return RequestsTimeOut(rawValue: value) ?? .baseline 
    } 

    #if (RX_BUMPER)
    static var requestsTimeOutObservable: Observable<RequestsTimeOut> {
        return Bumper.observeValue(for: RequestsTimeOut.key).map {
            RequestsTimeOut(rawValue: $0 ?? "") ?? .baseline
        }
    }
    #endif

    static var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed {
        guard let value = Bumper.value(for: TaxonomiesAndTaxonomyChildrenInFeed.key) else { return .control }
        return TaxonomiesAndTaxonomyChildrenInFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var taxonomiesAndTaxonomyChildrenInFeedObservable: Observable<TaxonomiesAndTaxonomyChildrenInFeed> {
        return Bumper.observeValue(for: TaxonomiesAndTaxonomyChildrenInFeed.key).map {
            TaxonomiesAndTaxonomyChildrenInFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var deckItemPage: DeckItemPage {
        guard let value = Bumper.value(for: DeckItemPage.key) else { return .control }
        return DeckItemPage(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var deckItemPageObservable: Observable<DeckItemPage> {
        return Bumper.observeValue(for: DeckItemPage.key).map {
            DeckItemPage(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showClockInDirectAnswer: ShowClockInDirectAnswer {
        guard let value = Bumper.value(for: ShowClockInDirectAnswer.key) else { return .control }
        return ShowClockInDirectAnswer(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showClockInDirectAnswerObservable: Observable<ShowClockInDirectAnswer> {
        return Bumper.observeValue(for: ShowClockInDirectAnswer.key).map {
            ShowClockInDirectAnswer(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var mostSearchedDemandedItems: MostSearchedDemandedItems {
        guard let value = Bumper.value(for: MostSearchedDemandedItems.key) else { return .control }
        return MostSearchedDemandedItems(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var mostSearchedDemandedItemsObservable: Observable<MostSearchedDemandedItems> {
        return Bumper.observeValue(for: MostSearchedDemandedItems.key).map {
            MostSearchedDemandedItems(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        guard let value = Bumper.value(for: ShowAdsInFeedWithRatio.key) else { return .control }
        return ShowAdsInFeedWithRatio(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showAdsInFeedWithRatioObservable: Observable<ShowAdsInFeedWithRatio> {
        return Bumper.observeValue(for: ShowAdsInFeedWithRatio.key).map {
            ShowAdsInFeedWithRatio(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var realEstateFlowType: RealEstateFlowType {
        guard let value = Bumper.value(for: RealEstateFlowType.key) else { return .standard }
        return RealEstateFlowType(rawValue: value) ?? .standard 
    } 

    #if (RX_BUMPER)
    static var realEstateFlowTypeObservable: Observable<RealEstateFlowType> {
        return Bumper.observeValue(for: RealEstateFlowType.key).map {
            RealEstateFlowType(rawValue: $0 ?? "") ?? .standard
        }
    }
    #endif

    static var realEstateNewCopy: RealEstateNewCopy {
        guard let value = Bumper.value(for: RealEstateNewCopy.key) else { return .control }
        return RealEstateNewCopy(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstateNewCopyObservable: Observable<RealEstateNewCopy> {
        return Bumper.observeValue(for: RealEstateNewCopy.key).map {
            RealEstateNewCopy(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var dummyUsersInfoProfile: DummyUsersInfoProfile {
        guard let value = Bumper.value(for: DummyUsersInfoProfile.key) else { return .control }
        return DummyUsersInfoProfile(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var dummyUsersInfoProfileObservable: Observable<DummyUsersInfoProfile> {
        return Bumper.observeValue(for: DummyUsersInfoProfile.key).map {
            DummyUsersInfoProfile(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showInactiveConversations: Bool {
        guard let value = Bumper.value(for: ShowInactiveConversations.key) else { return false }
        return ShowInactiveConversations(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showInactiveConversationsObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowInactiveConversations.key).map {
            ShowInactiveConversations(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var noAdsInFeedForNewUsers: NoAdsInFeedForNewUsers {
        guard let value = Bumper.value(for: NoAdsInFeedForNewUsers.key) else { return .control }
        return NoAdsInFeedForNewUsers(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var noAdsInFeedForNewUsersObservable: Observable<NoAdsInFeedForNewUsers> {
        return Bumper.observeValue(for: NoAdsInFeedForNewUsers.key).map {
            NoAdsInFeedForNewUsers(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchImprovements: SearchImprovements {
        guard let value = Bumper.value(for: SearchImprovements.key) else { return .control }
        return SearchImprovements(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchImprovementsObservable: Observable<SearchImprovements> {
        return Bumper.observeValue(for: SearchImprovements.key).map {
            SearchImprovements(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var relaxedSearch: RelaxedSearch {
        guard let value = Bumper.value(for: RelaxedSearch.key) else { return .control }
        return RelaxedSearch(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var relaxedSearchObservable: Observable<RelaxedSearch> {
        return Bumper.observeValue(for: RelaxedSearch.key).map {
            RelaxedSearch(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showChatSafetyTips: Bool {
        guard let value = Bumper.value(for: ShowChatSafetyTips.key) else { return false }
        return ShowChatSafetyTips(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showChatSafetyTipsObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowChatSafetyTips.key).map {
            ShowChatSafetyTips(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        guard let value = Bumper.value(for: OnboardingIncentivizePosting.key) else { return .control }
        return OnboardingIncentivizePosting(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var onboardingIncentivizePostingObservable: Observable<OnboardingIncentivizePosting> {
        return Bumper.observeValue(for: OnboardingIncentivizePosting.key).map {
            OnboardingIncentivizePosting(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var userIsTyping: UserIsTyping {
        guard let value = Bumper.value(for: UserIsTyping.key) else { return .control }
        return UserIsTyping(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var userIsTypingObservable: Observable<UserIsTyping> {
        return Bumper.observeValue(for: UserIsTyping.key).map {
            UserIsTyping(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var bumpUpBoost: BumpUpBoost {
        guard let value = Bumper.value(for: BumpUpBoost.key) else { return .control }
        return BumpUpBoost(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var bumpUpBoostObservable: Observable<BumpUpBoost> {
        return Bumper.observeValue(for: BumpUpBoost.key).map {
            BumpUpBoost(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForChatNowInTurkey: CopyForChatNowInTurkey {
        guard let value = Bumper.value(for: CopyForChatNowInTurkey.key) else { return .control }
        return CopyForChatNowInTurkey(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForChatNowInTurkeyObservable: Observable<CopyForChatNowInTurkey> {
        return Bumper.observeValue(for: CopyForChatNowInTurkey.key).map {
            CopyForChatNowInTurkey(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var chatNorris: ChatNorris {
        guard let value = Bumper.value(for: ChatNorris.key) else { return .control }
        return ChatNorris(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var chatNorrisObservable: Observable<ChatNorris> {
        return Bumper.observeValue(for: ChatNorris.key).map {
            ChatNorris(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var addPriceTitleDistanceToListings: AddPriceTitleDistanceToListings {
        guard let value = Bumper.value(for: AddPriceTitleDistanceToListings.key) else { return .control }
        return AddPriceTitleDistanceToListings(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var addPriceTitleDistanceToListingsObservable: Observable<AddPriceTitleDistanceToListings> {
        return Bumper.observeValue(for: AddPriceTitleDistanceToListings.key).map {
            AddPriceTitleDistanceToListings(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var markAllConversationsAsRead: MarkAllConversationsAsRead {
        guard let value = Bumper.value(for: MarkAllConversationsAsRead.key) else { return .control }
        return MarkAllConversationsAsRead(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var markAllConversationsAsReadObservable: Observable<MarkAllConversationsAsRead> {
        return Bumper.observeValue(for: MarkAllConversationsAsRead.key).map {
            MarkAllConversationsAsRead(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showProTagUserProfile: Bool {
        guard let value = Bumper.value(for: ShowProTagUserProfile.key) else { return false }
        return ShowProTagUserProfile(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showProTagUserProfileObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowProTagUserProfile.key).map {
            ShowProTagUserProfile(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var feedAdsProviderForUS: FeedAdsProviderForUS {
        guard let value = Bumper.value(for: FeedAdsProviderForUS.key) else { return .control }
        return FeedAdsProviderForUS(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var feedAdsProviderForUSObservable: Observable<FeedAdsProviderForUS> {
        return Bumper.observeValue(for: FeedAdsProviderForUS.key).map {
            FeedAdsProviderForUS(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForChatNowInEnglish: CopyForChatNowInEnglish {
        guard let value = Bumper.value(for: CopyForChatNowInEnglish.key) else { return .control }
        return CopyForChatNowInEnglish(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForChatNowInEnglishObservable: Observable<CopyForChatNowInEnglish> {
        return Bumper.observeValue(for: CopyForChatNowInEnglish.key).map {
            CopyForChatNowInEnglish(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var feedAdsProviderForTR: FeedAdsProviderForTR {
        guard let value = Bumper.value(for: FeedAdsProviderForTR.key) else { return .control }
        return FeedAdsProviderForTR(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var feedAdsProviderForTRObservable: Observable<FeedAdsProviderForTR> {
        return Bumper.observeValue(for: FeedAdsProviderForTR.key).map {
            FeedAdsProviderForTR(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchCarsIntoNewBackend: SearchCarsIntoNewBackend {
        guard let value = Bumper.value(for: SearchCarsIntoNewBackend.key) else { return .control }
        return SearchCarsIntoNewBackend(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchCarsIntoNewBackendObservable: Observable<SearchCarsIntoNewBackend> {
        return Bumper.observeValue(for: SearchCarsIntoNewBackend.key).map {
            SearchCarsIntoNewBackend(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var sectionedMainFeed: SectionedMainFeed {
        guard let value = Bumper.value(for: SectionedMainFeed.key) else { return .control }
        return SectionedMainFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var sectionedMainFeedObservable: Observable<SectionedMainFeed> {
        return Bumper.observeValue(for: SectionedMainFeed.key).map {
            SectionedMainFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var filterSearchCarSellerType: FilterSearchCarSellerType {
        guard let value = Bumper.value(for: FilterSearchCarSellerType.key) else { return .control }
        return FilterSearchCarSellerType(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var filterSearchCarSellerTypeObservable: Observable<FilterSearchCarSellerType> {
        return Bumper.observeValue(for: FilterSearchCarSellerType.key).map {
            FilterSearchCarSellerType(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showExactLocationForPros: Bool {
        guard let value = Bumper.value(for: ShowExactLocationForPros.key) else { return true }
        return ShowExactLocationForPros(rawValue: value)?.asBool ?? true
    } 

    #if (RX_BUMPER)
    static var showExactLocationForProsObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowExactLocationForPros.key).map {
            ShowExactLocationForPros(rawValue: $0 ?? "")?.asBool ?? true
        }
    }
    #endif

    static var showPasswordlessLogin: ShowPasswordlessLogin {
        guard let value = Bumper.value(for: ShowPasswordlessLogin.key) else { return .control }
        return ShowPasswordlessLogin(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showPasswordlessLoginObservable: Observable<ShowPasswordlessLogin> {
        return Bumper.observeValue(for: ShowPasswordlessLogin.key).map {
            ShowPasswordlessLogin(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish {
        guard let value = Bumper.value(for: CopyForSellFasterNowInEnglish.key) else { return .control }
        return CopyForSellFasterNowInEnglish(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForSellFasterNowInEnglishObservable: Observable<CopyForSellFasterNowInEnglish> {
        return Bumper.observeValue(for: CopyForSellFasterNowInEnglish.key).map {
            CopyForSellFasterNowInEnglish(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var emergencyLocate: EmergencyLocate {
        guard let value = Bumper.value(for: EmergencyLocate.key) else { return .control }
        return EmergencyLocate(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var emergencyLocateObservable: Observable<EmergencyLocate> {
        return Bumper.observeValue(for: EmergencyLocate.key).map {
            EmergencyLocate(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var realEstateMap: RealEstateMap {
        guard let value = Bumper.value(for: RealEstateMap.key) else { return .control }
        return RealEstateMap(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstateMapObservable: Observable<RealEstateMap> {
        return Bumper.observeValue(for: RealEstateMap.key).map {
            RealEstateMap(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var iAmInterestedFeed: IAmInterestedFeed {
        guard let value = Bumper.value(for: IAmInterestedFeed.key) else { return .control }
        return IAmInterestedFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var iAmInterestedFeedObservable: Observable<IAmInterestedFeed> {
        return Bumper.observeValue(for: IAmInterestedFeed.key).map {
            IAmInterestedFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs {
        guard let value = Bumper.value(for: ChatConversationsListWithoutTabs.key) else { return .control }
        return ChatConversationsListWithoutTabs(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var chatConversationsListWithoutTabsObservable: Observable<ChatConversationsListWithoutTabs> {
        return Bumper.observeValue(for: ChatConversationsListWithoutTabs.key).map {
            ChatConversationsListWithoutTabs(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var personalizedFeed: PersonalizedFeed {
        guard let value = Bumper.value(for: PersonalizedFeed.key) else { return .control }
        return PersonalizedFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var personalizedFeedObservable: Observable<PersonalizedFeed> {
        return Bumper.observeValue(for: PersonalizedFeed.key).map {
            PersonalizedFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var servicesCategoryOnSalchichasMenu: ServicesCategoryOnSalchichasMenu {
        guard let value = Bumper.value(for: ServicesCategoryOnSalchichasMenu.key) else { return .control }
        return ServicesCategoryOnSalchichasMenu(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var servicesCategoryOnSalchichasMenuObservable: Observable<ServicesCategoryOnSalchichasMenu> {
        return Bumper.observeValue(for: ServicesCategoryOnSalchichasMenu.key).map {
            ServicesCategoryOnSalchichasMenu(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchBoxImprovements: SearchBoxImprovements {
        guard let value = Bumper.value(for: SearchBoxImprovements.key) else { return .control }
        return SearchBoxImprovements(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchBoxImprovementsObservable: Observable<SearchBoxImprovements> {
        return Bumper.observeValue(for: SearchBoxImprovements.key).map {
            SearchBoxImprovements(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var googleAdxForTR: GoogleAdxForTR {
        guard let value = Bumper.value(for: GoogleAdxForTR.key) else { return .control }
        return GoogleAdxForTR(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var googleAdxForTRObservable: Observable<GoogleAdxForTR> {
        return Bumper.observeValue(for: GoogleAdxForTR.key).map {
            GoogleAdxForTR(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiContactAfterSearch: MultiContactAfterSearch {
        guard let value = Bumper.value(for: MultiContactAfterSearch.key) else { return .control }
        return MultiContactAfterSearch(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiContactAfterSearchObservable: Observable<MultiContactAfterSearch> {
        return Bumper.observeValue(for: MultiContactAfterSearch.key).map {
            MultiContactAfterSearch(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showServicesFeatures: ShowServicesFeatures {
        guard let value = Bumper.value(for: ShowServicesFeatures.key) else { return .control }
        return ShowServicesFeatures(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showServicesFeaturesObservable: Observable<ShowServicesFeatures> {
        return Bumper.observeValue(for: ShowServicesFeatures.key).map {
            ShowServicesFeatures(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var emptySearchImprovements: EmptySearchImprovements {
        guard let value = Bumper.value(for: EmptySearchImprovements.key) else { return .control }
        return EmptySearchImprovements(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var emptySearchImprovementsObservable: Observable<EmptySearchImprovements> {
        return Bumper.observeValue(for: EmptySearchImprovements.key).map {
            EmptySearchImprovements(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var offensiveReportAlert: OffensiveReportAlert {
        guard let value = Bumper.value(for: OffensiveReportAlert.key) else { return .control }
        return OffensiveReportAlert(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var offensiveReportAlertObservable: Observable<OffensiveReportAlert> {
        return Bumper.observeValue(for: OffensiveReportAlert.key).map {
            OffensiveReportAlert(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var highlightedIAmInterestedFeed: HighlightedIAmInterestedFeed {
        guard let value = Bumper.value(for: HighlightedIAmInterestedFeed.key) else { return .control }
        return HighlightedIAmInterestedFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var highlightedIAmInterestedFeedObservable: Observable<HighlightedIAmInterestedFeed> {
        return Bumper.observeValue(for: HighlightedIAmInterestedFeed.key).map {
            HighlightedIAmInterestedFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS {
        guard let value = Bumper.value(for: FullScreenAdsWhenBrowsingForUS.key) else { return .control }
        return FullScreenAdsWhenBrowsingForUS(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var fullScreenAdsWhenBrowsingForUSObservable: Observable<FullScreenAdsWhenBrowsingForUS> {
        return Bumper.observeValue(for: FullScreenAdsWhenBrowsingForUS.key).map {
            FullScreenAdsWhenBrowsingForUS(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var videoPosting: VideoPosting {
        guard let value = Bumper.value(for: VideoPosting.key) else { return .control }
        return VideoPosting(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var videoPostingObservable: Observable<VideoPosting> {
        return Bumper.observeValue(for: VideoPosting.key).map {
            VideoPosting(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var predictivePosting: PredictivePosting {
        guard let value = Bumper.value(for: PredictivePosting.key) else { return .control }
        return PredictivePosting(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var predictivePostingObservable: Observable<PredictivePosting> {
        return Bumper.observeValue(for: PredictivePosting.key).map {
            PredictivePosting(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers {
        guard let value = Bumper.value(for: PreventMessagesFromFeedToProUsers.key) else { return .control }
        return PreventMessagesFromFeedToProUsers(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var preventMessagesFromFeedToProUsersObservable: Observable<PreventMessagesFromFeedToProUsers> {
        return Bumper.observeValue(for: PreventMessagesFromFeedToProUsers.key).map {
            PreventMessagesFromFeedToProUsers(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var simplifiedChatButton: SimplifiedChatButton {
        guard let value = Bumper.value(for: SimplifiedChatButton.key) else { return .control }
        return SimplifiedChatButton(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var simplifiedChatButtonObservable: Observable<SimplifiedChatButton> {
        return Bumper.observeValue(for: SimplifiedChatButton.key).map {
            SimplifiedChatButton(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showChatConnectionStatusBar: ShowChatConnectionStatusBar {
        guard let value = Bumper.value(for: ShowChatConnectionStatusBar.key) else { return .control }
        return ShowChatConnectionStatusBar(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showChatConnectionStatusBarObservable: Observable<ShowChatConnectionStatusBar> {
        return Bumper.observeValue(for: ShowChatConnectionStatusBar.key).map {
            ShowChatConnectionStatusBar(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem: AdvancedReputationSystem {
        guard let value = Bumper.value(for: AdvancedReputationSystem.key) else { return .control }
        return AdvancedReputationSystem(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystemObservable: Observable<AdvancedReputationSystem> {
        return Bumper.observeValue(for: AdvancedReputationSystem.key).map {
            AdvancedReputationSystem(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var notificationSettings: NotificationSettings {
        guard let value = Bumper.value(for: NotificationSettings.key) else { return .control }
        return NotificationSettings(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var notificationSettingsObservable: Observable<NotificationSettings> {
        return Bumper.observeValue(for: NotificationSettings.key).map {
            NotificationSettings(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var emptyStateErrorResearchActive: Bool {
        guard let value = Bumper.value(for: EmptyStateErrorResearchActive.key) else { return false }
        return EmptyStateErrorResearchActive(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var emptyStateErrorResearchActiveObservable: Observable<Bool> {
        return Bumper.observeValue(for: EmptyStateErrorResearchActive.key).map {
            EmptyStateErrorResearchActive(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif
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

enum SimplifiedChatButton: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC, variantD, variantE, variantF
    static var defaultValue: String { return SimplifiedChatButton.control.rawValue }
    static var enumValues: [SimplifiedChatButton] { return [.control, .baseline, .variantA, .variantB, .variantC, .variantD, .variantE, .variantF]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a simplified chat button on item page" } 
    static func fromPosition(_ position: Int) -> SimplifiedChatButton {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            case 5: return .variantD
            case 6: return .variantE
            case 7: return .variantF
            default: return .control
        }
    }
}

enum ShowChatConnectionStatusBar: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowChatConnectionStatusBar.control.rawValue }
    static var enumValues: [ShowChatConnectionStatusBar] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a toast in the chat with the websocket and network connection status" } 
    static func fromPosition(_ position: Int) -> ShowChatConnectionStatusBar {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AdvancedReputationSystem: String, BumperFeature  {
    case control, baseline, variantA, variantB
    static var defaultValue: String { return AdvancedReputationSystem.control.rawValue }
    static var enumValues: [AdvancedReputationSystem] { return [.control, .baseline, .variantA, .variantB]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Advance reputation system and Karma Score with SMS and tooltip" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            default: return .control
        }
    }
}

enum NotificationSettings: String, BumperFeature  {
    case control, baseline, differentLists, sameList
    static var defaultValue: String { return NotificationSettings.control.rawValue }
    static var enumValues: [NotificationSettings] { return [.control, .baseline, .differentLists, .sameList]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Settings to enable or disable each type of notification" } 
    static func fromPosition(_ position: Int) -> NotificationSettings {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .differentLists
            case 3: return .sameList
            default: return .control
        }
    }
}

enum EmptyStateErrorResearchActive: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return EmptyStateErrorResearchActive.no.rawValue }
    static var enumValues: [EmptyStateErrorResearchActive] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Sends more events and params to Amplitude to find the empty-state-error issue." } 
    var asBool: Bool { return self == .yes }
}

