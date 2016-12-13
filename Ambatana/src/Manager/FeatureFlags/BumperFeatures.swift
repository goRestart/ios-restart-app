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
        Bumper.initialize([WebsocketChat.self, NotificationsSection.self, UserReviews.self, ShowNPSSurvey.self, MessageOnFavoriteRound2Mode.self, InterestedUsersMode.self, FiltersReorder.self, DirectPostInOnboarding.self, ShareButtonWithIcon.self, ProductDetailShareMode.self, ChatHeadBubbles.self, SaveMailLogout.self, ExpressChatBanner.self, ShowLiquidProductsToNewUser.self, PostAfterDeleteMode.self, KeywordsTravelCollection.self, CommercializerAfterPosting.self, RelatedProductsOnMoreInfo.self, ShareAfterPosting.self, PostingMultiPictureEnabled.self, PeriscopeImprovement.self, NewQuickAnswers.self])
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

    static var messageOnFavoriteRound2Mode: MessageOnFavoriteRound2Mode {
        guard let value = Bumper.valueForKey(MessageOnFavoriteRound2Mode.key) else { return .NoMessage }
        return MessageOnFavoriteRound2Mode(rawValue: value) ?? .NoMessage 
    }

    static var interestedUsersMode: InterestedUsersMode {
        guard let value = Bumper.valueForKey(InterestedUsersMode.key) else { return .NoNotification }
        return InterestedUsersMode(rawValue: value) ?? .NoNotification 
    }

    static var filtersReorder: Bool {
        guard let value = Bumper.valueForKey(FiltersReorder.key) else { return false }
        return FiltersReorder(rawValue: value)?.asBool ?? false
    }

    static var directPostInOnboarding: Bool {
        guard let value = Bumper.valueForKey(DirectPostInOnboarding.key) else { return false }
        return DirectPostInOnboarding(rawValue: value)?.asBool ?? false
    }

    static var shareButtonWithIcon: Bool {
        guard let value = Bumper.valueForKey(ShareButtonWithIcon.key) else { return true }
        return ShareButtonWithIcon(rawValue: value)?.asBool ?? true
    }

    static var productDetailShareMode: ProductDetailShareMode {
        guard let value = Bumper.valueForKey(ProductDetailShareMode.key) else { return .Native }
        return ProductDetailShareMode(rawValue: value) ?? .Native 
    }

    static var chatHeadBubbles: Bool {
        guard let value = Bumper.valueForKey(ChatHeadBubbles.key) else { return false }
        return ChatHeadBubbles(rawValue: value)?.asBool ?? false
    }

    static var saveMailLogout: Bool {
        guard let value = Bumper.valueForKey(SaveMailLogout.key) else { return false }
        return SaveMailLogout(rawValue: value)?.asBool ?? false
    }

    static var expressChatBanner: Bool {
        guard let value = Bumper.valueForKey(ExpressChatBanner.key) else { return false }
        return ExpressChatBanner(rawValue: value)?.asBool ?? false
    }

    static var showLiquidProductsToNewUser: Bool {
        guard let value = Bumper.valueForKey(ShowLiquidProductsToNewUser.key) else { return false }
        return ShowLiquidProductsToNewUser(rawValue: value)?.asBool ?? false
    }

    static var postAfterDeleteMode: PostAfterDeleteMode {
        guard let value = Bumper.valueForKey(PostAfterDeleteMode.key) else { return .Original }
        return PostAfterDeleteMode(rawValue: value) ?? .Original 
    }

    static var keywordsTravelCollection: KeywordsTravelCollection {
        guard let value = Bumper.valueForKey(KeywordsTravelCollection.key) else { return .Standard }
        return KeywordsTravelCollection(rawValue: value) ?? .Standard 
    }

    static var commercializerAfterPosting: Bool {
        guard let value = Bumper.valueForKey(CommercializerAfterPosting.key) else { return false }
        return CommercializerAfterPosting(rawValue: value)?.asBool ?? false
    }

    static var relatedProductsOnMoreInfo: Bool {
        guard let value = Bumper.valueForKey(RelatedProductsOnMoreInfo.key) else { return false }
        return RelatedProductsOnMoreInfo(rawValue: value)?.asBool ?? false
    }

    static var shareAfterPosting: Bool {
        guard let value = Bumper.valueForKey(ShareAfterPosting.key) else { return false }
        return ShareAfterPosting(rawValue: value)?.asBool ?? false
    }

    static var postingMultiPictureEnabled: Bool {
        guard let value = Bumper.valueForKey(PostingMultiPictureEnabled.key) else { return false }
        return PostingMultiPictureEnabled(rawValue: value)?.asBool ?? false
    }

    static var periscopeImprovement: Bool {
        guard let value = Bumper.valueForKey(PeriscopeImprovement.key) else { return false }
        return PeriscopeImprovement(rawValue: value)?.asBool ?? false
    }

    static var newQuickAnswers: Bool {
        guard let value = Bumper.valueForKey(NewQuickAnswers.key) else { return false }
        return NewQuickAnswers(rawValue: value)?.asBool ?? false
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

enum MessageOnFavoriteRound2Mode: String, BumperFeature  {
    case NoMessage, DirectMessage
    static var defaultValue: String { return MessageOnFavoriteRound2Mode.NoMessage.rawValue }
    static var enumValues: [MessageOnFavoriteRound2Mode] { return [.NoMessage, .DirectMessage]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Message after favorite: The Return" } 
    static func fromPosition(position: Int) -> MessageOnFavoriteRound2Mode {
        switch position { 
            case 0: return .NoMessage
            case 1: return .DirectMessage
            default: return .NoMessage
        }
    }
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

enum FiltersReorder: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return FiltersReorder.No.rawValue }
    static var enumValues: [FiltersReorder] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Product filters reorder" } 
    var asBool: Bool { return self == .Yes }
}

enum DirectPostInOnboarding: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return DirectPostInOnboarding.No.rawValue }
    static var enumValues: [DirectPostInOnboarding] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Last Onboarding step opens the camera" } 
    var asBool: Bool { return self == .Yes }
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

enum ChatHeadBubbles: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return ChatHeadBubbles.No.rawValue }
    static var enumValues: [ChatHeadBubbles] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Chat head bubbles" } 
    var asBool: Bool { return self == .Yes }
}

enum SaveMailLogout: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return SaveMailLogout.No.rawValue }
    static var enumValues: [SaveMailLogout] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Remembers email or FB/Google username on logout" } 
    var asBool: Bool { return self == .Yes }
}

enum ExpressChatBanner: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return ExpressChatBanner.No.rawValue }
    static var enumValues: [ExpressChatBanner] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show express chat banner in chat detail" } 
    var asBool: Bool { return self == .Yes }
}

enum ShowLiquidProductsToNewUser: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return ShowLiquidProductsToNewUser.No.rawValue }
    static var enumValues: [ShowLiquidProductsToNewUser] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show liquid products to new user" } 
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

enum CommercializerAfterPosting: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return CommercializerAfterPosting.No.rawValue }
    static var enumValues: [CommercializerAfterPosting] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Commercializer after posting" } 
    var asBool: Bool { return self == .Yes }
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

enum PostingMultiPictureEnabled: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return PostingMultiPictureEnabled.No.rawValue }
    static var enumValues: [PostingMultiPictureEnabled] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Posting multi picture enabled" } 
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

enum NewQuickAnswers: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return NewQuickAnswers.No.rawValue }
    static var enumValues: [NewQuickAnswers] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Use quick answers v2" } 
    var asBool: Bool { return self == .Yes }
}

