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
        flags.append(RealEstateEnabled.self)
        flags.append(RequestsTimeOut.self)
        flags.append(DeckItemPage.self)
        flags.append(ShowAdsInFeedWithRatio.self)
        flags.append(RealEstateFlowType.self)
        flags.append(RealEstateNewCopy.self)
        flags.append(DummyUsersInfoProfile.self)
        flags.append(ShowInactiveConversations.self)
        flags.append(SearchImprovements.self)
        flags.append(RelaxedSearch.self)
        flags.append(ShowChatSafetyTips.self)
        flags.append(OnboardingIncentivizePosting.self)
        flags.append(CopyForChatNowInTurkey.self)
        flags.append(ChatNorris.self)
        flags.append(ShowProTagUserProfile.self)
        flags.append(CopyForChatNowInEnglish.self)
        flags.append(ShowExactLocationForPros.self)
        flags.append(ShowPasswordlessLogin.self)
        flags.append(CopyForSellFasterNowInEnglish.self)
        flags.append(EmergencyLocate.self)
        flags.append(PersonalizedFeed.self)
        flags.append(ServicesCategoryOnSalchichasMenu.self)
        flags.append(EmptySearchImprovements.self)
        flags.append(OffensiveReportAlert.self)
        flags.append(FullScreenAdsWhenBrowsingForUS.self)
        flags.append(VideoPosting.self)
        flags.append(PredictivePosting.self)
        flags.append(PreventMessagesFromFeedToProUsers.self)
        flags.append(SimplifiedChatButton.self)
        flags.append(ShowChatConnectionStatusBar.self)
        flags.append(NotificationSettings.self)
        flags.append(CarExtraFieldsEnabled.self)
        flags.append(ReportingFostaSesta.self)
        flags.append(ShowChatHeaderWithoutUser.self)
        flags.append(RealEstateMapTooltip.self)
        flags.append(AppInstallAdsInFeed.self)
        flags.append(EnableCTAMessageType.self)
        flags.append(OpenChatFromUserProfile.self)
        flags.append(SearchAlertsInSearchSuggestions.self)
        flags.append(EngagementBadging.self)
        flags.append(ServicesUnifiedFilterScreen.self)
        flags.append(FrictionlessShare.self)
        flags.append(ShowCommunity.self)
        flags.append(ExpressChatImprovement.self)
        flags.append(SmartQuickAnswers.self)
        flags.append(AlwaysShowBumpBannerWithLoading.self)
        flags.append(ServicesPaymentFrequency.self)
        flags.append(SearchAlertsDisableOldestIfMaximumReached.self)
        flags.append(ShowSellFasterInProfileCells.self)
        flags.append(BumpInEditCopys.self)
        flags.append(MultiAdRequestMoreInfo.self)
        flags.append(EnableJobsAndServicesCategory.self)
        flags.append(CopyForSellFasterNowInTurkish.self)
        flags.append(NotificationCenterRedesign.self)
        flags.append(TurkeyFreePosting.self)
        flags.append(RandomImInterestedMessages.self)
        flags.append(CarPromoCells.self)
        flags.append(RealEstatePromoCells.self)
        flags.append(AdvancedReputationSystem11.self)
        flags.append(AdvancedReputationSystem12.self)
        flags.append(ProUsersExtraImages.self)
        flags.append(SectionedDiscoveryFeed.self)
        flags.append(ServicesPromoCells.self)
        flags.append(ImInterestedInProfile.self)
        flags.append(ClickToTalk.self)
        flags.append(MutePushNotifications.self)
        flags.append(MultiAdRequestInChatSectionForUS.self)
        flags.append(MultiAdRequestInChatSectionForTR.self)
        flags.append(AffiliationEnabled.self)
        flags.append(MakeAnOfferButton.self)
        Bumper.initialize(flags)
    } 

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

    static var carExtraFieldsEnabled: CarExtraFieldsEnabled {
        guard let value = Bumper.value(for: CarExtraFieldsEnabled.key) else { return .control }
        return CarExtraFieldsEnabled(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var carExtraFieldsEnabledObservable: Observable<CarExtraFieldsEnabled> {
        return Bumper.observeValue(for: CarExtraFieldsEnabled.key).map {
            CarExtraFieldsEnabled(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var reportingFostaSesta: ReportingFostaSesta {
        guard let value = Bumper.value(for: ReportingFostaSesta.key) else { return .control }
        return ReportingFostaSesta(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var reportingFostaSestaObservable: Observable<ReportingFostaSesta> {
        return Bumper.observeValue(for: ReportingFostaSesta.key).map {
            ReportingFostaSesta(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showChatHeaderWithoutUser: Bool {
        guard let value = Bumper.value(for: ShowChatHeaderWithoutUser.key) else { return true }
        return ShowChatHeaderWithoutUser(rawValue: value)?.asBool ?? true
    } 

    #if (RX_BUMPER)
    static var showChatHeaderWithoutUserObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowChatHeaderWithoutUser.key).map {
            ShowChatHeaderWithoutUser(rawValue: $0 ?? "")?.asBool ?? true
        }
    }
    #endif

    static var realEstateMapTooltip: RealEstateMapTooltip {
        guard let value = Bumper.value(for: RealEstateMapTooltip.key) else { return .control }
        return RealEstateMapTooltip(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstateMapTooltipObservable: Observable<RealEstateMapTooltip> {
        return Bumper.observeValue(for: RealEstateMapTooltip.key).map {
            RealEstateMapTooltip(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var appInstallAdsInFeed: AppInstallAdsInFeed {
        guard let value = Bumper.value(for: AppInstallAdsInFeed.key) else { return .control }
        return AppInstallAdsInFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var appInstallAdsInFeedObservable: Observable<AppInstallAdsInFeed> {
        return Bumper.observeValue(for: AppInstallAdsInFeed.key).map {
            AppInstallAdsInFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var enableCTAMessageType: Bool {
        guard let value = Bumper.value(for: EnableCTAMessageType.key) else { return false }
        return EnableCTAMessageType(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var enableCTAMessageTypeObservable: Observable<Bool> {
        return Bumper.observeValue(for: EnableCTAMessageType.key).map {
            EnableCTAMessageType(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var openChatFromUserProfile: OpenChatFromUserProfile {
        guard let value = Bumper.value(for: OpenChatFromUserProfile.key) else { return .control }
        return OpenChatFromUserProfile(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var openChatFromUserProfileObservable: Observable<OpenChatFromUserProfile> {
        return Bumper.observeValue(for: OpenChatFromUserProfile.key).map {
            OpenChatFromUserProfile(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions {
        guard let value = Bumper.value(for: SearchAlertsInSearchSuggestions.key) else { return .control }
        return SearchAlertsInSearchSuggestions(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchAlertsInSearchSuggestionsObservable: Observable<SearchAlertsInSearchSuggestions> {
        return Bumper.observeValue(for: SearchAlertsInSearchSuggestions.key).map {
            SearchAlertsInSearchSuggestions(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var engagementBadging: EngagementBadging {
        guard let value = Bumper.value(for: EngagementBadging.key) else { return .control }
        return EngagementBadging(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var engagementBadgingObservable: Observable<EngagementBadging> {
        return Bumper.observeValue(for: EngagementBadging.key).map {
            EngagementBadging(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var servicesUnifiedFilterScreen: ServicesUnifiedFilterScreen {
        guard let value = Bumper.value(for: ServicesUnifiedFilterScreen.key) else { return .control }
        return ServicesUnifiedFilterScreen(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var servicesUnifiedFilterScreenObservable: Observable<ServicesUnifiedFilterScreen> {
        return Bumper.observeValue(for: ServicesUnifiedFilterScreen.key).map {
            ServicesUnifiedFilterScreen(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var frictionlessShare: FrictionlessShare {
        guard let value = Bumper.value(for: FrictionlessShare.key) else { return .control }
        return FrictionlessShare(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var frictionlessShareObservable: Observable<FrictionlessShare> {
        return Bumper.observeValue(for: FrictionlessShare.key).map {
            FrictionlessShare(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showCommunity: ShowCommunity {
        guard let value = Bumper.value(for: ShowCommunity.key) else { return .control }
        return ShowCommunity(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showCommunityObservable: Observable<ShowCommunity> {
        return Bumper.observeValue(for: ShowCommunity.key).map {
            ShowCommunity(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var expressChatImprovement: ExpressChatImprovement {
        guard let value = Bumper.value(for: ExpressChatImprovement.key) else { return .control }
        return ExpressChatImprovement(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var expressChatImprovementObservable: Observable<ExpressChatImprovement> {
        return Bumper.observeValue(for: ExpressChatImprovement.key).map {
            ExpressChatImprovement(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var smartQuickAnswers: SmartQuickAnswers {
        guard let value = Bumper.value(for: SmartQuickAnswers.key) else { return .control }
        return SmartQuickAnswers(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var smartQuickAnswersObservable: Observable<SmartQuickAnswers> {
        return Bumper.observeValue(for: SmartQuickAnswers.key).map {
            SmartQuickAnswers(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var alwaysShowBumpBannerWithLoading: AlwaysShowBumpBannerWithLoading {
        guard let value = Bumper.value(for: AlwaysShowBumpBannerWithLoading.key) else { return .control }
        return AlwaysShowBumpBannerWithLoading(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var alwaysShowBumpBannerWithLoadingObservable: Observable<AlwaysShowBumpBannerWithLoading> {
        return Bumper.observeValue(for: AlwaysShowBumpBannerWithLoading.key).map {
            AlwaysShowBumpBannerWithLoading(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var servicesPaymentFrequency: ServicesPaymentFrequency {
        guard let value = Bumper.value(for: ServicesPaymentFrequency.key) else { return .control }
        return ServicesPaymentFrequency(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var servicesPaymentFrequencyObservable: Observable<ServicesPaymentFrequency> {
        return Bumper.observeValue(for: ServicesPaymentFrequency.key).map {
            ServicesPaymentFrequency(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchAlertsDisableOldestIfMaximumReached: SearchAlertsDisableOldestIfMaximumReached {
        guard let value = Bumper.value(for: SearchAlertsDisableOldestIfMaximumReached.key) else { return .control }
        return SearchAlertsDisableOldestIfMaximumReached(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchAlertsDisableOldestIfMaximumReachedObservable: Observable<SearchAlertsDisableOldestIfMaximumReached> {
        return Bumper.observeValue(for: SearchAlertsDisableOldestIfMaximumReached.key).map {
            SearchAlertsDisableOldestIfMaximumReached(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showSellFasterInProfileCells: ShowSellFasterInProfileCells {
        guard let value = Bumper.value(for: ShowSellFasterInProfileCells.key) else { return .control }
        return ShowSellFasterInProfileCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showSellFasterInProfileCellsObservable: Observable<ShowSellFasterInProfileCells> {
        return Bumper.observeValue(for: ShowSellFasterInProfileCells.key).map {
            ShowSellFasterInProfileCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var bumpInEditCopys: BumpInEditCopys {
        guard let value = Bumper.value(for: BumpInEditCopys.key) else { return .control }
        return BumpInEditCopys(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var bumpInEditCopysObservable: Observable<BumpInEditCopys> {
        return Bumper.observeValue(for: BumpInEditCopys.key).map {
            BumpInEditCopys(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiAdRequestMoreInfo: MultiAdRequestMoreInfo {
        guard let value = Bumper.value(for: MultiAdRequestMoreInfo.key) else { return .control }
        return MultiAdRequestMoreInfo(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiAdRequestMoreInfoObservable: Observable<MultiAdRequestMoreInfo> {
        return Bumper.observeValue(for: MultiAdRequestMoreInfo.key).map {
            MultiAdRequestMoreInfo(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var enableJobsAndServicesCategory: EnableJobsAndServicesCategory {
        guard let value = Bumper.value(for: EnableJobsAndServicesCategory.key) else { return .control }
        return EnableJobsAndServicesCategory(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var enableJobsAndServicesCategoryObservable: Observable<EnableJobsAndServicesCategory> {
        return Bumper.observeValue(for: EnableJobsAndServicesCategory.key).map {
            EnableJobsAndServicesCategory(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForSellFasterNowInTurkish: CopyForSellFasterNowInTurkish {
        guard let value = Bumper.value(for: CopyForSellFasterNowInTurkish.key) else { return .control }
        return CopyForSellFasterNowInTurkish(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForSellFasterNowInTurkishObservable: Observable<CopyForSellFasterNowInTurkish> {
        return Bumper.observeValue(for: CopyForSellFasterNowInTurkish.key).map {
            CopyForSellFasterNowInTurkish(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var notificationCenterRedesign: NotificationCenterRedesign {
        guard let value = Bumper.value(for: NotificationCenterRedesign.key) else { return .control }
        return NotificationCenterRedesign(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var notificationCenterRedesignObservable: Observable<NotificationCenterRedesign> {
        return Bumper.observeValue(for: NotificationCenterRedesign.key).map {
            NotificationCenterRedesign(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var turkeyFreePosting: TurkeyFreePosting {
        guard let value = Bumper.value(for: TurkeyFreePosting.key) else { return .control }
        return TurkeyFreePosting(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var turkeyFreePostingObservable: Observable<TurkeyFreePosting> {
        return Bumper.observeValue(for: TurkeyFreePosting.key).map {
            TurkeyFreePosting(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var randomImInterestedMessages: RandomImInterestedMessages {
        guard let value = Bumper.value(for: RandomImInterestedMessages.key) else { return .control }
        return RandomImInterestedMessages(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var randomImInterestedMessagesObservable: Observable<RandomImInterestedMessages> {
        return Bumper.observeValue(for: RandomImInterestedMessages.key).map {
            RandomImInterestedMessages(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var carPromoCells: CarPromoCells {
        guard let value = Bumper.value(for: CarPromoCells.key) else { return .control }
        return CarPromoCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var carPromoCellsObservable: Observable<CarPromoCells> {
        return Bumper.observeValue(for: CarPromoCells.key).map {
            CarPromoCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var realEstatePromoCells: RealEstatePromoCells {
        guard let value = Bumper.value(for: RealEstatePromoCells.key) else { return .control }
        return RealEstatePromoCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstatePromoCellsObservable: Observable<RealEstatePromoCells> {
        return Bumper.observeValue(for: RealEstatePromoCells.key).map {
            RealEstatePromoCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem11: AdvancedReputationSystem11 {
        guard let value = Bumper.value(for: AdvancedReputationSystem11.key) else { return .control }
        return AdvancedReputationSystem11(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystem11Observable: Observable<AdvancedReputationSystem11> {
        return Bumper.observeValue(for: AdvancedReputationSystem11.key).map {
            AdvancedReputationSystem11(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem12: AdvancedReputationSystem12 {
        guard let value = Bumper.value(for: AdvancedReputationSystem12.key) else { return .control }
        return AdvancedReputationSystem12(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystem12Observable: Observable<AdvancedReputationSystem12> {
        return Bumper.observeValue(for: AdvancedReputationSystem12.key).map {
            AdvancedReputationSystem12(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var proUsersExtraImages: ProUsersExtraImages {
        guard let value = Bumper.value(for: ProUsersExtraImages.key) else { return .control }
        return ProUsersExtraImages(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var proUsersExtraImagesObservable: Observable<ProUsersExtraImages> {
        return Bumper.observeValue(for: ProUsersExtraImages.key).map {
            ProUsersExtraImages(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var sectionedDiscoveryFeed: SectionedDiscoveryFeed {
        guard let value = Bumper.value(for: SectionedDiscoveryFeed.key) else { return .control }
        return SectionedDiscoveryFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var sectionedDiscoveryFeedObservable: Observable<SectionedDiscoveryFeed> {
        return Bumper.observeValue(for: SectionedDiscoveryFeed.key).map {
            SectionedDiscoveryFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var servicesPromoCells: ServicesPromoCells {
        guard let value = Bumper.value(for: ServicesPromoCells.key) else { return .control }
        return ServicesPromoCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var servicesPromoCellsObservable: Observable<ServicesPromoCells> {
        return Bumper.observeValue(for: ServicesPromoCells.key).map {
            ServicesPromoCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var imInterestedInProfile: ImInterestedInProfile {
        guard let value = Bumper.value(for: ImInterestedInProfile.key) else { return .control }
        return ImInterestedInProfile(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var imInterestedInProfileObservable: Observable<ImInterestedInProfile> {
        return Bumper.observeValue(for: ImInterestedInProfile.key).map {
            ImInterestedInProfile(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var clickToTalk: ClickToTalk {
        guard let value = Bumper.value(for: ClickToTalk.key) else { return .control }
        return ClickToTalk(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var clickToTalkObservable: Observable<ClickToTalk> {
        return Bumper.observeValue(for: ClickToTalk.key).map {
            ClickToTalk(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var mutePushNotifications: MutePushNotifications {
        guard let value = Bumper.value(for: MutePushNotifications.key) else { return .control }
        return MutePushNotifications(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var mutePushNotificationsObservable: Observable<MutePushNotifications> {
        return Bumper.observeValue(for: MutePushNotifications.key).map {
            MutePushNotifications(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiAdRequestInChatSectionForUS: MultiAdRequestInChatSectionForUS {
        guard let value = Bumper.value(for: MultiAdRequestInChatSectionForUS.key) else { return .control }
        return MultiAdRequestInChatSectionForUS(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiAdRequestInChatSectionForUSObservable: Observable<MultiAdRequestInChatSectionForUS> {
        return Bumper.observeValue(for: MultiAdRequestInChatSectionForUS.key).map {
            MultiAdRequestInChatSectionForUS(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiAdRequestInChatSectionForTR: MultiAdRequestInChatSectionForTR {
        guard let value = Bumper.value(for: MultiAdRequestInChatSectionForTR.key) else { return .control }
        return MultiAdRequestInChatSectionForTR(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiAdRequestInChatSectionForTRObservable: Observable<MultiAdRequestInChatSectionForTR> {
        return Bumper.observeValue(for: MultiAdRequestInChatSectionForTR.key).map {
            MultiAdRequestInChatSectionForTR(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var affiliationEnabled: AffiliationEnabled {
        guard let value = Bumper.value(for: AffiliationEnabled.key) else { return .control }
        return AffiliationEnabled(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var affiliationEnabledObservable: Observable<AffiliationEnabled> {
        return Bumper.observeValue(for: AffiliationEnabled.key).map {
            AffiliationEnabled(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var makeAnOfferButton: MakeAnOfferButton {
        guard let value = Bumper.value(for: MakeAnOfferButton.key) else { return .control }
        return MakeAnOfferButton(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var makeAnOfferButtonObservable: Observable<MakeAnOfferButton> {
        return Bumper.observeValue(for: MakeAnOfferButton.key).map {
            MakeAnOfferButton(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif
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

enum ShowAdsInFeedWithRatio: String, BumperFeature  {
    case control, baseline, ten, fifteen, twenty
    static var defaultValue: String { return ShowAdsInFeedWithRatio.control.rawValue }
    static var enumValues: [ShowAdsInFeedWithRatio] { return [.control, .baseline, .ten, .fifteen, .twenty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] show ads in feed every X cells" } 
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
    static var description: String { return "[CHAT] Show button to access inactive conversations" } 
    var asBool: Bool { return self == .yes }
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
    static var description: String { return "[CHAT] Show chat safety tips to new users" } 
    var asBool: Bool { return self == .yes }
}

enum OnboardingIncentivizePosting: String, BumperFeature  {
    case control, baseline, blockingPosting, blockingPostingSkipWelcome
    static var defaultValue: String { return OnboardingIncentivizePosting.control.rawValue }
    static var enumValues: [OnboardingIncentivizePosting] { return [.control, .baseline, .blockingPosting, .blockingPostingSkipWelcome]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Leads the user through the posting feature and onboarding improvements" } 
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
    static var description: String { return "[CHAT] Show the create meeting option in chat detail view." } 
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

enum ShowProTagUserProfile: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowProTagUserProfile.no.rawValue }
    static var enumValues: [ShowProTagUserProfile] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show Professional tag in user profile" } 
    var asBool: Bool { return self == .yes }
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

enum ShowExactLocationForPros: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return ShowExactLocationForPros.yes.rawValue }
    static var enumValues: [ShowExactLocationForPros] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show exact location for professional delaers in listing detail map" } 
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
    static var description: String { return "[MONEY] Try different copies for 'Sell faster now' banner in English" } 
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
    static var description: String { return "[PRODUCTS] Show services category on salchichas menu" } 
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

enum FullScreenAdsWhenBrowsingForUS: String, BumperFeature  {
    case control, baseline, adsForAllUsers, adsForOldUsers
    static var defaultValue: String { return FullScreenAdsWhenBrowsingForUS.control.rawValue }
    static var enumValues: [FullScreenAdsWhenBrowsingForUS] { return [.control, .baseline, .adsForAllUsers, .adsForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show full screen Interstitial while browsing through items" } 
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
    static var description: String { return "[PRODUCTS] Show video posting flow when pressing Other Items and Other Vehicles and Parts on salchichas menu" } 
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
    static var description: String { return "[PRODUCTS] Show predictive posting flow when pressing Other Items on salchichas menu" } 
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
    static var description: String { return "[MONEY] If buyer taps 'I'm interested' button in the feed and the listing is from a PRO user, show the phone number request screen" } 
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
    static var description: String { return "[PRODUCTS] Show a simplified chat button on item page" } 
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
    static var description: String { return "[CHAT] Show a toast in the chat with the websocket and network connection status" } 
    static func fromPosition(_ position: Int) -> ShowChatConnectionStatusBar {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum NotificationSettings: String, BumperFeature  {
    case control, baseline, differentLists, sameList
    static var defaultValue: String { return NotificationSettings.control.rawValue }
    static var enumValues: [NotificationSettings] { return [.control, .baseline, .differentLists, .sameList]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Settings to enable or disable each type of notification" } 
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

enum CarExtraFieldsEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return CarExtraFieldsEnabled.control.rawValue }
    static var enumValues: [CarExtraFieldsEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "allows user to see extra car fields (bodyType, fuelType, drivetrain, transmission, seats, mileage)" } 
    static func fromPosition(_ position: Int) -> CarExtraFieldsEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ReportingFostaSesta: String, BumperFeature  {
    case control, baseline, withIcons, withoutIcons
    static var defaultValue: String { return ReportingFostaSesta.control.rawValue }
    static var enumValues: [ReportingFostaSesta] { return [.control, .baseline, .withIcons, .withoutIcons]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show new user/product reporting flow (FOSTA-SESTA compliance)" } 
    static func fromPosition(_ position: Int) -> ReportingFostaSesta {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .withIcons
            case 3: return .withoutIcons
            default: return .control
        }
    }
}

enum ShowChatHeaderWithoutUser: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return ShowChatHeaderWithoutUser.yes.rawValue }
    static var enumValues: [ShowChatHeaderWithoutUser] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Use the new header WITHOUT USER in chat detail" } 
    var asBool: Bool { return self == .yes }
}

enum RealEstateMapTooltip: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateMapTooltip.control.rawValue }
    static var enumValues: [RealEstateMapTooltip] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show tooltip for Real Estate Map" } 
    static func fromPosition(_ position: Int) -> RealEstateMapTooltip {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AppInstallAdsInFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AppInstallAdsInFeed.control.rawValue }
    static var enumValues: [AppInstallAdsInFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show App Install Ads from Google Adx in feed" } 
    static func fromPosition(_ position: Int) -> AppInstallAdsInFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EnableCTAMessageType: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return EnableCTAMessageType.no.rawValue }
    static var enumValues: [EnableCTAMessageType] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Enable the CTA message type" } 
    var asBool: Bool { return self == .yes }
}

enum OpenChatFromUserProfile: String, BumperFeature  {
    case control, baseline, vatiant1NoQuickAnswers, variant2WithOneTimeQuickAnswers
    static var defaultValue: String { return OpenChatFromUserProfile.control.rawValue }
    static var enumValues: [OpenChatFromUserProfile] { return [.control, .baseline, .vatiant1NoQuickAnswers, .variant2WithOneTimeQuickAnswers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Open a chat from the user profile" } 
    static func fromPosition(_ position: Int) -> OpenChatFromUserProfile {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .vatiant1NoQuickAnswers
            case 3: return .variant2WithOneTimeQuickAnswers
            default: return .control
        }
    }
}

enum SearchAlertsInSearchSuggestions: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SearchAlertsInSearchSuggestions.control.rawValue }
    static var enumValues: [SearchAlertsInSearchSuggestions] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show search alerts in search suggestions view" } 
    static func fromPosition(_ position: Int) -> SearchAlertsInSearchSuggestions {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EngagementBadging: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EngagementBadging.control.rawValue }
    static var enumValues: [EngagementBadging] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show recent items bubble in feed basic approach" } 
    static func fromPosition(_ position: Int) -> EngagementBadging {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ServicesUnifiedFilterScreen: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ServicesUnifiedFilterScreen.control.rawValue }
    static var enumValues: [ServicesUnifiedFilterScreen] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show new services filter screen" } 
    static func fromPosition(_ position: Int) -> ServicesUnifiedFilterScreen {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum FrictionlessShare: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return FrictionlessShare.control.rawValue }
    static var enumValues: [FrictionlessShare] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[PRODUCTS] Open facebook share dialog in congrats screen" } 
    static func fromPosition(_ position: Int) -> FrictionlessShare {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowCommunity: String, BumperFeature  {
    case control, baseline, communityOnNavBar, communityOnTabBar
    static var defaultValue: String { return ShowCommunity.control.rawValue }
    static var enumValues: [ShowCommunity] { return [.control, .baseline, .communityOnNavBar, .communityOnTabBar]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Users] Show button/tab to open the new Community feature" } 
    static func fromPosition(_ position: Int) -> ShowCommunity {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .communityOnNavBar
            case 3: return .communityOnTabBar
            default: return .control
        }
    }
}

enum ExpressChatImprovement: String, BumperFeature  {
    case control, baseline, hideDontAsk, newTitleAndHideDontAsk
    static var defaultValue: String { return ExpressChatImprovement.control.rawValue }
    static var enumValues: [ExpressChatImprovement] { return [.control, .baseline, .hideDontAsk, .newTitleAndHideDontAsk]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Express chat improvements" } 
    static func fromPosition(_ position: Int) -> ExpressChatImprovement {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .hideDontAsk
            case 3: return .newTitleAndHideDontAsk
            default: return .control
        }
    }
}

enum SmartQuickAnswers: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SmartQuickAnswers.control.rawValue }
    static var enumValues: [SmartQuickAnswers] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show smart quick answer events" } 
    static func fromPosition(_ position: Int) -> SmartQuickAnswers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AlwaysShowBumpBannerWithLoading: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AlwaysShowBumpBannerWithLoading.control.rawValue }
    static var enumValues: [AlwaysShowBumpBannerWithLoading] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Always show bump banner with a loading till we get the info" } 
    static func fromPosition(_ position: Int) -> AlwaysShowBumpBannerWithLoading {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ServicesPaymentFrequency: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ServicesPaymentFrequency.control.rawValue }
    static var enumValues: [ServicesPaymentFrequency] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[SERVICES] shows services paymentFrequency functionality (e.g 2 euro per day, etc.)" } 
    static func fromPosition(_ position: Int) -> ServicesPaymentFrequency {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SearchAlertsDisableOldestIfMaximumReached: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SearchAlertsDisableOldestIfMaximumReached.control.rawValue }
    static var enumValues: [SearchAlertsDisableOldestIfMaximumReached] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Disable oldest search alert if a new one is created and the maximum has been reached" } 
    static func fromPosition(_ position: Int) -> SearchAlertsDisableOldestIfMaximumReached {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowSellFasterInProfileCells: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowSellFasterInProfileCells.control.rawValue }
    static var enumValues: [ShowSellFasterInProfileCells] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Add CTA to bump up to profile listing cells" } 
    static func fromPosition(_ position: Int) -> ShowSellFasterInProfileCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum BumpInEditCopys: String, BumperFeature  {
    case control, baseline, attractMoreBuyers, attractMoreBuyersToSellFast, showMeHowToAttract
    static var defaultValue: String { return BumpInEditCopys.control.rawValue }
    static var enumValues: [BumpInEditCopys] { return [.control, .baseline, .attractMoreBuyers, .attractMoreBuyersToSellFast, .showMeHowToAttract]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Test different variants for bump up in edit listing screen" } 
    static func fromPosition(_ position: Int) -> BumpInEditCopys {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .attractMoreBuyers
            case 3: return .attractMoreBuyersToSellFast
            case 4: return .showMeHowToAttract
            default: return .control
        }
    }
}

enum MultiAdRequestMoreInfo: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MultiAdRequestMoreInfo.control.rawValue }
    static var enumValues: [MultiAdRequestMoreInfo] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Test different ad sizes in more info view" } 
    static func fromPosition(_ position: Int) -> MultiAdRequestMoreInfo {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EnableJobsAndServicesCategory: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EnableJobsAndServicesCategory.control.rawValue }
    static var enumValues: [EnableJobsAndServicesCategory] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[SERVICES] Services category becomes Jobs & Services, enables features related to jobs" } 
    static func fromPosition(_ position: Int) -> EnableJobsAndServicesCategory {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CopyForSellFasterNowInTurkish: String, BumperFeature  {
    case control, baseline, variantB, variantC, variantD
    static var defaultValue: String { return CopyForSellFasterNowInTurkish.control.rawValue }
    static var enumValues: [CopyForSellFasterNowInTurkish] { return [.control, .baseline, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Try different copies for 'Sell faster now' banner in Turkish" } 
    static func fromPosition(_ position: Int) -> CopyForSellFasterNowInTurkish {
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

enum NotificationCenterRedesign: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NotificationCenterRedesign.control.rawValue }
    static var enumValues: [NotificationCenterRedesign] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Notification center redesign with sections and modern UI design" } 
    static func fromPosition(_ position: Int) -> NotificationCenterRedesign {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum TurkeyFreePosting: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return TurkeyFreePosting.control.rawValue }
    static var enumValues: [TurkeyFreePosting] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[PRODUCTS] Enable Leanplum driven Turkey free posting" } 
    static func fromPosition(_ position: Int) -> TurkeyFreePosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RandomImInterestedMessages: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RandomImInterestedMessages.control.rawValue }
    static var enumValues: [RandomImInterestedMessages] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Random Im Interested messages from listing list" } 
    static func fromPosition(_ position: Int) -> RandomImInterestedMessages {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CarPromoCells: String, BumperFeature  {
    case control, baseline, variantA, variantB
    static var defaultValue: String { return CarPromoCells.control.rawValue }
    static var enumValues: [CarPromoCells] { return [.control, .baseline, .variantA, .variantB]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CARS] Show promo cells for cars" } 
    static func fromPosition(_ position: Int) -> CarPromoCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            default: return .control
        }
    }
}

enum RealEstatePromoCells: String, BumperFeature  {
    case control, baseline, variantA
    static var defaultValue: String { return RealEstatePromoCells.control.rawValue }
    static var enumValues: [RealEstatePromoCells] { return [.control, .baseline, .variantA]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[REAL ESTATE] Show NEW promo cells for real Estate" } 
    static func fromPosition(_ position: Int) -> RealEstatePromoCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            default: return .control
        }
    }
}

enum AdvancedReputationSystem11: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AdvancedReputationSystem11.control.rawValue }
    static var enumValues: [AdvancedReputationSystem11] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[USERS] ARS v1.1" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem11 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AdvancedReputationSystem12: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AdvancedReputationSystem12.control.rawValue }
    static var enumValues: [AdvancedReputationSystem12] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[USERS] ARS v1.2" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem12 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ProUsersExtraImages: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ProUsersExtraImages.control.rawValue }
    static var enumValues: [ProUsersExtraImages] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Cars] allow up to 25 images to be displayed on the product detail page" } 
    static func fromPosition(_ position: Int) -> ProUsersExtraImages {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SectionedDiscoveryFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SectionedDiscoveryFeed.control.rawValue }
    static var enumValues: [SectionedDiscoveryFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Discovery] Show SectionedFeed" } 
    static func fromPosition(_ position: Int) -> SectionedDiscoveryFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ServicesPromoCells: String, BumperFeature  {
    case control, baseline, activeWithCallToAction, activeWithoutCallToAction
    static var defaultValue: String { return ServicesPromoCells.control.rawValue }
    static var enumValues: [ServicesPromoCells] { return [.control, .baseline, .activeWithCallToAction, .activeWithoutCallToAction]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[SERVICES] Show promo cells for Services" } 
    static func fromPosition(_ position: Int) -> ServicesPromoCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .activeWithCallToAction
            case 3: return .activeWithoutCallToAction
            default: return .control
        }
    }
}

enum ImInterestedInProfile: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ImInterestedInProfile.control.rawValue }
    static var enumValues: [ImInterestedInProfile] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show Im Interested buttons in public profiles" } 
    static func fromPosition(_ position: Int) -> ImInterestedInProfile {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ClickToTalk: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ClickToTalk.control.rawValue }
    static var enumValues: [ClickToTalk] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[VERTICALS] Show Click to talk" } 
    static func fromPosition(_ position: Int) -> ClickToTalk {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MutePushNotifications: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MutePushNotifications.control.rawValue }
    static var enumValues: [MutePushNotifications] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CORE] Push notifications won't make a sound during some night hours." } 
    static func fromPosition(_ position: Int) -> MutePushNotifications {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MultiAdRequestInChatSectionForUS: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MultiAdRequestInChatSectionForUS.control.rawValue }
    static var enumValues: [MultiAdRequestInChatSectionForUS] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Muti ad request in Chat section. For US" } 
    static func fromPosition(_ position: Int) -> MultiAdRequestInChatSectionForUS {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MultiAdRequestInChatSectionForTR: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MultiAdRequestInChatSectionForTR.control.rawValue }
    static var enumValues: [MultiAdRequestInChatSectionForTR] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Muti ad request in Chat section. For Turkey" } 
    static func fromPosition(_ position: Int) -> MultiAdRequestInChatSectionForTR {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AffiliationEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AffiliationEnabled.control.rawValue }
    static var enumValues: [AffiliationEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Enables Affiliation / Referral Program" } 
    static func fromPosition(_ position: Int) -> AffiliationEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MakeAnOfferButton: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MakeAnOfferButton.control.rawValue }
    static var enumValues: [MakeAnOfferButton] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[P2P PAYMENTS] Show make an offer button" } 
    static func fromPosition(_ position: Int) -> MakeAnOfferButton {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

