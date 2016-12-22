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
        Bumper.initialize([WebsocketChat.self, NotificationsSection.self, UserReviews.self, ShowNPSSurvey.self, InterestedUsersMode.self, ShareButtonWithIcon.self, ProductDetailShareMode.self, ExpressChatBanner.self, PostAfterDeleteMode.self, KeywordsTravelCollection.self, RelatedProductsOnMoreInfo.self, ShareAfterPosting.self, PeriscopeImprovement.self, FavoriteWithBadgeOnProfile.self, NewQuickAnswers.self, PostingMultiPictureEnabled.self, FavoriteWithBubbleToChat.self])
    } 

    static var websocketChat: Bool {
        guard let value = Bumper.valueForKey(WebsocketChat.key) else { return false }
        return WebsocketChat(rawValue: value)?.asBool ?? false
    }

    static var notificationsSection: Bool {
        guard let value = Bumper.valueForKey(NotificationsSection.key) else { return true }
        return NotificationsSection(rawValue: value)?.asBool ?? true
    }

    static var userReviews: Bool {
        guard let value = Bumper.valueForKey(UserReviews.key) else { return true }
        return UserReviews(rawValue: value)?.asBool ?? true
    }

    static var showNPSSurvey: Bool {
        guard let value = Bumper.valueForKey(ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    }

    static var interestedUsersMode: InterestedUsersMode {
        guard let value = Bumper.valueForKey(InterestedUsersMode.key) else { return .NoNotification }
        return InterestedUsersMode(rawValue: value) ?? .NoNotification 
    }

    static var shareButtonWithIcon: Bool {
        guard let value = Bumper.valueForKey(ShareButtonWithIcon.key) else { return true }
        return ShareButtonWithIcon(rawValue: value)?.asBool ?? true
    }

    static var productDetailShareMode: ProductDetailShareMode {
        guard let value = Bumper.valueForKey(ProductDetailShareMode.key) else { return .Native }
        return ProductDetailShareMode(rawValue: value) ?? .Native 
    }

    static var expressChatBanner: Bool {
        guard let value = Bumper.valueForKey(ExpressChatBanner.key) else { return false }
        return ExpressChatBanner(rawValue: value)?.asBool ?? false
    }

    static var postAfterDeleteMode: PostAfterDeleteMode {
        guard let value = Bumper.valueForKey(PostAfterDeleteMode.key) else { return .Original }
        return PostAfterDeleteMode(rawValue: value) ?? .Original 
    }

    static var keywordsTravelCollection: KeywordsTravelCollection {
        guard let value = Bumper.valueForKey(KeywordsTravelCollection.key) else { return .Standard }
        return KeywordsTravelCollection(rawValue: value) ?? .Standard 
    }

    static var relatedProductsOnMoreInfo: Bool {
        guard let value = Bumper.valueForKey(RelatedProductsOnMoreInfo.key) else { return false }
        return RelatedProductsOnMoreInfo(rawValue: value)?.asBool ?? false
    }

    static var shareAfterPosting: Bool {
        guard let value = Bumper.valueForKey(ShareAfterPosting.key) else { return false }
        return ShareAfterPosting(rawValue: value)?.asBool ?? false
    }

    static var periscopeImprovement: Bool {
        guard let value = Bumper.valueForKey(PeriscopeImprovement.key) else { return false }
        return PeriscopeImprovement(rawValue: value)?.asBool ?? false
    }

    static var favoriteWithBadgeOnProfile: Bool {
        guard let value = Bumper.valueForKey(FavoriteWithBadgeOnProfile.key) else { return false }
        return FavoriteWithBadgeOnProfile(rawValue: value)?.asBool ?? false
    }

    static var newQuickAnswers: Bool {
        guard let value = Bumper.valueForKey(NewQuickAnswers.key) else { return false }
        return NewQuickAnswers(rawValue: value)?.asBool ?? false
    }

    static var postingMultiPictureEnabled: Bool {
        guard let value = Bumper.valueForKey(PostingMultiPictureEnabled.key) else { return false }
        return PostingMultiPictureEnabled(rawValue: value)?.asBool ?? false
    }

    static var favoriteWithBubbleToChat: Bool {
        guard let value = Bumper.valueForKey(FavoriteWithBubbleToChat.key) else { return false }
        return FavoriteWithBubbleToChat(rawValue: value)?.asBool ?? false
    } 
}


enum WebsocketChat: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return WebsocketChat.No.rawValue }
    static var enumValues: [WebsocketChat] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New Websocket Chat" } 
    var asBool: Bool { return self == .Yes }
}

enum NotificationsSection: String, BumperFeature  {
    case Yes, No
    static var defaultValue: String { return NotificationsSection.Yes.rawValue }
    static var enumValues: [NotificationsSection] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Notifications Section" } 
    var asBool: Bool { return self == .Yes }
}

enum UserReviews: String, BumperFeature  {
    case Yes, No
    static var defaultValue: String { return UserReviews.Yes.rawValue }
    static var enumValues: [UserReviews] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User Reviews Feature" } 
    var asBool: Bool { return self == .Yes }
}

enum ShowNPSSurvey: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return ShowNPSSurvey.No.rawValue }
    static var enumValues: [ShowNPSSurvey] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show nps survey" } 
    var asBool: Bool { return self == .Yes }
}

enum InterestedUsersMode: String, BumperFeature  {
    case NoNotification, Original, LimitedPrints
    static var defaultValue: String { return InterestedUsersMode.NoNotification.rawValue }
    static var enumValues: [InterestedUsersMode] { return [.NoNotification, .Original, .LimitedPrints]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Interested users bubble mode" } 
    static func fromPosition(position: Int) -> InterestedUsersMode {
        switch position { 
            case 0: return .NoNotification
            case 1: return .Original
            case 2: return .LimitedPrints
            default: return .NoNotification
        }
    }
}

enum ShareButtonWithIcon: String, BumperFeature  {
    case Yes, No
    static var defaultValue: String { return ShareButtonWithIcon.Yes.rawValue }
    static var enumValues: [ShareButtonWithIcon] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Share button with an icon" } 
    var asBool: Bool { return self == .Yes }
}

enum ProductDetailShareMode: String, BumperFeature  {
    case Native, InPlace, FullScreen
    static var defaultValue: String { return ProductDetailShareMode.Native.rawValue }
    static var enumValues: [ProductDetailShareMode] { return [.Native, .InPlace, .FullScreen]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "How the share options are presented in product detail" } 
    static func fromPosition(position: Int) -> ProductDetailShareMode {
        switch position { 
            case 0: return .Native
            case 1: return .InPlace
            case 2: return .FullScreen
            default: return .Native
        }
    }
}

enum ExpressChatBanner: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return ExpressChatBanner.No.rawValue }
    static var enumValues: [ExpressChatBanner] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show express chat banner in chat detail" } 
    var asBool: Bool { return self == .Yes }
}

enum PostAfterDeleteMode: String, BumperFeature  {
    case Original, FullScreen, Alert
    static var defaultValue: String { return PostAfterDeleteMode.Original.rawValue }
    static var enumValues: [PostAfterDeleteMode] { return [.Original, .FullScreen, .Alert]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Posting incentivation after delete" } 
    static func fromPosition(position: Int) -> PostAfterDeleteMode {
        switch position { 
            case 0: return .Original
            case 1: return .FullScreen
            case 2: return .Alert
            default: return .Original
        }
    }
}

enum KeywordsTravelCollection: String, BumperFeature  {
    case Standard, CarsPrior, BrandsPrior
    static var defaultValue: String { return KeywordsTravelCollection.Standard.rawValue }
    static var enumValues: [KeywordsTravelCollection] { return [.Standard, .CarsPrior, .BrandsPrior]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Keywords prioritize on Travel Collection" } 
    static func fromPosition(position: Int) -> KeywordsTravelCollection {
        switch position { 
            case 0: return .Standard
            case 1: return .CarsPrior
            case 2: return .BrandsPrior
            default: return .Standard
        }
    }
}

enum RelatedProductsOnMoreInfo: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return RelatedProductsOnMoreInfo.No.rawValue }
    static var enumValues: [RelatedProductsOnMoreInfo] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Related Products on More Info" } 
    var asBool: Bool { return self == .Yes }
}

enum ShareAfterPosting: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return ShareAfterPosting.No.rawValue }
    static var enumValues: [ShareAfterPosting] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show sharing screen after posting (forced)" } 
    var asBool: Bool { return self == .Yes }
}

enum PeriscopeImprovement: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return PeriscopeImprovement.No.rawValue }
    static var enumValues: [PeriscopeImprovement] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "periscope chat improvements" } 
    var asBool: Bool { return self == .Yes }
}

enum FavoriteWithBadgeOnProfile: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return FavoriteWithBadgeOnProfile.No.rawValue }
    static var enumValues: [FavoriteWithBadgeOnProfile] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Badge on profile when favorite" } 
    var asBool: Bool { return self == .Yes }
}

enum NewQuickAnswers: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return NewQuickAnswers.No.rawValue }
    static var enumValues: [NewQuickAnswers] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Use quick answers v2" } 
    var asBool: Bool { return self == .Yes }
}

enum PostingMultiPictureEnabled: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return PostingMultiPictureEnabled.No.rawValue }
    static var enumValues: [PostingMultiPictureEnabled] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Posting multi picture enabled" } 
    var asBool: Bool { return self == .Yes }
}

enum FavoriteWithBubbleToChat: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return FavoriteWithBubbleToChat.No.rawValue }
    static var enumValues: [FavoriteWithBubbleToChat] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Bubble to chat when favorite" } 
    var asBool: Bool { return self == .Yes }
}

