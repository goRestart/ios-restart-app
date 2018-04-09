//
//  ShareType.swift
//  LetGo
//
//  Created by AHL on 16/8/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

enum NativeShareStyle {
    case normal         // native share is shown with standard options
    case restricted     // native share is shown without some options that are not shares at all
    case notAvailable   // native share is not shown
}

enum ShareType {
    case email, facebook, fbMessenger, whatsapp, twitter, telegram, copyLink, sms
    case native(restricted: Bool)   // "restricted == true" excludes some shareTypes that are not shares at all, like copyToClipboard, and assign to contact
    
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

    var accessibilityId: AccessibilityId {
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
