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
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            return UIImage(named: "right_tap_squared")
        }
        return UIImage(named: "finger_tap")
    }
    var firstText: NSAttributedString {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            let highlightedTextTapRight = LGLocalizedString.productNewOnboardingTapRightHighlightedLabel
            let highlightedTextTapMiddle = LGLocalizedString.productNewOnboardingTapRightHighlightedLabel2
            return tipText(textToHighlight: highlightedTextTapRight,
                           textToHighlight2: highlightedTextTapMiddle,
                           fullText: LGLocalizedString.productNewOnboardingTapRightLabel(highlightedTextTapRight, highlightedTextTapMiddle))
        }
        return tipText(textToHighlight: nil,
                       textToHighlight2: nil,
                       fullText: LGLocalizedString.productOnboardingFingerTapLabel)
    }

    var secondImage: UIImage? {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            return UIImage(named: "left_tap_squared")
        }
        return UIImage(named: "finger_swipe")
    }
    var secondText: NSAttributedString {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            let highlightedText = LGLocalizedString.productNewOnboardingTapLeftLabelHighlighted
            return tipText(textToHighlight: highlightedText,
                           textToHighlight2: nil,
                           fullText: LGLocalizedString.productNewOnboardingTapLeftLabel(highlightedText))
        }
        return tipText(textToHighlight: nil,
                       textToHighlight2: nil,
                       fullText: LGLocalizedString.productOnboardingFingerSwipeLabel)
    }

    var thirdImage: UIImage? {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            return UIImage(named: "finger_swipe_card")
        }
        return UIImage(named: "finger_scroll")
    }
    var thirdText: NSAttributedString {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            let highlightedText = LGLocalizedString.productNewOnboardingFingerSwipeNextProductHighlightedLabel
            return tipText(textToHighlight: highlightedText,
                           textToHighlight2: nil,
                           fullText: LGLocalizedString.productNewOnboardingFingerSwipeNextProductLabel(highlightedText))
        }
        return tipText(textToHighlight: nil,
                       textToHighlight2: nil,
                       fullText: LGLocalizedString.productOnboardingFingerScrollLabel)
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

    private func tipText(textToHighlight: String?, textToHighlight2: String?, fullText: String) -> NSAttributedString {

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
        
        if let textToHighlight2 = textToHighlight2 {
            var highlightedTextAttributes = [String : AnyObject]()
            highlightedTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColor
            highlightedTextAttributes[NSFontAttributeName] = UIFont.systemMediumFont(size: 17)
            
            let range2 = (fullText as NSString).range(of: textToHighlight2)
            resultText.addAttributes(highlightedTextAttributes, range: range2)
        }

        return resultText
    }
}
