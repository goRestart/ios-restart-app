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
        Bumper.initialize([WebsocketChat.self, NotificationsSection.self, UserRatings.self, ShowNPSSurvey.self, ProfileBuildTrustButton.self, NonStopProductDetail.self, OnboardingPermissionsMode.self, IncentivizePostingMode.self, MessageOnFavoriteMode.self, ExpressChatMode.self])
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

    static var profileBuildTrustButton: Bool {
        guard let value = Bumper.valueForKey(ProfileBuildTrustButton.key) else { return true }
        return ProfileBuildTrustButton(rawValue: value)?.asBool ?? true
    }

    static var nonStopProductDetail: Bool {
        guard let value = Bumper.valueForKey(NonStopProductDetail.key) else { return true }
        return NonStopProductDetail(rawValue: value)?.asBool ?? true
    }

    static var onboardingPermissionsMode: OnboardingPermissionsMode {
        guard let value = Bumper.valueForKey(OnboardingPermissionsMode.key) else { return .Original }
        return OnboardingPermissionsMode(rawValue: value) ?? .Original 
    }

    static var incentivizePostingMode: IncentivizePostingMode {
        guard let value = Bumper.valueForKey(IncentivizePostingMode.key) else { return .Original }
        return IncentivizePostingMode(rawValue: value) ?? .Original 
    }

    static var messageOnFavoriteMode: MessageOnFavoriteMode {
        guard let value = Bumper.valueForKey(MessageOnFavoriteMode.key) else { return .NoMessage }
        return MessageOnFavoriteMode(rawValue: value) ?? .NoMessage 
    }

    static var expressChatMode: ExpressChatMode {
        guard let value = Bumper.valueForKey(ExpressChatMode.key) else { return .NoChat }
        return ExpressChatMode(rawValue: value) ?? .NoChat 
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

enum ProfileBuildTrustButton: String, BumperFeature  {
    case Yes, No
    static var defaultValue: String { return ProfileBuildTrustButton.Yes.rawValue }
    static var enumValues: [ProfileBuildTrustButton] { return [.Yes, .No]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Profile Build trust" } 
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

enum IncentivizePostingMode: String, BumperFeature  {
    case Original, VariantA, VariantB, VariantC
    static var defaultValue: String { return IncentivizePostingMode.Original.rawValue }
    static var enumValues: [IncentivizePostingMode] { return [.Original, .VariantA, .VariantB, .VariantC]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Onboarding Posting" } 
    static func fromPosition(position: Int) -> IncentivizePostingMode {
        switch position { 
            case 0: return .Original
            case 1: return .VariantA
            case 2: return .VariantB
            case 3: return .VariantC
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

enum ExpressChatMode: String, BumperFeature  {
    case NoChat, ContactXSellers, AskAvailable
    static var defaultValue: String { return ExpressChatMode.NoChat.rawValue }
    static var enumValues: [ExpressChatMode] { return [.NoChat, .ContactXSellers, .AskAvailable]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Express Chat Message" } 
    static func fromPosition(position: Int) -> ExpressChatMode {
        switch position { 
            case 0: return .NoChat
            case 1: return .ContactXSellers
            case 2: return .AskAvailable
            default: return .NoChat
        }
    }
}

