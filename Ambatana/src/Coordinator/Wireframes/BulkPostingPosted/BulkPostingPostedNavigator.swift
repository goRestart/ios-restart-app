import LGCoreKit

protocol BulkPostingPostedNavigator: class {
    func close(listings: [Listing])
    func openEditListing(listing: Listing, onEditAction: OnEditActionable)
    func postAnotherListing()
}
