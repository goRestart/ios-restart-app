import Foundation
import LGComponents

protocol ListingDetailOnboardingViewDelegate: class {
    func listingDetailOnboardingDidAppear()
    func listingDetailOnboardingDidDisappear()
}

class ListingDetailOnboardingViewModel : BaseViewModel {

    var featureFlags: FeatureFlaggeable
    var keyValueStorage: KeyValueStorageable
    weak var delegate: ListingDetailOnboardingViewDelegate?

    var firstImage: UIImage  = R.Asset.ProductOnboardingImages.fingerTap.image
    var firstText = ListingDetailOnboardingViewModel.tipText(textToHighlight: nil,
                                                                                 textToHighlight2: nil,
                                                                                 fullText: R.Strings.productOnboardingFingerTapLabel)
    var secondImage: UIImage = R.Asset.ProductOnboardingImages.fingerSwipe.image

    var secondText = ListingDetailOnboardingViewModel.tipText(textToHighlight: nil,
                                                              textToHighlight2: nil,
                                                              fullText: R.Strings.productOnboardingFingerSwipeLabel)
    var thirdImage: UIImage = R.Asset.ProductOnboardingImages.fingerScroll.image

    var thirdText = ListingDetailOnboardingViewModel.tipText(textToHighlight: nil,
                       textToHighlight2: nil,
                       fullText: R.Strings.productOnboardingFingerScrollLabel)

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

        var regularTextAttributes = [NSAttributedStringKey : Any]()
        regularTextAttributes[NSAttributedStringKey.foregroundColor] = UIColor.white
        regularTextAttributes[NSAttributedStringKey.font] = UIFont.systemMediumFont(size: 17)

        let regularAttributedText = NSAttributedString(string: fullText, attributes: regularTextAttributes)

        let resultText = NSMutableAttributedString(attributedString: regularAttributedText)

        if let textToHighlight = textToHighlight {
            var highlightedTextAttributes = [NSAttributedStringKey : Any]()
            highlightedTextAttributes[NSAttributedStringKey.foregroundColor] = UIColor.primaryColor
            highlightedTextAttributes[NSAttributedStringKey.font] = UIFont.systemMediumFont(size: 17)

            let range = (fullText as NSString).range(of: textToHighlight)
            resultText.addAttributes(highlightedTextAttributes, range: range)
        }

        return resultText
    }
}
