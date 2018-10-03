import LGCoreKit

protocol BulkListingPostedNavigator: class {
    func close(listings: [Listing])
    func openEditListing(listing: Listing, onEditAction: OnEditActionable)
    func postAnotherListing()
}
