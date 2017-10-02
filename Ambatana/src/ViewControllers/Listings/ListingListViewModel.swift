//
//  ListingListViewModel.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

protocol ListingListViewModelDelegate: class {
    func vmReloadData(_ vm: ListingListViewModel)
    func vmDidUpdateState(_ vm: ListingListViewModel, state: ViewState)
    func vmDidFinishLoading(_ vm: ListingListViewModel, page: UInt, indexes: [Int])
}

protocol ListingListViewModelDataDelegate: class {
    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt, hasListings: Bool,
                         error: RepositoryError)
    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt, hasListings: Bool)
    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?)
    func vmProcessReceivedListingPage(_ Listings: [ListingCellModel], page: UInt) -> [ListingCellModel]
    func vmDidSelectSellBanner(_ type: String)
    func vmDidSelectCollection(_ type: CollectionCellType)
}

extension ListingListViewModelDataDelegate {
    func vmProcessReceivedListingPage(_ Listings: [ListingCellModel], page: UInt) -> [ListingCellModel] { return Listings }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}

struct ListingsRequesterResult {
    let listingsResult: ListingsResult
    let context: String?
    let verticalTrackingInfo: VerticalTrackingInfo?

    init(listingsResult: ListingsResult, context: String?, verticalTrackingInfo: VerticalTrackingInfo? = nil) {
        self.listingsResult = listingsResult
        self.context = context
        self.verticalTrackingInfo = verticalTrackingInfo
    }
}

struct VerticalTrackingInfo {
    let category: ListingCategory
    let keywords: [String]
    let matchingFields: [String]
    let nonMatchingFields: [String]
}

typealias ListingsRequesterCompletion = (ListingsRequesterResult) -> Void

protocol ListingListRequester: class {
    var itemsPerPage: Int { get }
    func canRetrieve() -> Bool
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?)
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?)
    func isLastPage(_ resultCount: Int) -> Bool
    func updateInitialOffset(_ newOffset: Int)
    func duplicate() -> ListingListRequester
    func isEqual(toRequester requester: ListingListRequester) -> Bool
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double?
    var countryCode: String? { get }
}

class ListingListViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let cellMinHeight: CGFloat = 80.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellBannerAspectRatio: CGFloat = 1.3
    private static let cellMaxThumbFactor: CGFloat = 2.0
    private static let cellFeaturedInfoMinHeight: CGFloat = 105.0
    private static let cellFeaturedInfoTitleMaxLines: CGFloat = 2.0
    private static let cellPriceViewHeight: CGFloat = 30.0

    var cellWidth: CGFloat {
        return (UIScreen.main.bounds.size.width - (listingListFixedInset*2)) / CGFloat(numberOfColumns)
    }

    var cellStyle: CellStyle {
        return .mainList
    }
    
    var listingListFixedInset: CGFloat = 10.0
    
    // MARK: - iVars 

    // Delegates
    weak var delegate: ListingListViewModelDelegate?
    weak var dataDelegate: ListingListViewModelDataDelegate?
    weak var listingCellDelegate: ListingCellDelegate?
    
    // Requester
    var listingListRequester: ListingListRequester?
    
    let imageDownloader: ImageDownloaderType

    //State
    private(set) var pageNumber: UInt
    private(set) var refreshing: Bool
    private(set) var state: ViewState {
        didSet {
            delegate?.vmDidUpdateState(self, state: state)
            isListingListEmpty.value = state.isEmpty
        }
    }

    // Data
    private(set) var objects: [ListingCellModel]
    private var indexToTitleMapping: [Int:String]

    // UI
    private(set) var defaultCellSize: CGSize
    
    private(set) var isLastPage: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var isOnErrorState: Bool = false
    
    var canRetrieveListings: Bool {
        let requesterCanRetrieve = listingListRequester?.canRetrieve() ?? false
        return requesterCanRetrieve && !isLoading
    }
    
    var canRetrieveListingsNextPage: Bool {
        return !isLastPage && canRetrieveListings
    }
    
    var shouldShowPrices: Bool?
    
    // Tracking
    
    fileprivate let tracker: Tracker
    
    
    // RX vars
    
    let isListingListEmpty = Variable<Bool>(true)

    // MARK: - Computed iVars
    
    var numberOfListings: Int {
        return objects.count
    }
    
    let numberOfColumns: Int

    
    // MARK: - Lifecycle

    init(requester: ListingListRequester?,
         listings: [Listing]? = nil,
         numberOfColumns: Int = 2,
         tracker: Tracker = TrackerProxy.sharedInstance,
         imageDownloader: ImageDownloaderType = ImageDownloader.sharedInstance,
         shouldShowPrices: Bool = false) {
        self.objects = (listings ?? []).map(ListingCellModel.init)
        self.pageNumber = 0
        self.refreshing = false
        self.state = .loading
        self.numberOfColumns = numberOfColumns
        self.listingListRequester = requester
        self.defaultCellSize = CGSize.zero
        self.tracker = tracker
        self.imageDownloader = imageDownloader
        self.indexToTitleMapping = [:]
        self.shouldShowPrices = shouldShowPrices
        super.init()
        let cellHeight = cellWidth * ListingListViewModel.cellAspectRatio
        self.defaultCellSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    convenience init(listViewModel: ListingListViewModel) {
        self.init(requester: listViewModel.listingListRequester)
        self.pageNumber = listViewModel.pageNumber
        self.state = listViewModel.state
        self.objects = listViewModel.objects
    }
    
   
    // MARK: - Public methods
    // MARK: > Requests

    func refresh() {
        refreshing = true
        if !retrieveListings() {
            refreshing = false
            delegate?.vmDidFinishLoading(self, page: 0, indexes: [])
        }
    }

    func setErrorState(_ viewModel: LGEmptyViewModel) {
        state = .error(viewModel)
        if let errorReason = viewModel.emptyReason {
             trackErrorStateShown(reason: errorReason)
        }
    }

    func setEmptyState(_ viewModel: LGEmptyViewModel) {
        state = .empty(viewModel)
        objects = [ListingCellModel.emptyCell(vm: viewModel)]
    }

    func refreshControlTriggered() {
        refresh()
    }

    func reloadData() {
        delegate?.vmReloadData(self)
    }
    
    @discardableResult func retrieveListings() -> Bool {
        guard canRetrieveListings else { return false }
        retrieveListings(firstPage: true)
        return true
    }
    
    func retrieveListingsNextPage() {
        if canRetrieveListingsNextPage {
            retrieveListings(firstPage: false)
        }
    }

    func resetUI() {
        pageNumber = 0
        refreshing = false
        state = .loading
        isLastPage = false
        isLoading = false
        isOnErrorState = false
        clearList()
    }

    func update(listing: Listing) {
        guard state.isData, let listingId = listing.objectId else { return }
        guard let index = indexFor(listingId: listingId) else { return }
        objects[index] = ListingCellModel(listing: listing)
        delegate?.vmReloadData(self)
    }

    func prepend(listing: Listing) {
        guard state.isData else { return }
        objects.insert(ListingCellModel(listing: listing), at: 0)
        delegate?.vmReloadData(self)
    }

    func delete(listingId: String) {
        guard state.isData else { return }
        guard let index = indexFor(listingId: listingId) else { return }
        objects.remove(at: index)
        delegate?.vmReloadData(self)
    }
    
    func updateShouldShowPrices(_ shouldShowPrices: Bool) {
        self.shouldShowPrices = shouldShowPrices
    }
    
    
    private func retrieveListings(firstPage: Bool) {
        guard let listingListRequester = listingListRequester else { return } //Should not happen

        isLoading = true
        isOnErrorState = false

        if firstPage && numberOfListings == 0 {
            state = .loading
            indexToTitleMapping = [:]
        }
        
        let completion: ListingsRequesterCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            let nextPageNumber = firstPage ? 0 : strongSelf.pageNumber + 1
            self?.isLoading = false
            if let newListings = result.listingsResult.value {
                if let context = result.context, !newListings.isEmpty {
                    strongSelf.indexToTitleMapping[strongSelf.numberOfListings] = context
                }
                if let verticalTrackingInfo = result.verticalTrackingInfo, !newListings.isEmpty {
                    strongSelf.trackVerticalFilterResults(withVerticalTrackingInfo: verticalTrackingInfo)
                }
                let listingCellModels = newListings.map(ListingCellModel.init)
                let cellModels = self?.dataDelegate?.vmProcessReceivedListingPage(listingCellModels, page: nextPageNumber) ?? listingCellModels
                let indexes: [Int]
                if firstPage {
                    strongSelf.objects = cellModels
                    strongSelf.refreshing = false
                    indexes = [Int](0 ..< cellModels.count)
                } else {
                    let currentCount = strongSelf.numberOfListings
                    strongSelf.objects += cellModels
                    indexes = [Int](currentCount ..< (currentCount+cellModels.count))
                }
                strongSelf.pageNumber = nextPageNumber
                let hasListings = strongSelf.numberOfListings > 0
                strongSelf.isLastPage = strongSelf.listingListRequester?.isLastPage(newListings.count) ?? true
                //This assignment should be ALWAYS before calling the delegates to give them the option to re-set the state
                if hasListings {
                    // to avoid showing "loading footer" when there are no elements
                    strongSelf.state = .data
                }
                strongSelf.delegate?.vmDidFinishLoading(strongSelf, page: nextPageNumber, indexes: indexes)
                strongSelf.dataDelegate?.listingListVM(strongSelf, didSucceedRetrievingListingsPage: nextPageNumber,
                                                       hasListings: hasListings)
            } else if let error = result.listingsResult.error {
                strongSelf.processError(error, nextPageNumber: nextPageNumber)
            }
        }

        if firstPage {
            listingListRequester.retrieveFirstPage(completion)
        } else {
            listingListRequester.retrieveNextPage(completion)
        }
    }

    private func processError(_ error: RepositoryError, nextPageNumber: UInt) {
        isOnErrorState = true
        let hasListings = objects.count > 0
        delegate?.vmDidFinishLoading(self, page: nextPageNumber, indexes: [])
        dataDelegate?.listingListMV(self, didFailRetrievingListingsPage: nextPageNumber,
                                               hasListings: hasListings, error: error)
    }

    func selectedItemAtIndex(_ index: Int, thumbnailImage: UIImage?, originFrame: CGRect?) {
        guard let item = itemAtIndex(index) else { return }        
        switch item {
        case .listingCell:
            dataDelegate?.listingListVM(self, didSelectItemAtIndex: index, thumbnailImage: thumbnailImage,
                                        originFrame: originFrame)
        case .collectionCell(let type):
            dataDelegate?.vmDidSelectCollection(type)
        case .emptyCell:
            return
        }
    }
    
    func prefetchItems(atIndexes indexes: [Int]) {
        var urls = [URL]()
        for index in indexes where objects.count < index {
            switch objects[index] {
            case .listingCell(let listing):
                if let thumbnailURL = listing.thumbnail?.fileURL {
                    urls.append(thumbnailURL)
                }
            case .emptyCell, .collectionCell:
                break
            }
        }
        imageDownloader.downloadImagesWithURLs(urls)
    }


    // MARK: > UI

    func clearList() {
        objects = []
        delegate?.vmReloadData(self)
    }
    
    /**
        Returns the Listing at the given index.
    
        - parameter index: The index of the Listing.
        - returns: The Listing.
    */
    func itemAtIndex(_ index: Int) -> ListingCellModel? {
        guard 0..<numberOfListings ~= index else { return nil }
        return objects[index]
    }

    func listingAtIndex(_ index: Int) -> Listing? {
        guard 0..<numberOfListings ~= index else { return nil }
        let item = objects[index]
        switch item {
        case let .listingCell(listing):
            return listing
        case .collectionCell, .emptyCell:
            return nil
        }
    }

    func indexFor(listingId: String) -> Int? {
        return objects.index(where: { cellModel in
            switch cellModel {
            case let .listingCell(listing):
                return listing.objectId == listingId
            case .collectionCell, .emptyCell:
                return false
            }
        })
    }

    /**
        Returns the size of the cell at the given index path.
    
        - parameter index: The index of the Listing.
        - returns: The cell size.
    */
    func sizeForCellAtIndex(_ index: Int) -> CGSize {
        guard let item = itemAtIndex(index) else { return defaultCellSize }
        switch item {
        case let .listingCell(listing):
            guard let thumbnailSize = listing.thumbnailSize, thumbnailSize.height != 0 && thumbnailSize.width != 0
                else { return defaultCellSize }
            
            let thumbFactor = min(ListingListViewModel.cellMaxThumbFactor,
                                  CGFloat(thumbnailSize.height / thumbnailSize.width))
            let imageFinalHeight = max(ListingListViewModel.cellMinHeight, round(defaultCellSize.width * thumbFactor))

            var featuredInfoFinalHeight: CGFloat = 0.0
            if let featured = listing.featured, featured {
                var listingTitleHeight: CGFloat = 0.0
                if let title = listing.title {
                    listingTitleHeight = title.heightForWidth(width: defaultCellSize.width, maxLines: 2, withFont: UIFont.mediumBodyFont)
                }
                featuredInfoFinalHeight = CGFloat(ListingListViewModel.cellFeaturedInfoMinHeight) + listingTitleHeight
            }
            
            var priceViewHeight: CGFloat = 0.0
            priceViewHeight = ListingListViewModel.cellPriceViewHeight

            return CGSize(width: defaultCellSize.width, height: imageFinalHeight+featuredInfoFinalHeight+priceViewHeight)
        case .collectionCell:
            let height = defaultCellSize.width*ListingListViewModel.cellBannerAspectRatio
            return CGSize(width: defaultCellSize.width, height: height)
        case .emptyCell:
            return CGSize(width: defaultCellSize.width, height: 1)
        }
    }
        
    /**
        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page,
        if possible.
    
        - parameter index: The index of the Listing currently visible on screen.
    */
    func setCurrentItemIndex(_ index: Int) {
        guard let itemsPerPage = listingListRequester?.itemsPerPage, numberOfListings > 0 else { return }
        let threshold = numberOfListings - Int(Float(itemsPerPage)*Constants.listingsPagingThresholdPercentage)
        let shouldRetrieveListingsNextPage = index >= threshold && !isOnErrorState
        if shouldRetrieveListingsNextPage {
            retrieveListingsNextPage()
        }
    }

    func titleForIndex(index: Int) -> String? {
        if let lastValidIndex = (indexToTitleMapping.map { $0.key }.filter { $0 <= index }).sorted().last {
            return indexToTitleMapping[lastValidIndex]
        }
        return nil
    }
}


// MARK: - Tracking

extension ListingListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason) {
        let event = TrackerEvent.emptyStateVisit(typePage: .listingList , reason: reason)
        tracker.trackEvent(event)
    }

    func trackVerticalFilterResults(withVerticalTrackingInfo info: VerticalTrackingInfo) {
        let event = TrackerEvent.listingListVertical(category: info.category,
                                                     keywords: info.keywords,
                                                     matchingFields: info.matchingFields,
                                                     nonMatchingFields: info.nonMatchingFields)
        tracker.trackEvent(event)
    }
}
