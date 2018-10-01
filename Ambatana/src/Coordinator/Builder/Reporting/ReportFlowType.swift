import Foundation
import LGCoreKit
import LGComponents

enum ReportFlowType {
    case product(listing: Listing)
    case user(rateData: RateUserData)

    var options: ReportOptionsGroup {
        switch self {
        case .product: return ReportOptionsBuilder.reportProductOptions()
        case .user: return ReportOptionsBuilder.reportUserOptions()
        }
    }

    var title: String {
        switch self {
        case .product: return R.Strings.reportingListingTitle
        case .user: return R.Strings.reportingUserTitle
        }
    }

    var listing: Listing? {
        switch self {
        case .product(let listing): return listing
        case .user: return nil
        }
    }

    var rateData: RateUserData? {
        switch self {
        case .product(let listing):
            return RateUserData(user: listing.user, listingId: listing.objectId, ratingType: .report)
        case .user(let data): return data
        }
    }
}
