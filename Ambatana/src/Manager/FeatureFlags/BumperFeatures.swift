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
        Bumper.initialize([WebsocketChat.self, NotificationsSection.self, UserReviews.self, ShowNPSSurvey.self, InterestedUsersMode.self, ProductDetailShareMode.self, ExpressChatBanner.self, PostAfterDeleteMode.self, KeywordsTravelCollection.self, RelatedProductsOnMoreInfo.self, ShareAfterPosting.self, MonetizationEnabled.self, PeriscopeImprovement.self, FavoriteWithBadgeOnProfile.self, NewQuickAnswers.self, PostingMultiPictureEnabled.self, FavoriteWithBubbleToChat.self, CaptchaTransparent.self, PassiveBuyersShowKeyboard.self, FilterIconWithLetters.self])
    } 

    static var websocketChat: Bool {
        guard let value = Bumper.value(for: WebsocketChat.key) else { return false }
        return WebsocketChat(rawValue: value)?.asBool ?? false
    }

    static var notificationsSection: Bool {
        guard let value = Bumper.value(for: NotificationsSection.key) else { return true }
        return NotificationsSection(rawValue: value)?.asBool ?? true
    }

    static var userReviews: Bool {
        guard let value = Bumper.value(for: UserReviews.key) else { return true }
        return UserReviews(rawValue: value)?.asBool ?? true
    }

    static var showNPSSurvey: Bool {
        guard let value = Bumper.value(for: ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    }

    static var interestedUsersMode: InterestedUsersMode {
        guard let value = Bumper.value(for: InterestedUsersMode.key) else { return .noNotification }
        return InterestedUsersMode(rawValue: value) ?? .noNotification 
    }

    static var productDetailShareMode: ProductDetailShareMode {
        guard let value = Bumper.value(for: ProductDetailShareMode.key) else { return .native }
        return ProductDetailShareMode(rawValue: value) ?? .native 
    }

    static var expressChatBanner: Bool {
        guard let value = Bumper.value(for: ExpressChatBanner.key) else { return false }
        return ExpressChatBanner(rawValue: value)?.asBool ?? false
    }

    static var postAfterDeleteMode: PostAfterDeleteMode {
        guard let value = Bumper.value(for: PostAfterDeleteMode.key) else { return .original }
        return PostAfterDeleteMode(rawValue: value) ?? .original 
    }

    static var keywordsTravelCollection: KeywordsTravelCollection {
        guard let value = Bumper.value(for: KeywordsTravelCollection.key) else { return .standard }
        return KeywordsTravelCollection(rawValue: value) ?? .standard 
    }

    static var relatedProductsOnMoreInfo: Bool {
        guard let value = Bumper.value(for: RelatedProductsOnMoreInfo.key) else { return false }
        return RelatedProductsOnMoreInfo(rawValue: value)?.asBool ?? false
    }

    static var shareAfterPosting: Bool {
        guard let value = Bumper.value(for: ShareAfterPosting.key) else { return false }
        return ShareAfterPosting(rawValue: value)?.asBool ?? false
    }

    static var monetizationEnabled: Bool {
        guard let value = Bumper.value(for: MonetizationEnabled.key) else { return false }
        return MonetizationEnabled(rawValue: value)?.asBool ?? false
    }

    static var periscopeImprovement: Bool {
        guard let value = Bumper.value(for: PeriscopeImprovement.key) else { return false }
        return PeriscopeImprovement(rawValue: value)?.asBool ?? false
    }

    static var favoriteWithBadgeOnProfile: Bool {
        guard let value = Bumper.value(for: FavoriteWithBadgeOnProfile.key) else { return false }
        return FavoriteWithBadgeOnProfile(rawValue: value)?.asBool ?? false
    }

    static var newQuickAnswers: Bool {
        guard let value = Bumper.value(for: NewQuickAnswers.key) else { return false }
        return NewQuickAnswers(rawValue: value)?.asBool ?? false
    }

    static var postingMultiPictureEnabled: Bool {
        guard let value = Bumper.value(for: PostingMultiPictureEnabled.key) else { return false }
        return PostingMultiPictureEnabled(rawValue: value)?.asBool ?? false
    }

    static var favoriteWithBubbleToChat: Bool {
        guard let value = Bumper.value(for: FavoriteWithBubbleToChat.key) else { return false }
        return FavoriteWithBubbleToChat(rawValue: value)?.asBool ?? false
    }

    static var captchaTransparent: Bool {
        guard let value = Bumper.value(for: CaptchaTransparent.key) else { return false }
        return CaptchaTransparent(rawValue: value)?.asBool ?? false
    }

    static var passiveBuyersShowKeyboard: Bool {
        guard let value = Bumper.value(for: PassiveBuyersShowKeyboard.key) else { return false }
        return PassiveBuyersShowKeyboard(rawValue: value)?.asBool ?? false
    }

    static var filterIconWithLetters: Bool {
        guard let value = Bumper.value(for: FilterIconWithLetters.key) else { return false }
        return FilterIconWithLetters(rawValue: value)?.asBool ?? false
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

enum NotificationsSection: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return NotificationsSection.yes.rawValue }
    static var enumValues: [NotificationsSection] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Notifications Section" } 
    var asBool: Bool { return self == .yes }
}

enum UserReviews: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return UserReviews.yes.rawValue }
    static var enumValues: [UserReviews] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User Reviews Feature" } 
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

enum InterestedUsersMode: String, BumperFeature  {
    case noNotification, original, limitedPrints
    static var defaultValue: String { return InterestedUsersMode.noNotification.rawValue }
    static var enumValues: [InterestedUsersMode] { return [.noNotification, .original, .limitedPrints]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Interested users bubble mode" } 
    static func fromPosition(_ position: Int) -> InterestedUsersMode {
        switch position { 
            case 0: return .noNotification
            case 1: return .original
            case 2: return .limitedPrints
            default: return .noNotification
        }
    }
}

enum ProductDetailShareMode: String, BumperFeature  {
    case native, inPlace, fullScreen
    static var defaultValue: String { return ProductDetailShareMode.native.rawValue }
    static var enumValues: [ProductDetailShareMode] { return [.native, .inPlace, .fullScreen]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "How the share options are presented in product detail" } 
    static func fromPosition(_ position: Int) -> ProductDetailShareMode {
        switch position { 
            case 0: return .native
            case 1: return .inPlace
            case 2: return .fullScreen
            default: return .native
        }
    }
}

enum ExpressChatBanner: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ExpressChatBanner.no.rawValue }
    static var enumValues: [ExpressChatBanner] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show express chat banner in chat detail" } 
    var asBool: Bool { return self == .yes }
}

enum PostAfterDeleteMode: String, BumperFeature  {
    case original, fullScreen, alert
    static var defaultValue: String { return PostAfterDeleteMode.original.rawValue }
    static var enumValues: [PostAfterDeleteMode] { return [.original, .fullScreen, .alert]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Posting incentivation after delete" } 
    static func fromPosition(_ position: Int) -> PostAfterDeleteMode {
        switch position { 
            case 0: return .original
            case 1: return .fullScreen
            case 2: return .alert
            default: return .original
        }
    }
}

enum KeywordsTravelCollection: String, BumperFeature  {
    case standard, carsPrior, brandsPrior
    static var defaultValue: String { return KeywordsTravelCollection.standard.rawValue }
    static var enumValues: [KeywordsTravelCollection] { return [.standard, .carsPrior, .brandsPrior]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Keywords prioritize on Travel Collection" } 
    static func fromPosition(_ position: Int) -> KeywordsTravelCollection {
        switch position { 
            case 0: return .standard
            case 1: return .carsPrior
            case 2: return .brandsPrior
            default: return .standard
        }
    }
}

enum RelatedProductsOnMoreInfo: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return RelatedProductsOnMoreInfo.no.rawValue }
    static var enumValues: [RelatedProductsOnMoreInfo] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Related Products on More Info" } 
    var asBool: Bool { return self == .yes }
}

enum ShareAfterPosting: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShareAfterPosting.no.rawValue }
    static var enumValues: [ShareAfterPosting] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show sharing screen after posting (forced)" } 
    var asBool: Bool { return self == .yes }
}

enum MonetizationEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return MonetizationEnabled.no.rawValue }
    static var enumValues: [MonetizationEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "USer can make in-app purchases" } 
    var asBool: Bool { return self == .yes }
}

enum PeriscopeImprovement: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PeriscopeImprovement.no.rawValue }
    static var enumValues: [PeriscopeImprovement] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "periscope chat improvements" } 
    var asBool: Bool { return self == .yes }
}

enum FavoriteWithBadgeOnProfile: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FavoriteWithBadgeOnProfile.no.rawValue }
    static var enumValues: [FavoriteWithBadgeOnProfile] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Badge on profile when favorite" } 
    var asBool: Bool { return self == .yes }
}

enum NewQuickAnswers: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return NewQuickAnswers.no.rawValue }
    static var enumValues: [NewQuickAnswers] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Use quick answers v2" } 
    var asBool: Bool { return self == .yes }
}

enum PostingMultiPictureEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PostingMultiPictureEnabled.no.rawValue }
    static var enumValues: [PostingMultiPictureEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Posting multi picture enabled" } 
    var asBool: Bool { return self == .yes }
}

enum FavoriteWithBubbleToChat: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FavoriteWithBubbleToChat.no.rawValue }
    static var enumValues: [FavoriteWithBubbleToChat] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Bubble to chat when favorite" } 
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

enum PassiveBuyersShowKeyboard: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PassiveBuyersShowKeyboard.no.rawValue }
    static var enumValues: [PassiveBuyersShowKeyboard] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Passive buyers products suggested notification opens product with keyboard opened" } 
    var asBool: Bool { return self == .yes }
}

enum FilterIconWithLetters: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FilterIconWithLetters.no.rawValue }
    static var enumValues: [FilterIconWithLetters] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show filter icon as 'FILTERS'" } 
    var asBool: Bool { return self == .yes }
}

