import LGComponents
import LGCoreKit

final class ProductListingViewModel: BaseViewModel {
    
    private var cellStyle: CellStyle = .mainList
    private let listingCellSizeMetrics: ListingCellSizeMetrics
    private let myUserRepository: MyUserRepository
    private let interestedStateManager: InterestedStateUpdater

    init(numberOfColumns: Int,
         myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.listingCellSizeMetrics = ListingCellSizeMetrics(numberOfColumns: numberOfColumns)
        self.myUserRepository = myUserRepository
        self.interestedStateManager = LGInterestedStateUpdater()
        super.init()
    }
    
    var defaultListingCellSize: CGSize {
        return listingCellSizeMetrics.defaultCellSize
    }
    
    var buttonHeight: CGFloat {
        return listingCellSizeMetrics.buttonHeight
    }
    
    func cellSize(for feedListingData: FeedListingData) -> CGSize {
        let width = listingCellSizeMetrics.cellWidth
        var cellHeight = feedListingData.imageSize.height
        let listing = feedListingData.listing
        if let featured = listing.featured, featured {
            if cellStyle == .serviceList {
                cellHeight += actionButtonCellHeight(for: listing)
            } else  {
                cellHeight += featuredInfoAdditionalCellHeight(for: listing,
                                                               width: width)
            }
        } else if cellStyle == .serviceList {
            cellHeight += ListingCellMetrics.getTotalHeightForPriceAndTitleView(titleViewModel: ListingTitleViewModel(listing: feedListingData.listing), containerWidth: width)
        }
        return CGSize(width: Int(width), height: Int(cellHeight))
    }

    func updateFeedData(_ data: FeedListingData) -> FeedListingData {
        let newState = data.listing.interestedState(myUserRepository: myUserRepository,
                                                    listingInterestStates: interestedStateManager.listingInterestStates)
        return FeedListingData.Lenses.interestedState.set(newState, data)
    }

    private func actionButtonCellHeight(for listing: Listing) -> CGFloat {
        let isMine = listing.isMine(myUserRepository: myUserRepository)
        return isMine ? 0.0 : ListingCellMetrics.ActionButton.totalHeight
    }
    
    private func featuredInfoAdditionalCellHeight(for listing: Listing, width: CGFloat) -> CGFloat {
        var height: CGFloat = actionButtonCellHeight(for: listing)
        height += ListingCellMetrics.getTotalHeightForPriceAndTitleView(titleViewModel: ListingTitleViewModel(listing: listing), containerWidth: width)
        return height
    }
}
