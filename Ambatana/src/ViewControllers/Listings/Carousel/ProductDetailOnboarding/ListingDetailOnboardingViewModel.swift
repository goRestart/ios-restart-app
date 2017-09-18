//
//  ListingDetailOnboardingViewModel.swift
//  LetGo
//
//  Created by Dídac on 13/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol ListingDetailOnboardingViewDelegate: class {
    func listingDetailOnboardingDidAppear()
    func listingDetailOnboardingDidDisappear()
}

class ListingDetailOnboardingViewModel : BaseViewModel {

    var featureFlags: FeatureFlaggeable
    var keyValueStorage: KeyValueStorageable
    weak var delegate: ListingDetailOnboardingViewDelegate?
    
    var newLabelIsHidden: Bool {
        return !(featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive && keyValueStorage[.didShowListingDetailOnboarding])
    }

    var newText: String {
        return LGLocalizedString.commonNew
    }

    var firstImage: UIImage? {
        return UIImage(named: "finger_tap")
    }
    var firstText: NSAttributedString {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            let highlightedText = LGLocalizedString.productNewOnboardingFingerTapHighlightedLabel
            return tipText(textToHighlight: highlightedText,
                           fullText: LGLocalizedString.productNewOnboardingFingerTapLabel(highlightedText))
        }
        return tipText(textToHighlight: nil, fullText: LGLocalizedString.productOnboardingFingerTapLabel)
    }

    var secondImage: UIImage? {
        return UIImage(named: "finger_swipe")
    }
    var secondText: NSAttributedString {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            let highlightedText = LGLocalizedString.productNewOnboardingFingerSwipeHighlightedLabel
            return tipText(textToHighlight: highlightedText,
                           fullText: LGLocalizedString.productNewOnboardingFingerSwipeLabel(highlightedText))
        }
        return tipText(textToHighlight: nil, fullText: LGLocalizedString.productOnboardingFingerSwipeLabel)
    }

    var thirdImage: UIImage? {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            return UIImage(named: "finger_keep_swipe")
        }
        return UIImage(named: "finger_scroll")
    }
    var thirdText: NSAttributedString {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            let highlightedText = LGLocalizedString.productNewOnboardingFingerKeepSwipeHighlightedLabel
            return tipText(textToHighlight: highlightedText,
                           fullText: LGLocalizedString.productNewOnboardingFingerKeepSwipeLabel(highlightedText))
        }
        return tipText(textToHighlight: nil, fullText: LGLocalizedString.productOnboardingFingerScrollLabel)
    }

    convenience override init() {
        self.init(featureFlags: FeatureFlags.sharedInstance, keyValueStorage: KeyValueStorage.sharedInstance)
    }

    init(featureFlags: FeatureFlaggeable, keyValueStorage: KeyValueStorageable) {
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        super.init()
    }

    override func didSetActive(_ active: Bool) {
        super.didSetActive(active)
        hasBeenShown()
    }

    func hasBeenShown() {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            keyValueStorage[.didShowHorizontalListingDetailOnboarding] = true
        } else {
            keyValueStorage[.didShowListingDetailOnboarding] = true
        }
        delegate?.listingDetailOnboardingDidAppear()
    }

    func close() {
        delegate?.listingDetailOnboardingDidDisappear()
    }

    private func tipText(textToHighlight: String?, fullText: String) -> NSAttributedString {

        var regularTextAttributes = [String : AnyObject]()
        regularTextAttributes[NSForegroundColorAttributeName] = UIColor.white
        regularTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 17)

        let regularAttributedText = NSAttributedString(string: fullText, attributes: regularTextAttributes)

        let resultText = NSMutableAttributedString(attributedString: regularAttributedText)

        if let textToHighlight = textToHighlight {
            var highlightedTextAttributes = [String : AnyObject]()
            highlightedTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColor
            highlightedTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 17)

            let range = (fullText as NSString).range(of: textToHighlight)
            resultText.addAttributes(highlightedTextAttributes, range: range)
        }

        return resultText
    }
}
