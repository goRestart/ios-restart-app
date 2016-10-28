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

final class SocialHelper {
    /**
        Returns a social message for the given product with a title.
    
        - parameter title: The title
        - parameter product: The product
        - returns: The social message.
    */
    static func socialMessageWithProduct(product: Product) -> SocialMessage {
        let productIsMine = Core.myUserRepository.myUser?.objectId == product.user.objectId
        let socialTitleMyProduct = product.price.free ? LGLocalizedString.productIsMineShareBodyFree :
                                                        LGLocalizedString.productIsMineShareBody
        let socialTitle = productIsMine ? socialTitleMyProduct : LGLocalizedString.productShareBody
        return ProductSocialMessage(title: socialTitle, product: product, isMine: productIsMine)
    }

    static func socialMessageUser(user: User, itsMe: Bool) -> SocialMessage {
        return UserSocialMessage(user: user, itsMe: itsMe)
    }

    static func socialMessageAppShare() -> SocialMessage {
        return AppShareSocialMessage()
    }

    static func socialMessageCommercializer(shareUrl: String, thumbUrl: String?) -> SocialMessage {
        return CommercializerSocialMessage(shareUrl: shareUrl, thumbUrl: thumbUrl)
    }
}


// MARK: - UIViewController native share extension

protocol NativeShareDelegate {
    var nativeShareSuccessMessage: String? { get }
    var nativeShareErrorMessage: String? { get }
    func nativeShareInFacebook()
    func nativeShareInTwitter()
    func nativeShareInEmail()
    func nativeShareInWhatsApp()
}

extension UIViewController {

    func presentNativeShare(socialMessage socialMessage: SocialMessage, delegate: NativeShareDelegate?,
                                          barButtonItem: UIBarButtonItem? = nil) {

        guard let activityItems = socialMessage.nativeShareItems else { return }
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
        if vc.respondsToSelector(Selector("popoverPresentationController")) {
            let presentationController = vc.popoverPresentationController
            if let item = barButtonItem {
                presentationController?.barButtonItem = item
            } else {
                presentationController?.sourceView = self.view
            }
        }

        vc.completionWithItemsHandler = { [weak self] (activity, success, items, error) in

            // Comment left here as a clue to manage future activities
            /*   SAMPLES OF SHARING RESULTS VIA ACTIVITY VC

             println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")

             Activity: com.apple.UIKit.activity.PostToFacebook Success: true Items: nil Error: nil
             Activity: net.whatsapp.WhatsApp.ShareExtension Success: true Items: nil Error: nil
             Activity: com.apple.UIKit.activity.Mail Success: true Items: nil Error: nil
             Activity: com.apple.UIKit.activity.PostToTwitter Success: true Items: nil Error: nil
             */

            guard success else {
                //In case of cancellation just do nothing -> success == false && error == nil
                guard error != nil else { return }
                if let errorMessage = delegate?.nativeShareErrorMessage {
                    self?.showAutoFadingOutMessageAlert(errorMessage)
                }
                return
            }

            if activity == UIActivityTypePostToFacebook {
                delegate?.nativeShareInFacebook()
            } else if activity == UIActivityTypePostToTwitter {
                delegate?.nativeShareInTwitter()
            } else if activity == UIActivityTypeMail {
                delegate?.nativeShareInEmail()
            } else if let ac = activity, let _ = ac.rangeOfString("whatsapp") {
                delegate?.nativeShareInWhatsApp()
                return
            } else if activity == UIActivityTypeCopyToPasteboard {
                return
            }

            if let successMessage = delegate?.nativeShareSuccessMessage {
                self?.showAutoFadingOutMessageAlert(successMessage)
            }
        }
        presentViewController(vc, animated: true, completion: nil)
    }
}
