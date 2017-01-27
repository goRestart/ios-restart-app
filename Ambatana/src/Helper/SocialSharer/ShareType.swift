//
//  ShareType.swift
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

enum NativeShareStyle {
    case normal         // native share is shown with standard options
    case restricted     // native share is shown without some options that are not shares at all
    case notAvailable   // native share is not shown
}

enum ShareType {
    // native -> "restricted == true" excludes some shareTypes that are not shares at all, like copyToClipboard, and assign to contact
    case email, facebook, fbMessenger, whatsapp, twitter, telegram, copyLink, sms, native(restricted: Bool)

    private static var otherCountriesTypes: [ShareType] { return [.sms, .email, .facebook, .fbMessenger, .twitter, .whatsapp, .telegram] }
    private static var turkeyTypes: [ShareType] { return [.whatsapp, .facebook, .email ,.fbMessenger, .twitter, .sms, .telegram] }

    var moreInfoTypes: [ShareType] {
        return ShareType.shareTypesForCountry("", maxButtons: nil, nativeShare: .notAvailable)
    }

    static func shareTypesForCountry(_ countryCode: String, maxButtons: Int?, nativeShare: NativeShareStyle) -> [ShareType] {
        let turkey = "tr"

        let countryTypes: [ShareType]
        switch countryCode.lowercased() {
        case turkey:
            countryTypes = turkeyTypes
        default:
            countryTypes = otherCountriesTypes
        }

        var resultShareTypes = countryTypes.filter { SocialSharer.canShareIn($0) }

        if var maxButtons = maxButtons, maxButtons > 0 {
            switch nativeShare {
            case .normal, .restricted:
                maxButtons = maxButtons-1
            case .notAvailable:
                break
            }
            if resultShareTypes.count > maxButtons {
                resultShareTypes = Array(resultShareTypes[0..<maxButtons])
            }
        }

        switch nativeShare {
        case .normal:
            resultShareTypes.append(.native(restricted: false))
        case .restricted:
            resultShareTypes.append(.native(restricted: true))
        case .notAvailable:
            break
        }

        return resultShareTypes
    }

    var trackingShareNetwork: EventParameterShareNetwork {
        switch self {
        case .email:
            return .email
        case .fbMessenger:
            return .fbMessenger
        case .whatsapp:
            return .whatsapp
        case .facebook:
            return .facebook
        case .twitter:
            return .twitter
        case .telegram:
            return .telegram
        case .copyLink:
            return .copyLink
        case .sms:
            return .sms
        case .native:
            return .native
        }
    }

    var smallImage: UIImage? {
        switch self {
        case .email:
            return UIImage(named: "item_share_email")
        case .facebook:
            return UIImage(named: "item_share_fb")
        case .twitter:
            return UIImage(named: "item_share_twitter")
        case .native:
            return UIImage(named: "item_share_more")
        case .copyLink:
            return UIImage(named: "item_share_link")
        case .fbMessenger:
            return UIImage(named: "item_share_fb_messenger")
        case .whatsapp:
            return UIImage(named: "item_share_whatsapp")
        case .telegram:
            return UIImage(named: "item_share_telegram")
        case .sms:
            return UIImage(named: "item_share_sms")
        }
    }

    var bigImage: UIImage? {
        switch self {
        case .email:
            return UIImage(named: "item_share_email_big")
        case .facebook:
            return UIImage(named: "item_share_fb_big")
        case .twitter:
            return UIImage(named: "item_share_twitter_big")
        case .native:
            return UIImage(named: "item_share_more_big")
        case .copyLink:
            return UIImage(named: "item_share_link_big")
        case .fbMessenger:
            return UIImage(named: "item_share_fb_messenger_big")
        case .whatsapp:
            return UIImage(named: "item_share_whatsapp_big")
        case .telegram:
            return UIImage(named: "item_share_telegram_big")
        case .sms:
            return UIImage(named: "item_share_sms_big")
        }
    }

    var accesibilityId: AccessibilityId {
        switch self {
        case .email:
            return .socialShareEmail
        case .facebook:
            return .socialShareFacebook
        case .twitter:
            return .socialShareTwitter
        case .native:
            return .socialShareMore
        case .copyLink:
            return .socialShareCopyLink
        case .fbMessenger:
            return .socialShareFBMessenger
        case .whatsapp:
            return .socialShareWhatsapp
        case .telegram:
            return .socialShareTelegram
        case .sms:
            return .socialShareSMS
        }
    }
}
