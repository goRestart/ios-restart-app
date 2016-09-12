//
//  TourLoginViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
enum TourLoginNextStep {
    case Notifications
    case Location
    case None
}

final class TourLoginViewModel: BaseViewModel {

    var attributedLegalText: NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, let privacyURL = privacyURL else {
            return NSAttributedString(string: LGLocalizedString.tourTermsConditions)
        }

        let links = [LGLocalizedString.tourTermsConditionsTermsKeyword: conditionsURL,
                     LGLocalizedString.tourTermsConditionsPrivacyKeyword: privacyURL]
        let localizedLegalText = LGLocalizedString.tourTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
                                                                                             textColor: UIColor.darkGrayText)
        let range = NSMakeRange(0, attributtedLegalText.length)
        attributtedLegalText.addAttribute(NSFontAttributeName, value: UIFont.smallBodyFont, range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        attributtedLegalText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
        return attributtedLegalText
    }

    private var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    private var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }
    
    func nextStep() -> TourLoginNextStep {
        
        let casnAskForPushPermissions = PushPermissionsManager.sharedInstance
            .shouldShowPushPermissionsAlertFromViewController(.Onboarding)
       
        if casnAskForPushPermissions {
            return .Notifications
        } else if Core.locationManager.shouldAskForLocationPermissions() {
            return .Location
        } else {
            return .None
        }
    }
}