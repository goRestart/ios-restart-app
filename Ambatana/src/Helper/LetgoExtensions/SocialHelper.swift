//
//  SocialHelper.swift
//  LetGo
//
//  Created by AHL on 16/8/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import TwitterKit
import LGCoreKit
import MessageUI
import Branch


enum ShareType {
    case Email, Facebook, FBMessenger, Whatsapp, Twitter, Telegram, CopyLink, SMS, Native

    private static var otherCountriesTypes: [ShareType] { return [.SMS, .Email, .Facebook, .FBMessenger, .Twitter, .Whatsapp, .Telegram] }
    private static var turkeyTypes: [ShareType] { return [.Whatsapp, .Facebook, .Email ,.FBMessenger, .Twitter, .SMS, .Telegram] }

    var moreInfoTypes: [ShareType] {
        return ShareType.shareTypesForCountry("", maxButtons: nil, includeNative: false)
    }

    static func shareTypesForCountry(countryCode: String, maxButtons: Int?, includeNative: Bool) -> [ShareType] {
        let turkey = "tr"

        let countryTypes: [ShareType]
        switch countryCode {
        case turkey:
            countryTypes = turkeyTypes
        default:
            countryTypes = otherCountriesTypes
        }

        var resultShareTypes = countryTypes.filter { SocialSharer.canShareIn($0) }

        if var maxButtons = maxButtons where maxButtons > 0 {
            maxButtons = includeNative ? maxButtons-1 : maxButtons
            if resultShareTypes.count > maxButtons {
                resultShareTypes = Array(resultShareTypes[0..<maxButtons])
            }
        }

        if includeNative {
            resultShareTypes.append(.Native)
        }

        return resultShareTypes
    }

    var trackingShareNetwork: EventParameterShareNetwork {
        switch self {
        case .Email:
            return .Email
        case .FBMessenger:
            return .FBMessenger
        case .Whatsapp:
            return .Whatsapp
        case .Facebook:
            return .Facebook
        case .Twitter:
            return .Twitter
        case .Telegram:
            return .Telegram
        case .CopyLink:
            return .CopyLink
        case .SMS:
            return .SMS
        case .Native:
            return .Native
        }
    }
}
