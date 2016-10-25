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
        Bumper.initialize([WebsocketChat.self, NotificationsSection.self, UserRatings.self, ShowNPSSurvey.self, NonStopProductDetail.self, OnboardingPermissionsMode.self, MessageOnFavoriteMode.self, InterestedUsersMode.self, FiltersReorder.self, HalfCameraButton.self, FreePostingMode.self, DirectPostInOnboarding.self, ProductDetailShareMode.self])
    } 

    static var websocketChat: Bool {
        guard let value = Bumper.valueForKey(WebsocketChat.key) else { return false }
        return WebsocketChat(rawValue: value)?.asBool ?? false
    }

    static var notificationsSection: Bool {
        guard let value = Bumper.valueForKey(NotificationsSection.key) else { return false }
        return NotificationsSection(rawValue: value)?.asBool ?? false
    }

    static var userRatings: Bool {
        guard let value = Bumper.valueForKey(UserRatings.key) else { return false }
        return UserRatings(rawValue: value)?.asBool ?? false
    }

    static var showNPSSurvey: Bool {
        guard let value = Bumper.valueForKey(ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    }

    static var nonStopProductDetail: Bool {
        guard let value = Bumper.valueForKey(NonStopProductDetail.key) else { return true }
        return NonStopProductDetail(rawValue: value)?.asBool ?? true
    }

    static var onboardingPermissionsMode: OnboardingPermissionsMode {
        guard let value = Bumper.valueForKey(OnboardingPermissionsMode.key) else { return .Original }
        return OnboardingPermissionsMode(rawValue: value) ?? .Original 
    }

    static var messageOnFavoriteMode: MessageOnFavoriteMode {
        guard let value = Bumper.valueForKey(MessageOnFavoriteMode.key) else { return .NoMessage }
        return MessageOnFavoriteMode(rawValue: value) ?? .NoMessage 
    }

    static var interestedUsersMode: InterestedUsersMode {
        guard let value = Bumper.valueForKey(InterestedUsersMode.key) else { return .NoNotification }
        return InterestedUsersMode(rawValue: value) ?? .NoNotification 
    }

    static var filtersReorder: Bool {
        guard let value = Bumper.valueForKey(FiltersReorder.key) else { return false }
        return FiltersReorder(rawValue: value)?.asBool ?? false
    }

    static var halfCameraButton: Bool {
        guard let value = Bumper.valueForKey(HalfCameraButton.key) else { return true }
        return HalfCameraButton(rawValue: value)?.asBool ?? true
    }

    static var freePostingMode: FreePostingMode {
        guard let value = Bumper.valueForKey(FreePostingMode.key) else { return .Disabled }
        return FreePostingMode(rawValue: value) ?? .Disabled 
    }

    static var directPostInOnboarding: Bool {
        guard let value = Bumper.valueForKey(DirectPostInOnboarding.key) else { return false }
        return DirectPostInOnboarding(rawValue: value)?.asBool ?? false
    }

    static var productDetailShareMode: ProductDetailShareMode {
        guard let value = Bumper.valueForKey(ProductDetailShareMode.key) else { return .Native }
        return ProductDetailShareMode(rawValue: value) ?? .Native 
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
    case No, Yes
    static var defaultValue: String { return NotificationsSection.No.rawValue }
    static var enumValues: [NotificationsSection] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Notifications Section" } 
    var asBool: Bool { return self == .Yes }
}

enum UserRatings: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return UserRatings.No.rawValue }
    static var enumValues: [UserRatings] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User Ratings" } 
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

enum NonStopProductDetail: String, BumperFeature  {
    case Yes, No
    static var defaultValue: String { return NonStopProductDetail.Yes.rawValue }
    static var enumValues: [NonStopProductDetail] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Non stop prod detail" } 
    var asBool: Bool { return self == .Yes }
}

enum OnboardingPermissionsMode: String, BumperFeature  {
    case Original, OneButtonOriginalImages, OneButtonNewImages
    static var defaultValue: String { return OnboardingPermissionsMode.Original.rawValue }
    static var enumValues: [OnboardingPermissionsMode] { return [.Original, .OneButtonOriginalImages, .OneButtonNewImages]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Onboarding permissions" } 
    static func fromPosition(position: Int) -> OnboardingPermissionsMode {
        switch position { 
            case 0: return .Original
            case 1: return .OneButtonOriginalImages
            case 2: return .OneButtonNewImages
            default: return .Original
        }
    }
}

enum MessageOnFavoriteMode: String, BumperFeature  {
    case NoMessage, NotificationPreMessage, DirectMessage
    static var defaultValue: String { return MessageOnFavoriteMode.NoMessage.rawValue }
    static var enumValues: [MessageOnFavoriteMode] { return [.NoMessage, .NotificationPreMessage, .DirectMessage]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Message after favorite" } 
    static func fromPosition(position: Int) -> MessageOnFavoriteMode {
        switch position { 
            case 0: return .NoMessage
            case 1: return .NotificationPreMessage
            case 2: return .DirectMessage
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

enum HalfCameraButton: String, BumperFeature  {
    case Yes, No
    static var defaultValue: String { return HalfCameraButton.Yes.rawValue }
    static var enumValues: [HalfCameraButton] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Camera button cut in gallery" } 
    var asBool: Bool { return self == .Yes }
}

enum FreePostingMode: String, BumperFeature  {
    case Disabled, SplitButton, OneButton
    static var defaultValue: String { return FreePostingMode.Disabled.rawValue }
    static var enumValues: [FreePostingMode] { return [.Disabled, .SplitButton, .OneButton]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Free Posting Mode" } 
    static func fromPosition(position: Int) -> FreePostingMode {
        switch position { 
            case 0: return .Disabled
            case 1: return .SplitButton
            case 2: return .OneButton
            default: return .Disabled
        }
    }
}

enum DirectPostInOnboarding: String, BumperFeature  {
    case No, Yes
    static var defaultValue: String { return DirectPostInOnboarding.No.rawValue }
    static var enumValues: [DirectPostInOnboarding] { return [.No, .Yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Last Onboarding step opens the camera" } 
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

