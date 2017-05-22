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
        flags.append(UserReviews.self)
        flags.append(ShowNPSSurvey.self)
        flags.append(SurveyEnabled.self)
        flags.append(FreeBumpUpEnabled.self)
        flags.append(PricedBumpUpEnabled.self)
        flags.append(CaptchaTransparent.self)
        flags.append(PassiveBuyersShowKeyboard.self)
        flags.append(OnboardingReview.self)
        flags.append(ProductDetailNextRelated.self)
        flags.append(ContactSellerOnFavorite.self)
        flags.append(SignUpLoginImprovement.self)
        flags.append(PeriscopeRemovePredefinedText.self)
        flags.append(HideTabBarOnFirstSessionV2.self)
        flags.append(PostingGallery.self)
        flags.append(QuickAnswersRepeatedTextField.self)
        flags.append(CarsVerticalEnabled.self)
        flags.append(CarsCategoryAfterPicture.self)
        flags.append(NewMarkAsSoldFlow.self)
        Bumper.initialize(flags)
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

    static var passiveBuyersShowKeyboard: Bool {
        guard let value = Bumper.value(for: PassiveBuyersShowKeyboard.key) else { return false }
        return PassiveBuyersShowKeyboard(rawValue: value)?.asBool ?? false
    }

    static var onboardingReview: OnboardingReview {
        guard let value = Bumper.value(for: OnboardingReview.key) else { return .testA }
        return OnboardingReview(rawValue: value) ?? .testA 
    }

    static var productDetailNextRelated: Bool {
        guard let value = Bumper.value(for: ProductDetailNextRelated.key) else { return false }
        return ProductDetailNextRelated(rawValue: value)?.asBool ?? false
    }

    static var contactSellerOnFavorite: Bool {
        guard let value = Bumper.value(for: ContactSellerOnFavorite.key) else { return false }
        return ContactSellerOnFavorite(rawValue: value)?.asBool ?? false
    }

    static var signUpLoginImprovement: SignUpLoginImprovement {
        guard let value = Bumper.value(for: SignUpLoginImprovement.key) else { return .v1 }
        return SignUpLoginImprovement(rawValue: value) ?? .v1 
    }

    static var periscopeRemovePredefinedText: Bool {
        guard let value = Bumper.value(for: PeriscopeRemovePredefinedText.key) else { return false }
        return PeriscopeRemovePredefinedText(rawValue: value)?.asBool ?? false
    }

    static var hideTabBarOnFirstSessionV2: Bool {
        guard let value = Bumper.value(for: HideTabBarOnFirstSessionV2.key) else { return false }
        return HideTabBarOnFirstSessionV2(rawValue: value)?.asBool ?? false
    }

    static var postingGallery: PostingGallery {
        guard let value = Bumper.value(for: PostingGallery.key) else { return .singleSelection }
        return PostingGallery(rawValue: value) ?? .singleSelection 
    }

    static var quickAnswersRepeatedTextField: Bool {
        guard let value = Bumper.value(for: QuickAnswersRepeatedTextField.key) else { return false }
        return QuickAnswersRepeatedTextField(rawValue: value)?.asBool ?? false
    }

    static var carsVerticalEnabled: Bool {
        guard let value = Bumper.value(for: CarsVerticalEnabled.key) else { return false }
        return CarsVerticalEnabled(rawValue: value)?.asBool ?? false
    }

    static var carsCategoryAfterPicture: Bool {
        guard let value = Bumper.value(for: CarsCategoryAfterPicture.key) else { return false }
        return CarsCategoryAfterPicture(rawValue: value)?.asBool ?? false
    }

    static var newMarkAsSoldFlow: Bool {
        guard let value = Bumper.value(for: NewMarkAsSoldFlow.key) else { return false }
        return NewMarkAsSoldFlow(rawValue: value)?.asBool ?? false
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

enum PassiveBuyersShowKeyboard: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PassiveBuyersShowKeyboard.no.rawValue }
    static var enumValues: [PassiveBuyersShowKeyboard] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Passive buyers products suggested notification opens product with keyboard opened" } 
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

enum ProductDetailNextRelated: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ProductDetailNextRelated.no.rawValue }
    static var enumValues: [ProductDetailNextRelated] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Item page next item related" } 
    var asBool: Bool { return self == .yes }
}

enum ContactSellerOnFavorite: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ContactSellerOnFavorite.no.rawValue }
    static var enumValues: [ContactSellerOnFavorite] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Send a message when user clicks on contact the seller after favorite" } 
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

enum PeriscopeRemovePredefinedText: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PeriscopeRemovePredefinedText.no.rawValue }
    static var enumValues: [PeriscopeRemovePredefinedText] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Product detail remove chat text on tap" } 
    var asBool: Bool { return self == .yes }
}

enum HideTabBarOnFirstSessionV2: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return HideTabBarOnFirstSessionV2.no.rawValue }
    static var enumValues: [HideTabBarOnFirstSessionV2] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "hide tab bar with incentivise scroll banner v2" } 
    var asBool: Bool { return self == .yes }
}

enum PostingGallery: String, BumperFeature  {
    case singleSelection, multiSelection, multiSelectionWhiteButton, multiSelectionTabs, multiSelectionPostBottom
    static var defaultValue: String { return PostingGallery.singleSelection.rawValue }
    static var enumValues: [PostingGallery] { return [.singleSelection, .multiSelection, .multiSelectionWhiteButton, .multiSelectionTabs, .multiSelectionPostBottom]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Posting Gallery A/B/C/D/E" } 
    static func fromPosition(_ position: Int) -> PostingGallery {
        switch position { 
            case 0: return .singleSelection
            case 1: return .multiSelection
            case 2: return .multiSelectionWhiteButton
            case 3: return .multiSelectionTabs
            case 4: return .multiSelectionPostBottom
            default: return .singleSelection
        }
    }
}

enum QuickAnswersRepeatedTextField: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return QuickAnswersRepeatedTextField.no.rawValue }
    static var enumValues: [QuickAnswersRepeatedTextField] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Quick anwers periscope include the one as textfield placeholder" } 
    var asBool: Bool { return self == .yes }
}

enum CarsVerticalEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return CarsVerticalEnabled.no.rawValue }
    static var enumValues: [CarsVerticalEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Cars vertical enabled" } 
    var asBool: Bool { return self == .yes }
}

enum CarsCategoryAfterPicture: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return CarsCategoryAfterPicture.no.rawValue }
    static var enumValues: [CarsCategoryAfterPicture] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "When cars vertical enabled, select category after image selection" } 
    var asBool: Bool { return self == .yes }
}

enum NewMarkAsSoldFlow: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return NewMarkAsSoldFlow.no.rawValue }
    static var enumValues: [NewMarkAsSoldFlow] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New mark as sold flow active. alert + showing buyer list" } 
    var asBool: Bool { return self == .yes }
}

