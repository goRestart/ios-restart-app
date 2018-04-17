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
import GoogleMobileAds
import MoPub

protocol ListingListViewModelDelegate: class {
    func vmReloadData(_ vm: ListingListViewModel)
    func vmDidUpdateState(_ vm: ListingListViewModel, state: ViewState)
    func vmDidFinishLoading(_ vm: ListingListViewModel, page: UInt, indexes: [Int])
    func vmReloadItemAtIndexPath(indexPath: IndexPath)
}

protocol ListingListViewModelDataDelegate: class {
    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt, hasListings: Bool,
                         error: RepositoryError)
    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt, withResultsCount resultsCount: Int, hasListings: Bool)
    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?)
    func vmProcessReceivedListingPage(_ Listings: [ListingCellModel], page: UInt) -> [ListingCellModel]
    func vmDidSelectSellBanner(_ type: String)
    func vmDidSelectCollection(_ type: CollectionCellType)
    func vmDidSelectMostSearchedItems()
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
    var isFirstPage: Bool { get }
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

    private let cellMinHeight: CGFloat = 80.0
    private var cellAspectRatio: CGFloat {
        return 198.0 / cellMinHeight
    }
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
    
    let featureFlags: FeatureFlags
    private let myUserRepository: MyUserRepository
    
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
    private(set) var defaultCellSize: CGSize = .zero
    
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
        
    // Tracking
    
    fileprivate let tracker: Tracker
    fileprivate let reporter: CrashlyticsReporter
    
    
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
         reporter: CrashlyticsReporter = CrashlyticsReporter(),
         featureFlags: FeatureFlags = FeatureFlags.sharedInstance,
         myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.objects = (listings ?? []).map(ListingCellModel.init)
        self.pageNumber = 0
        self.refreshing = false
        self.state = .loading
        self.numberOfColumns = numberOfColumns
        self.listingListRequester = requester
        self.tracker = tracker
        self.reporter = reporter
        self.imageDownloader = imageDownloader
        self.indexToTitleMapping = [:]
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
        super.init()
        let cellHeight = cellWidth * cellAspectRatio
        self.defaultCellSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    convenience init(listViewModel: ListingListViewModel, featureFlags: FeatureFlags = FeatureFlags.sharedInstance) {
        self.init(requester: listViewModel.listingListRequester, featureFlags: featureFlags)
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
            trackErrorStateShown(reason: errorReason, errorCode: viewModel.errorCode)
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
                                                       withResultsCount: newListings.count,
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
        case .mostSearchedItems:
            dataDelegate?.vmDidSelectMostSearchedItems()
            return
        case .emptyCell, .dfpAdvertisement, .mopubAdvertisement, .promo:
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
            case .emptyCell, .collectionCell, .dfpAdvertisement, .mopubAdvertisement, .mostSearchedItems, .promo:
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
    
    func imageViewSizeForItem(at index: Int) -> CGSize {
        guard
            let listing = listingAtIndex(index),
            let size = thumbImageViewSize(for: listing,
                                          widthConstraint: cellWidth)
            else {
                return .zero
        }
        return size
    }

    func listingAtIndex(_ index: Int) -> Listing? {
        guard 0..<numberOfListings ~= index else { return nil }
        let item = objects[index]
        switch item {
        case let .listingCell(listing):
            return listing
        case .collectionCell, .emptyCell, .dfpAdvertisement, .mopubAdvertisement, .mostSearchedItems, .promo:
            return nil
        }
    }

    func indexFor(listingId: String) -> Int? {
        return objects.index(where: { cellModel in
            switch cellModel {
            case let .listingCell(listing):
                return listing.objectId == listingId
            case .collectionCell, .emptyCell, .dfpAdvertisement, .mopubAdvertisement, .mostSearchedItems, .promo:
                return false
            }
        })
    }
    
    private func featuredInfoAdditionalCellHeight(for listing: Listing, width: CGFloat, isVariantEnabled: Bool, productDetailDisplayType: AddPriceTitleDistanceToListings) -> CGFloat {
        
        let isMine = listing.isMine(myUserRepository: myUserRepository)
        
        let minHeightForFeaturedListing: CGFloat = isMine ? 0.0 : ListingCellMetrics.ActionButton.totalHeight
        guard isVariantEnabled, let featured = listing.featured, featured else {
            return 0
        }
        var height: CGFloat = minHeightForFeaturedListing
        height += productDetailDisplayType == .infoInImage ? 0 : ListingCellMetrics.getTotalHeightForPriceAndTitleView(listing.title, containerWidth: width)
        return height
    }
    
    private func discardedProductAdditionalHeight(for listing: Listing,
                                                  toHeight height: CGFloat,
                                                  variant: DiscardedProducts) -> CGFloat {
        let minCellHeight: CGFloat = ListingCellMetrics.minThumbnailHeightWithContent
        guard listing.status.isDiscarded, variant.isActive, height < minCellHeight else { return 0 }
        return minCellHeight - height
    }
    
    private func additionalImageHeightWithProductDetail(for listing: Listing,
                                                  toHeight height: CGFloat,
                                                  variant: AddPriceTitleDistanceToListings) -> CGFloat {
        let minCellHeight: CGFloat = ListingCellMetrics.minThumbnailHeightWithContent
        guard variant.showDetailInImage, height < minCellHeight else { return 0 }
        return minCellHeight - height
    }
    
    private func normalCellAdditionalHeight(for listing: Listing,
                                            width: CGFloat,
                                            variant: AddPriceTitleDistanceToListings) -> CGFloat {
        if let isFeatured = listing.featured, isFeatured { return 0 }
        guard variant.showDetailInNormalCell else { return 0 }
        return ListingCellMetrics.getTotalHeightForPriceAndTitleView(listing.title, containerWidth: width)
    }
    
    private func thumbImageViewSize(for listing: Listing, widthConstraint: CGFloat) -> CGSize? {
        let maxPortraitAspectRatio = AspectRatio.w1h2
        let addPriceInPhotoFlag = featureFlags.addPriceTitleDistanceToListings
        let minCellHeight: CGFloat = addPriceInPhotoFlag.showDetailInImage ? ListingCellMetrics.minThumbnailHeightWithContent : 80.0
        
        guard let originalThumbSize = listing.thumbnailSize?.toCGSize, originalThumbSize.height != 0 && originalThumbSize.width != 0 else {
            return nil
        }
        let originalThumbnailAspectRatio = AspectRatio(size: originalThumbSize)
        let cellAspectRatio: AspectRatio
        if originalThumbnailAspectRatio.isMore(.portrait, than: maxPortraitAspectRatio) {
            cellAspectRatio = maxPortraitAspectRatio
        } else {
            cellAspectRatio = originalThumbnailAspectRatio
        }
        var thumbHeight = round(cellAspectRatio.size(setting: widthConstraint, in: .width).height)
        thumbHeight = max(minCellHeight, thumbHeight)
        let thumbSize = CGSize(width: widthConstraint, height: thumbHeight)
        return thumbSize
    }
    
    private func cellSize(for listing: Listing, widthConstraint: CGFloat) -> CGSize? {
        guard var cellHeight = thumbImageViewSize(for: listing,
                                                  widthConstraint: widthConstraint)?.height else {
            return nil
        }
        cellHeight += featuredInfoAdditionalCellHeight(for: listing,
                                                       width: widthConstraint,
                                                       isVariantEnabled: featureFlags.pricedBumpUpEnabled,
                                                       productDetailDisplayType: featureFlags.addPriceTitleDistanceToListings)
        cellHeight += discardedProductAdditionalHeight(for: listing, toHeight: cellHeight, variant: featureFlags.discardedProducts)
        cellHeight += normalCellAdditionalHeight(for: listing, width: widthConstraint, variant: featureFlags.addPriceTitleDistanceToListings)
        let cellSize = CGSize(width: widthConstraint, height: cellHeight)
        return cellSize
    }
    
    /**
        Returns the size of the cell at the given index path.
    
        - parameter index: The index of the Listing.
        - returns: The cell size.
    */
    func sizeForCellAtIndex(_ index: Int) -> CGSize {
        guard let item = itemAtIndex(index) else { return defaultCellSize }
        let size: CGSize
        switch item {
        case let .listingCell(listing):
            size = cellSize(for: listing, widthConstraint: cellWidth) ?? defaultCellSize
        case .collectionCell:
            let bannerAspectRatio = AspectRatio.w4h3
            size = bannerAspectRatio.size(setting: cellWidth, in: .width)
        case .emptyCell:
            size = CGSize(width: cellWidth, height: 1)
        case .dfpAdvertisement(let adData):
            guard adData.adPosition == index else { return CGSize(width: cellWidth, height: 0) }
            size = CGSize(width: cellWidth, height: adData.bannerHeight)
        case .mopubAdvertisement(let adData):
            guard adData.adPosition == index else { return CGSize(width: cellWidth, height: 0) }
            size = CGSize(width: cellWidth, height: adData.bannerHeight)
        case .mostSearchedItems:
            return CGSize(width: cellWidth, height: MostSearchedItemsListingListCell.height)
        case .promo:
            return CGSize(width: cellWidth, height: PromoCellMetrics.height)
        }
        return size
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

    func categoriesForBannerIn(position: Int) -> [ListingCategory]? {
        guard 0..<objects.count ~= position else { return nil }
        var categories: [ListingCategory]? = nil
        let cellModel = objects[position]
        switch cellModel {
        case .dfpAdvertisement(let data):
            categories = data.categories
        case .mopubAdvertisement(let data):
            categories = data.categories
        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .promo:
            break
        }
        return categories
    }

    func updateAdvertisementRequestedIn(position: Int, bannerView: GADBannerView) {
        guard 0..<objects.count ~= position else { return }
        let modelToBeUpdated = objects[position]
        switch modelToBeUpdated {
        case .dfpAdvertisement(let data):
            guard data.adPosition == position else { return }
                let newAdData = AdvertisementDFPData(adUnitId: data.adUnitId,
                                                     rootViewController: data.rootViewController,
                                                     adPosition: data.adPosition,
                                                     bannerHeight: data.bannerHeight,
                                                     showAdsInFeedWithRatio: data.showAdsInFeedWithRatio,
                                                     adRequested: true,
                                                     categories: data.categories,
                                                     adRequest: data.adRequest,
                                                     bannerView: bannerView)
                objects[position] = ListingCellModel.dfpAdvertisement(data: newAdData)

        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .mopubAdvertisement, .promo:
            break
        }
    }
    
    func updateAdvertisementRequestedIn(position: Int, moPubNativeAd: MPNativeAd?, moPubView: UIView) {
        guard 0..<objects.count ~= position else { return }
        let modelToBeUpdated = objects[position]
        switch modelToBeUpdated {
        case .mopubAdvertisement(let data):
            guard data.adPosition == position else { return }
            let newAdData = AdvertisementMoPubData(adUnitId: data.adUnitId,
                                                   rootViewController: data.rootViewController,
                                                   adPosition: data.adPosition,
                                                   bannerHeight: data.bannerHeight,
                                                   showAdsInFeedWithRatio: data.showAdsInFeedWithRatio,
                                                   adRequested: true,
                                                   categories: data.categories,
                                                   nativeAdRequest: data.nativeAdRequest,
                                                   moPubNativeAd: moPubNativeAd,
                                                   moPubView: moPubView)
            objects[position] = ListingCellModel.mopubAdvertisement(data: newAdData)
            
        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .dfpAdvertisement, .promo:
            break
        }
    }
}


// MARK: - Tracking

extension ListingListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason, errorCode: Int?) {
        let event = TrackerEvent.emptyStateVisit(typePage: .listingList , reason: reason, errorCode: errorCode)
        tracker.trackEvent(event)

        reporter.report(CrashlyticsReporter.appDomain,
                        code: errorCode ?? 0,
                        message: "Listing list empty state shown -> \(reason.rawValue)")
    }

    func trackVerticalFilterResults(withVerticalTrackingInfo info: VerticalTrackingInfo) {
        let event = TrackerEvent.listingListVertical(category: info.category,
                                                     keywords: info.keywords,
                                                     matchingFields: info.matchingFields,
                                                     nonMatchingFields: info.nonMatchingFields)
        tracker.trackEvent(event)
    }
}

extension ListingListViewModel {
    func updateAdCellHeight(newHeight: CGFloat, forPosition: Int, withBannerView bannerView: GADBannerView) {
        guard 0..<objects.count ~= forPosition else { return }
        let modelToBeUpdated = objects[forPosition]
        switch modelToBeUpdated {
        case .dfpAdvertisement(let data):
            guard data.adPosition == forPosition else { return }
                let newAdData = AdvertisementDFPData(adUnitId: data.adUnitId,
                                                  rootViewController: data.rootViewController,
                                                  adPosition: data.adPosition,
                                                  bannerHeight: newHeight,
                                                  showAdsInFeedWithRatio: data.showAdsInFeedWithRatio,
                                                  adRequested: data.adRequested,
                                                  categories: data.categories,
                                                  adRequest: data.adRequest,
                                                  bannerView: bannerView)
                objects[forPosition] = ListingCellModel.dfpAdvertisement(data: newAdData)
                delegate?.vmReloadItemAtIndexPath(indexPath: IndexPath(item: forPosition, section: 0))
        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .mopubAdvertisement, .promo:
            break
        }
    }

    func bannerWasTapped(adType: EventParameterAdType,
                         willLeaveApp: EventParameterBoolean,
                         categories: [ListingCategory]?,
                         feedPosition: EventParameterFeedPosition) {
        let trackerEvent = TrackerEvent.adTapped(listingId: nil,
                                                 adType: adType,
                                                 isMine: .notAvailable,
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: willLeaveApp,
                                                 typePage: .listingList,
                                                 categories: categories,
                                                 feedPosition: feedPosition)
        tracker.trackEvent(trackerEvent)
    }
}
