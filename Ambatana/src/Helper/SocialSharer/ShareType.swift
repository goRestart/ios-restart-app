import LGComponents

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
            return R.Asset.IconsButtons.itemShareEmail.image
        case .facebook:
            return R.Asset.IconsButtons.itemShareFb.image
        case .twitter:
            return R.Asset.IconsButtons.itemShareTwitter.image
        case .native:
            return R.Asset.IconsButtons.itemShareMore.image
        case .copyLink:
            return R.Asset.IconsButtons.itemShareLink.image
        case .fbMessenger:
            return R.Asset.IconsButtons.itemShareFbMessenger.image
        case .whatsapp:
            return R.Asset.IconsButtons.itemShareWhatsapp.image
        case .telegram:
            return R.Asset.IconsButtons.itemShareTelegram.image
        case .sms:
            return R.Asset.IconsButtons.itemShareSms.image
        }
    }

    var bigImage: UIImage? {
        switch self {
        case .email:
            return R.Asset.IconsButtons.itemShareEmailBig.image
        case .facebook:
            return R.Asset.IconsButtons.itemShareFbBig.image
        case .twitter:
            return R.Asset.IconsButtons.itemShareTwitterBig.image
        case .native:
            return R.Asset.IconsButtons.itemShareMoreBig.image
        case .copyLink:
            return R.Asset.IconsButtons.itemShareLinkBig.image
        case .fbMessenger:
            return R.Asset.IconsButtons.itemShareFbMessengerBig.image
        case .whatsapp:
            return R.Asset.IconsButtons.itemShareWhatsappBig.image
        case .telegram:
            return R.Asset.IconsButtons.itemShareTelegramBig.image
        case .sms:
            return R.Asset.IconsButtons.itemShareSmsBig.image
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
