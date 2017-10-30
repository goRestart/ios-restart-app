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

    var firstImage: UIImage?  = #imageLiteral(resourceName: "finger_tap")
    var firstText = ListingDetailOnboardingViewModel.tipText(textToHighlight: nil,
                                                                                 textToHighlight2: nil,
                                                                                 fullText: LGLocalizedString.productOnboardingFingerTapLabel)
    var secondImage: UIImage? = #imageLiteral(resourceName: "finger_swipe")

    var secondText = ListingDetailOnboardingViewModel.tipText(textToHighlight: nil,
                                                              textToHighlight2: nil,
                                                              fullText: LGLocalizedString.productOnboardingFingerSwipeLabel)
    var thirdImage: UIImage? = #imageLiteral(resourceName: "finger_scroll")

    var thirdText = ListingDetailOnboardingViewModel.tipText(textToHighlight: nil,
                       textToHighlight2: nil,
                       fullText: LGLocalizedString.productOnboardingFingerScrollLabel)

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
        keyValueStorage[.didShowListingDetailOnboarding] = true
        delegate?.listingDetailOnboardingDidAppear()
    }

    func close() {
        delegate?.listingDetailOnboardingDidDisappear()
    }

    private static func tipText(textToHighlight: String?, textToHighlight2: String?, fullText: String) -> NSAttributedString {

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
