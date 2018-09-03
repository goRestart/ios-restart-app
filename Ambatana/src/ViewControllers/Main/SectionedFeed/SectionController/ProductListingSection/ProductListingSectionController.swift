import IGListKit
import LGCoreKit
import LGComponents

final class ProductListingSectionController: ListSectionController {
    
    private var productListingData: FeedListingData?
    private let productListingViewModel: ProductListingViewModel
    
    weak var listingActionDelegate: ListingActionDelegate?

    init(productListingViewModel: ProductListingViewModel) {
        self.productListingViewModel = productListingViewModel
        super.init()
        inset = .zero
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let data = productListingData else {
            return productListingViewModel.defaultListingCellSize
        }
        return productListingViewModel.cellSize(for: data)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let data = productListingData else {
            fatalError("No data available to render FeedListingCell")
        }
        let cellType = data.isFeatured ? FeedDetailedListingCell.self : FeedListingCell.self
        guard let cell = collectionContext?.dequeueReusableCell(of: cellType,
                                                                for: self,
                                                                at: index) as? FeedListingCell else { fatalError() }
        
        if let cell = cell as? FeedDetailedListingCell {
            cell.setupFeedDetailButton(data,
                                       buttonHeight: productListingViewModel.buttonHeight)
        }
        cell.setupFeedListingData(productListingViewModel.updateFeedData(data))
        cell.delegate = listingActionDelegate
        return cell
    }
    
    override func didUpdate(to object: Any) {
        productListingData = (object as? DiffableBox<FeedListingData>)?.value
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cell = collectionContext?.cellForItem(at: index, sectionController: self) as? FeedListingCell,
            let listing = productListingData?.listing else { return }
        let newFrame = viewController?.view.convert(cell.frame,
                                                    from: nil)
        listingActionDelegate?.didSelectListing(listing,
                                                thumbnailImage: cell.thumbnailImage,
                                                originFrame: newFrame)
    }
}
