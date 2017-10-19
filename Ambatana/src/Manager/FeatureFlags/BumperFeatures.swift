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
        flags.append(WebsocketChat.self)
        flags.append(ShowNPSSurvey.self)
        flags.append(SurveyEnabled.self)
        flags.append(FreeBumpUpEnabled.self)
        flags.append(PricedBumpUpEnabled.self)
        flags.append(CaptchaTransparent.self)
        flags.append(NewCarsMultiRequesterEnabled.self)
        flags.append(InAppRatingIOS10.self)
        flags.append(AddSuperKeywordsOnFeed.self)
        flags.append(TweaksCarPostingFlow.self)
        flags.append(UserReviewsReportEnabled.self)
        flags.append(DynamicQuickAnswers.self)
        flags.append(AppRatingDialogInactive.self)
        flags.append(ExpandableCategorySelectionMenu.self)
        flags.append(LocationDataSourceEndpoint.self)
        flags.append(DefaultRadiusDistanceFeed.self)
        flags.append(RealEstateEnabled.self)
        flags.append(SearchAutocomplete.self)
        flags.append(NewCarouselTapNextPhotoNavigationEnabled.self)
        flags.append(ShowPriceAfterSearchOrFilter.self)
        flags.append(RequestsTimeOut.self)
        flags.append(NewBumpUpExplanation.self)
        flags.append(HomeRelatedEnabled.self)
        flags.append(HideChatButtonOnFeaturedCells.self)
        flags.append(SuperKeywordGroupsAndSubgroupsInFeed.self)
        Bumper.initialize(flags)
    } 

    static var websocketChat: Bool {
        guard let value = Bumper.value(for: WebsocketChat.key) else { return false }
        return WebsocketChat(rawValue: value)?.asBool ?? false
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

    static var captchaTransparent: Bool {
        guard let value = Bumper.value(for: CaptchaTransparent.key) else { return false }
        return CaptchaTransparent(rawValue: value)?.asBool ?? false
    }

    static var newCarsMultiRequesterEnabled: Bool {
        guard let value = Bumper.value(for: NewCarsMultiRequesterEnabled.key) else { return false }
        return NewCarsMultiRequesterEnabled(rawValue: value)?.asBool ?? false
    }

    static var inAppRatingIOS10: Bool {
        guard let value = Bumper.value(for: InAppRatingIOS10.key) else { return false }
        return InAppRatingIOS10(rawValue: value)?.asBool ?? false
    }

    static var addSuperKeywordsOnFeed: AddSuperKeywordsOnFeed {
        guard let value = Bumper.value(for: AddSuperKeywordsOnFeed.key) else { return .control }
        return AddSuperKeywordsOnFeed(rawValue: value) ?? .control 
    }

    static var tweaksCarPostingFlow: TweaksCarPostingFlow {
        guard let value = Bumper.value(for: TweaksCarPostingFlow.key) else { return .control }
        return TweaksCarPostingFlow(rawValue: value) ?? .control 
    }

    static var userReviewsReportEnabled: Bool {
        guard let value = Bumper.value(for: UserReviewsReportEnabled.key) else { return false }
        return UserReviewsReportEnabled(rawValue: value)?.asBool ?? false
    }

    static var dynamicQuickAnswers: DynamicQuickAnswers {
        guard let value = Bumper.value(for: DynamicQuickAnswers.key) else { return .control }
        return DynamicQuickAnswers(rawValue: value) ?? .control 
    }

    static var appRatingDialogInactive: Bool {
        guard let value = Bumper.value(for: AppRatingDialogInactive.key) else { return false }
        return AppRatingDialogInactive(rawValue: value)?.asBool ?? false
    }

    static var expandableCategorySelectionMenu: ExpandableCategorySelectionMenu {
        guard let value = Bumper.value(for: ExpandableCategorySelectionMenu.key) else { return .control }
        return ExpandableCategorySelectionMenu(rawValue: value) ?? .control 
    }

    static var locationDataSourceEndpoint: LocationDataSourceEndpoint {
        guard let value = Bumper.value(for: LocationDataSourceEndpoint.key) else { return .control }
        return LocationDataSourceEndpoint(rawValue: value) ?? .control 
    }

    static var defaultRadiusDistanceFeed: DefaultRadiusDistanceFeed {
        guard let value = Bumper.value(for: DefaultRadiusDistanceFeed.key) else { return .control }
        return DefaultRadiusDistanceFeed(rawValue: value) ?? .control 
    }

    static var realEstateEnabled: Bool {
        guard let value = Bumper.value(for: RealEstateEnabled.key) else { return false }
        return RealEstateEnabled(rawValue: value)?.asBool ?? false
    }

    static var searchAutocomplete: SearchAutocomplete {
        guard let value = Bumper.value(for: SearchAutocomplete.key) else { return .control }
        return SearchAutocomplete(rawValue: value) ?? .control 
    }

    static var newCarouselTapNextPhotoNavigationEnabled: NewCarouselTapNextPhotoNavigationEnabled {
        guard let value = Bumper.value(for: NewCarouselTapNextPhotoNavigationEnabled.key) else { return .control }
        return NewCarouselTapNextPhotoNavigationEnabled(rawValue: value) ?? .control 
    }

    static var showPriceAfterSearchOrFilter: ShowPriceAfterSearchOrFilter {
        guard let value = Bumper.value(for: ShowPriceAfterSearchOrFilter.key) else { return .control }
        return ShowPriceAfterSearchOrFilter(rawValue: value) ?? .control 
    }

    static var requestsTimeOut: RequestsTimeOut {
        guard let value = Bumper.value(for: RequestsTimeOut.key) else { return .baseline }
        return RequestsTimeOut(rawValue: value) ?? .baseline 
    }

    static var newBumpUpExplanation: NewBumpUpExplanation {
        guard let value = Bumper.value(for: NewBumpUpExplanation.key) else { return .control }
        return NewBumpUpExplanation(rawValue: value) ?? .control 
    }

    static var homeRelatedEnabled: HomeRelatedEnabled {
        guard let value = Bumper.value(for: HomeRelatedEnabled.key) else { return .control }
        return HomeRelatedEnabled(rawValue: value) ?? .control
    }

    static var hideChatButtonOnFeaturedCells: HideChatButtonOnFeaturedCells {
        guard let value = Bumper.value(for: HideChatButtonOnFeaturedCells.key) else { return .control }
        return HideChatButtonOnFeaturedCells(rawValue: value) ?? .control 
    }

    static var superKeywordGroupsAndSubgroupsInFeed: SuperKeywordGroupsAndSubgroupsInFeed {
        guard let value = Bumper.value(for: SuperKeywordGroupsAndSubgroupsInFeed.key) else { return .control }
        return SuperKeywordGroupsAndSubgroupsInFeed(rawValue: value) ?? .control 
    } 
}


enum WebsocketChat: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return WebsocketChat.no.rawValue }
    static var enumValues: [WebsocketChat] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New Websocket Chat" } 
    var asBool: Bool { return self == .yes }
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

enum CaptchaTransparent: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return CaptchaTransparent.no.rawValue }
    static var enumValues: [CaptchaTransparent] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Captcha transparent" } 
    var asBool: Bool { return self == .yes }
}

enum NewCarsMultiRequesterEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return NewCarsMultiRequesterEnabled.no.rawValue }
    static var enumValues: [NewCarsMultiRequesterEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Cars multi requester enabled" } 
    var asBool: Bool { return self == .yes }
}

enum InAppRatingIOS10: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return InAppRatingIOS10.no.rawValue }
    static var enumValues: [InAppRatingIOS10] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New in-app rating for iOS 10.3+" } 
    var asBool: Bool { return self == .yes }
}

enum AddSuperKeywordsOnFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AddSuperKeywordsOnFeed.control.rawValue }
    static var enumValues: [AddSuperKeywordsOnFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Add super keywords in feed and filters" } 
    static func fromPosition(_ position: Int) -> AddSuperKeywordsOnFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum TweaksCarPostingFlow: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return TweaksCarPostingFlow.control.rawValue }
    static var enumValues: [TweaksCarPostingFlow] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "car posting summary only at the end" } 
    static func fromPosition(_ position: Int) -> TweaksCarPostingFlow {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
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

enum AppRatingDialogInactive: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return AppRatingDialogInactive.no.rawValue }
    static var enumValues: [AppRatingDialogInactive] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "App rating dialog inactive to increase user activation" } 
    var asBool: Bool { return self == .yes }
}

enum ExpandableCategorySelectionMenu: String, BumperFeature  {
    case control, baseline, expandableMenu
    static var defaultValue: String { return ExpandableCategorySelectionMenu.control.rawValue }
    static var enumValues: [ExpandableCategorySelectionMenu] { return [.control, .baseline, .expandableMenu]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show 'salchichas' menu on sell your stuff button" } 
    static func fromPosition(_ position: Int) -> ExpandableCategorySelectionMenu {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .expandableMenu
            default: return .control
        }
    }
}

enum LocationDataSourceEndpoint: String, BumperFeature  {
    case control, baseline, appleWithRegion, niordWithRegion
    static var defaultValue: String { return LocationDataSourceEndpoint.control.rawValue }
    static var enumValues: [LocationDataSourceEndpoint] { return [.control, .baseline, .appleWithRegion, .niordWithRegion]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Location data source for geocode and reverse geocode" } 
    static func fromPosition(_ position: Int) -> LocationDataSourceEndpoint {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .appleWithRegion
            case 3: return .niordWithRegion
            default: return .control
        }
    }
}

enum DefaultRadiusDistanceFeed: String, BumperFeature  {
    case control, baseline, two, five, ten, thirty
    static var defaultValue: String { return DefaultRadiusDistanceFeed.control.rawValue }
    static var enumValues: [DefaultRadiusDistanceFeed] { return [.control, .baseline, .two, .five, .ten, .thirty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Default distance radius main feed." } 
    static func fromPosition(_ position: Int) -> DefaultRadiusDistanceFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .two
            case 3: return .five
            case 4: return .ten
            case 5: return .thirty
            default: return .control
        }
    }
}

enum RealEstateEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return RealEstateEnabled.no.rawValue }
    static var enumValues: [RealEstateEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Allow to see Real Estate category" } 
    var asBool: Bool { return self == .yes }
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

enum NewCarouselTapNextPhotoNavigationEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NewCarouselTapNextPhotoNavigationEnabled.control.rawValue }
    static var enumValues: [NewCarouselTapNextPhotoNavigationEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New carousel on tap displays different photo from same product" } 
    static func fromPosition(_ position: Int) -> NewCarouselTapNextPhotoNavigationEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowPriceAfterSearchOrFilter: String, BumperFeature  {
    case control, baseline, priceOnSearchOrFilter
    static var defaultValue: String { return ShowPriceAfterSearchOrFilter.control.rawValue }
    static var enumValues: [ShowPriceAfterSearchOrFilter] { return [.control, .baseline, .priceOnSearchOrFilter]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show price in feed products when user applies any search or filter" } 
    static func fromPosition(_ position: Int) -> ShowPriceAfterSearchOrFilter {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .priceOnSearchOrFilter
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

enum NewBumpUpExplanation: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NewBumpUpExplanation.control.rawValue }
    static var enumValues: [NewBumpUpExplanation] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show new bump up explanation view" } 
    static func fromPosition(_ position: Int) -> NewBumpUpExplanation {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum HomeRelatedEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return HomeRelatedEnabled.control.rawValue }
    static var enumValues: [HomeRelatedEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show the related button in the main feed" } 
    static func fromPosition(_ position: Int) -> HomeRelatedEnabled {
    switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}
          
enum HideChatButtonOnFeaturedCells: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return HideChatButtonOnFeaturedCells.control.rawValue }
    static var enumValues: [HideChatButtonOnFeaturedCells] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "hide chat button on the featured listing cells" } 
    static func fromPosition(_ position: Int) -> HideChatButtonOnFeaturedCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SuperKeywordGroupsAndSubgroupsInFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SuperKeywordGroupsAndSubgroupsInFeed.control.rawValue }
    static var enumValues: [SuperKeywordGroupsAndSubgroupsInFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Super keywords groups and subgroups in feed as bubble filters" } 
    static func fromPosition(_ position: Int) -> SuperKeywordGroupsAndSubgroupsInFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

