import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

struct BulkPostingsPostedCellViewModel {
    let imageURL: URL?
    let price: String
}

protocol BulkPostingsPostedViewModelTypeInput {
    func didTapEditAtIndex(index: Int)
    func didTapClose()
    func didTapMainAction()
    func didTapIncentivate()
}

protocol BulkPostingsPostedViewModelTypeOutput {
    var cells: Driver<[(image: URL?, price: String)]> { get }
}

protocol BulkPostingsPostedViewModelType {
    var input: BulkPostingsPostedViewModelTypeInput { get }
    var output: BulkPostingsPostedViewModelTypeOutput { get }
}


// MARK: - BulkPostingsPostedViewModel

final class BulkPostingsPostedViewModel: BaseViewModel, BulkPostingsPostedViewModelTypeInput, BulkPostingsPostedViewModelTypeOutput, BulkPostingsPostedViewModelType {

    var input: BulkPostingsPostedViewModelTypeInput {  return self }
    var output: BulkPostingsPostedViewModelTypeOutput { return self }

    var navigator: BulkPostingPostedNavigator?

    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorage
    private let tracker: Tracker
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let preSignedUploadUrlRepository: PreSignedUploadUrlRepository
    private let myUserRepository: MyUserRepository


    // MARK: - Lifecycle

    convenience init(listings: [Listing]) {
        self.init(listings: listings,
                  listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  preSignedUploadUrlRepository: Core.preSignedUploadUrlRepository,
                  myUserRepository: Core.myUserRepository,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(listings: [Listing],
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
         preSignedUploadUrlRepository: PreSignedUploadUrlRepository,
         myUserRepository: MyUserRepository,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker) {
        self.listingsRelay.accept(listings)
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.preSignedUploadUrlRepository = preSignedUploadUrlRepository
        self.myUserRepository = myUserRepository
    }

    // MARK: - Input

    func didTapClose() {
        navigator?.close(listings: [])
    }

    func didTapEditAtIndex(index: Int) {
        let listing = listingsRelay.value[index]
        navigator?.openEditListing(listing: listing, onEditAction: self)
    }

    func didTapMainAction() {
        navigator?.postAnotherListing()
    }

    func didTapIncentivate() {
        navigator?.postAnotherListing()
    }

    // MARK: - Output

    private let listingsRelay = BehaviorRelay<[Listing]>(value: [])
    var cells: Driver<[(image: URL?, price: String)]> {
        return listingsRelay.asDriver().map { $0.map { listing in
            let price = listing.price.stringValue(currency: listing.currency, isFreeEnabled: listing.price.isFree)
            return (listing.thumbnail?.fileURL, price)
            }
        }
    }
}

// MARK: - OnEditActionable

extension BulkPostingsPostedViewModel: OnEditActionable {

    func onEdit(listing: Listing,
                purchases: [BumpUpProductData],
                timeSinceLastBump: TimeInterval?,
                maxCountdown: TimeInterval) {

        guard let index = listingsRelay.value.index(where: { $0.objectId == listing.objectId }) else { return }
        var listings = listingsRelay.value
        listings[index] = listing
        listingsRelay.accept(listings)
    }
}
