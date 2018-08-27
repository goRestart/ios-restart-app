import IGListKit
import LGCoreKit

/// This class renders each horizontally scrolling listing cell

final class EmbeddedListingSectionController: ListSectionController {

    private var feedListingData: FeedListingData?
    private let embeddedListingViewModel: EmbeddedListingViewModel

    weak var listingActionDelegate: ListingActionDelegate?
    
    init(embeddedListingViewModel: EmbeddedListingViewModel) {
        self.embeddedListingViewModel = embeddedListingViewModel
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: FeedListingCell.self,
                                                                for: self,
                                                                at: index) as? FeedListingCell else {
            fatalError()
        }
        if let data = feedListingData {
            cell.setupFeedListingData(embeddedListingViewModel.updateFeedData(data))
        }
        cell.delegate = listingActionDelegate
        return cell
    }
    
    override func didUpdate(to object: Any) {
        let diffWrapper = object as? DiffableBox<FeedListingData>
        feedListingData = diffWrapper?.value
    }
}
