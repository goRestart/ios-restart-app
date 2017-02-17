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
        Bumper.initialize([WebsocketChat.self, UserReviews.self, ShowNPSSurvey.self, PostAfterDeleteMode.self, FreeBumpUpEnabled.self, PricedBumpUpEnabled.self, FavoriteWithBadgeOnProfile.self, CaptchaTransparent.self, PassiveBuyersShowKeyboard.self, EditDeleteItemUxImprovement.self, OnboardingReview.self, BumpUpFreeTimeLimit.self, UserRatingMarkAsSold.self, SignUpLoginImprovement.self])
    } 

    static var websocketChat: Bool {
        guard let value = Bumper.value(for: WebsocketChat.key) else { return false }
        return WebsocketChat(rawValue: value)?.asBool ?? false
    }

    static var userReviews: Bool {
        guard let value = Bumper.value(for: UserReviews.key) else { return true }
        return UserReviews(rawValue: value)?.asBool ?? true
    }

    static var showNPSSurvey: Bool {
        guard let value = Bumper.value(for: ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    }

    static var postAfterDeleteMode: PostAfterDeleteMode {
        guard let value = Bumper.value(for: PostAfterDeleteMode.key) else { return .original }
        return PostAfterDeleteMode(rawValue: value) ?? .original 
    }

    static var freeBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: FreeBumpUpEnabled.key) else { return false }
        return FreeBumpUpEnabled(rawValue: value)?.asBool ?? false
    }

    static var pricedBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: PricedBumpUpEnabled.key) else { return false }
        return PricedBumpUpEnabled(rawValue: value)?.asBool ?? false
    }

    static var favoriteWithBadgeOnProfile: Bool {
        guard let value = Bumper.value(for: FavoriteWithBadgeOnProfile.key) else { return false }
        return FavoriteWithBadgeOnProfile(rawValue: value)?.asBool ?? false
    }

    static var captchaTransparent: Bool {
        guard let value = Bumper.value(for: CaptchaTransparent.key) else { return false }
        return CaptchaTransparent(rawValue: value)?.asBool ?? false
    }

    static var passiveBuyersShowKeyboard: Bool {
        guard let value = Bumper.value(for: PassiveBuyersShowKeyboard.key) else { return false }
        return PassiveBuyersShowKeyboard(rawValue: value)?.asBool ?? false
    }

    static var editDeleteItemUxImprovement: Bool {
        guard let value = Bumper.value(for: EditDeleteItemUxImprovement.key) else { return false }
        return EditDeleteItemUxImprovement(rawValue: value)?.asBool ?? false
    }

    static var onboardingReview: OnboardingReview {
        guard let value = Bumper.value(for: OnboardingReview.key) else { return .testA }
        return OnboardingReview(rawValue: value) ?? .testA 
    }

    static var bumpUpFreeTimeLimit: BumpUpFreeTimeLimit {
        guard let value = Bumper.value(for: BumpUpFreeTimeLimit.key) else { return .oneMin }
        return BumpUpFreeTimeLimit(rawValue: value) ?? .oneMin 
    }

    static var userRatingMarkAsSold: Bool {
        guard let value = Bumper.value(for: UserRatingMarkAsSold.key) else { return false }
        return UserRatingMarkAsSold(rawValue: value)?.asBool ?? false
    }

    static var signUpLoginImprovement: SignUpLoginImprovement {
        guard let value = Bumper.value(for: SignUpLoginImprovement.key) else { return .v1 }
        return SignUpLoginImprovement(rawValue: value) ?? .v1 
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

enum FavoriteWithBadgeOnProfile: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FavoriteWithBadgeOnProfile.no.rawValue }
    static var enumValues: [FavoriteWithBadgeOnProfile] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Badge on profile when favorite" } 
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

enum EditDeleteItemUxImprovement: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return EditDeleteItemUxImprovement.no.rawValue }
    static var enumValues: [EditDeleteItemUxImprovement] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Edit & Delete item UX improvements" } 
    var asBool: Bool { return self == .yes }
}

enum OnboardingReview: String, BumperFeature  {
    case testA, testB, testC, testD
    static var defaultValue: String { return OnboardingReview.testA.rawValue }
    static var enumValues: [OnboardingReview] { return [.testA, .testB, .testC, .testD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Onboarding Review A/B/C/D" } 
    static func fromPosition(_ position: Int) -> OnboardingReview {
        switch position { 
            case 0: return .testA
            case 1: return .testB
            case 2: return .testC
            case 3: return .testD
            default: return .testA
        }
    }
}

enum BumpUpFreeTimeLimit: String, BumperFeature  {
    case oneMin, eightHours, twelveHours, twentyFourHours
    static var defaultValue: String { return BumpUpFreeTimeLimit.oneMin.rawValue }
    static var enumValues: [BumpUpFreeTimeLimit] { return [.oneMin, .eightHours, .twelveHours, .twentyFourHours]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Time to next bump up" } 
    static func fromPosition(_ position: Int) -> BumpUpFreeTimeLimit {
        switch position { 
            case 0: return .oneMin
            case 1: return .eightHours
            case 2: return .twelveHours
            case 3: return .twentyFourHours
            default: return .oneMin
        }
    }
}

enum UserRatingMarkAsSold: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return UserRatingMarkAsSold.no.rawValue }
    static var enumValues: [UserRatingMarkAsSold] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Select buyer before mark sold" } 
    var asBool: Bool { return self == .yes }
}

enum SignUpLoginImprovement: String, BumperFeature  {
    case v1, v1WImprovements, v2
    static var defaultValue: String { return SignUpLoginImprovement.v1.rawValue }
    static var enumValues: [SignUpLoginImprovement] { return [.v1, .v1WImprovements, .v2]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "SignUp LogIn A/B/C" } 
    static func fromPosition(_ position: Int) -> SignUpLoginImprovement {
        switch position { 
            case 0: return .v1
            case 1: return .v1WImprovements
            case 2: return .v2
            default: return .v1
        }
    }
}

