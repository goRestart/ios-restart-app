
import Foundation
import LGCoreKit
import LGComponents

protocol ListingTitleFontDescriptor {
    var titleFont: UIFont { get }
    var titleColor: UIColor { get }
    var titlePrefixFont: UIFont { get }
    var titlePrefixColor: UIColor { get }
}

struct ListingTitleViewModel {
    
    private let listing: Listing
    private let featureFlags: FeatureFlaggeable
    
    private var titlePrefix: String? {
        if let listingType = listing.service?.servicesAttributes.listingType {
            let canShowTitlePrefix = featureFlags.jobsAndServicesEnabled.isActive
            switch listingType {
            case .service:
                return canShowTitlePrefix ? R.Strings.jobsServicesOfferingText+":" : nil
            case .job:
                return canShowTitlePrefix ? R.Strings.jobsServicesWantedText+":" : nil
            }
        }
        return nil
    }
    
    var title: String? {
        return listing.title
    }
    
    var shouldUseAttributedTitle: Bool {
        return title != nil && titlePrefix != nil
    }
    
    init?(listing: Listing?,
          featureFlags: FeatureFlaggeable) {
        guard let listing = listing else {
            return nil
        }
        self.listing = listing
        self.featureFlags = featureFlags
    }
    
    func createTitleAttributedString(withFontDescriptor fontDescriptor: ListingTitleFontDescriptor) -> NSAttributedString? {
        return createTitleAttributedString(forTitle: title,
                                           titlePrefix: titlePrefix,
                                           withFontDescriptor: fontDescriptor)
    }
    
    private func createTitleAttributedString(forTitle title: String?,
                                             titlePrefix: String?,
                                             withFontDescriptor fontDescriptor: ListingTitleFontDescriptor) -> NSAttributedString? {
        guard let title = title,
            let titlePrefix = titlePrefix else { return nil }
        
        let text = "\(titlePrefix) \(title)"
        return text.bifontAttributedText(highlightedText: titlePrefix,
                                         mainFont: fontDescriptor.titleFont,
                                         mainColour: fontDescriptor.titleColor,
                                         otherFont: fontDescriptor.titlePrefixFont,
                                         otherColour: fontDescriptor.titlePrefixColor)
    }
    
    func height(forWidth width: CGFloat,
                maxLines: Int?,
                fontDescriptor: ListingTitleFontDescriptor) -> CGFloat {
        if let attributedTitle = createTitleAttributedString(withFontDescriptor: fontDescriptor) {
            return attributedTitle.height(forContainerWidth: width,
                                           maxLines: maxLines,
                                           withFont: fontDescriptor.titleFont)
        } else {
            return title?.heightForWidth(width: width,
                                         maxLines: maxLines,
                                         withFont: fontDescriptor.titleFont) ?? 0
        }
    }

}
