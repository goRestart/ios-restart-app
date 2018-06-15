import LGComponents
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


final class ListingListViewModel: BaseViewModel {

    private let cellMinHeight: CGFloat = 80.0
    private var cellAspectRatio: CGFloat {
        return 198.0 / cellMinHeight
    }
    var cellWidth: CGFloat {
        return (UIScreen.main.bounds.size.width - (listingListFixedInset*2)) / CGFloat(numberOfColumns)
    }

    var cellStyle: CellStyle = .mainList
    
    var listingListFixedInset: CGFloat = 10.0
    
    // Delegates
    weak var delegate: ListingListViewModelDelegate?
    weak var dataDelegate: ListingListViewModelDataDelegate?
    weak var listingCellDelegate: ListingCellDelegate?
    
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository
    private let imageDownloader: ImageDownloaderType

    // Requesters
    
    /// A list of requester to try in sequence in case the previous
    /// requester returns empty or insufficient results.
    /// If the view model is initialized with a special requester, the
    /// requester will be put as the first and only requester inside this array
    private var requesterSequence: [ListingListRequester] = []
    
    private var currentRequesterIndex: Int = 0
    
    /// *Classic requester*. It is always the first element in
    /// the emptySearchFallbackRequesters list
    var listingListRequester: ListingListRequester? {
        return requesterSequence.first
    }
    
    /// Current fallback requester in use
    var currentActiveRequester: ListingListRequester?
    
    var currentRequesterType: RequesterType? {
        let tuple = requesterFactory?.buildIndexedRequesterList()[safeAt: currentRequesterIndex]
        return tuple?.0
    }
    
    private var requesterFactory: RequesterFactory? {
        didSet {
            requesterSequence = requesterFactory?.buildRequesterList() ?? []
            currentActiveRequester = requesterSequence.first
        }
    }

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
    private(set) var objects: [ListingCellModel] {
        didSet {
            if refreshing && objects.count < oldValue.count  {
                currentRequesterIndex = 0
                delegate?.vmReloadData(self)}
        }
    }
    private var indexToTitleMapping: [Int:String]

    // UI
    private(set) var defaultCellSize: CGSize = .zero
    
    private(set) var isLastPage: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var isOnErrorState: Bool = false
    
    var canRetrieveListings: Bool {
        let requester = featureFlags.emptySearchImprovements.isActive ? currentActiveRequester : listingListRequester
        let requesterCanRetrieve = requester?.canRetrieve() ?? false
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
    private var searchType: SearchType?

    // MARK: - Lifecycle
    
    private init(requester: ListingListRequester?,
                 listings: [Listing]? = nil,
                 numberOfColumns: Int = 2,
                 isPrivateList: Bool = false,
                 tracker: Tracker,
                 imageDownloader: ImageDownloaderType,
                 reporter: CrashlyticsReporter,
                 featureFlags: FeatureFlaggeable,
                 myUserRepository: MyUserRepository,
                 requesterFactory: RequesterFactory? = nil,
                 searchType: SearchType?) {
        self.objects = (listings ?? []).map(ListingCellModel.init)
        self.isPrivateList = isPrivateList
        self.pageNumber = 0
        self.refreshing = false
        self.state = .loading
        self.numberOfColumns = numberOfColumns
        self.tracker = tracker
        self.reporter = reporter
        self.imageDownloader = imageDownloader
        self.indexToTitleMapping = [:]
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
        self.searchType = searchType
        super.init()
        let cellHeight = cellWidth * cellAspectRatio
        self.defaultCellSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    convenience init(requester: ListingListRequester, isPrivateList: Bool = false) {
        self.init(requester: requester,
                  listings: nil,
                  numberOfColumns: 2,
                  isPrivateList: isPrivateList,
                  tracker: TrackerProxy.sharedInstance,
                  imageDownloader: ImageDownloader.sharedInstance,
                  reporter: CrashlyticsReporter(),
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  requesterFactory: nil,
                  searchType: nil)
        requesterSequence = [requester]
        setCurrentFallbackRequester()
    }
    
    convenience init(numberOfColumns: Int,
                     tracker: Tracker,
                     featureFlags: FeatureFlaggeable,
                     requesterFactory: RequesterFactory,
                     searchType: SearchType?) {
        self.init(requester: nil,
                  listings: nil,
                  numberOfColumns: numberOfColumns,
                  isPrivateList: false,
                  tracker: tracker,
                  imageDownloader: ImageDownloader.sharedInstance,
                  reporter: CrashlyticsReporter(),
                  featureFlags: featureFlags,
                  myUserRepository: Core.myUserRepository,
                  requesterFactory: requesterFactory,
                  searchType: searchType)
        self.requesterFactory = requesterFactory
        requesterSequence = requesterFactory.buildRequesterList()
        setCurrentFallbackRequester()
    }
    
    convenience override init() {
        self.init(requester: nil,
                  listings: nil,
                  numberOfColumns: 2,
                  isPrivateList: false,
                  tracker: TrackerProxy.sharedInstance,
                  imageDownloader: ImageDownloader.sharedInstance,
                  reporter: CrashlyticsReporter(),
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  requesterFactory: nil,
                  searchType: nil)
        setCurrentFallbackRequester()
    }
    
    convenience init(requester: ListingListRequester, listings: [Listing]?, numberOfColumns: Int) {
        self.init(requester: requester,
                  listings: listings,
                  numberOfColumns: numberOfColumns,
                  isPrivateList: false,
                  tracker: TrackerProxy.sharedInstance,
                  imageDownloader: ImageDownloader.sharedInstance,
                  reporter: CrashlyticsReporter(),
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  requesterFactory: nil,
                  searchType: nil)
        requesterSequence = [requester]
        setCurrentFallbackRequester()
    }
    
    private func setCurrentFallbackRequester() {
        currentActiveRequester = requesterSequence.first
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
            trackErrorStateShown(reason: errorReason, errorCode: viewModel.errorCode,
                                 errorDescription: viewModel.errorDescription)
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
        retriveListing(isFirstPage: true, featureFlags: featureFlags)
        return true
    }
    
    func retrieveListingsNextPage() {
        if canRetrieveListingsNextPage, let activeRequster = currentActiveRequester {
            retrieveListings(isFirstPage: false, with: [activeRequster])
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

    private var isPrivateList: Bool = false
    var listingInterestState: [String: InterestedState] = [:]

    func update(listing: Listing, interestedState: InterestedState) {
        guard state.isData, let listingId = listing.objectId else { return }
        guard let index = indexFor(listingId: listingId) else { return }
        listingInterestState[listingId] = interestedState

        delegate?.vmReloadItemAtIndexPath(indexPath: IndexPath(row: index, section: 0))
    }

    func interestStateFor(listingAtIndex index: Int) -> InterestedState? {
        guard !isPrivateList else { return .none }
        guard featureFlags.shouldShowIAmInterestedInFeed.isVisible else { return nil }
        guard let listingID = objects[index].listing?.objectId else { return nil }
        return listingInterestState[listingID] ?? .send(enabled: true)
    }

    func prepend(listing: Listing) {
        guard state.isData else { return }
        objects.insert(ListingCellModel(listing: listing), at: 0)
        delegate?.vmReloadData(self)
    }
    
    func prepend(listings: [Listing]) {
        listings.forEach( { prepend(listing: $0) } )
    }

    func delete(listingId: String) {
        guard state.isData else { return }
        guard let index = indexFor(listingId: listingId) else { return }
        objects.remove(at: index)
        delegate?.vmReloadData(self)
    }
    
    func updateFactory(_ newFactory: RequesterFactory?) {
        requesterFactory = newFactory
    }
    
    private func retriveListing(isFirstPage: Bool, featureFlags: FeatureFlaggeable) {
        retrieveListings(isFirstPage: isFirstPage,
                         with: requesterSequence)
    }
    
    private func retrieveListings(isFirstPage: Bool, with requesters: [ListingListRequester]) {
        var requesterList = requesters
        guard !requesterList.isEmpty, let currentRequester = requesterList.first else { return }
        currentActiveRequester = currentRequester
        isLoading = true
        isOnErrorState = false

        if isFirstPage && numberOfListings == 0 {
            state = .loading
            indexToTitleMapping = [:]
        }
        
        let completion: ListingsRequesterCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            let nextPageNumber = isFirstPage ? 0 : strongSelf.pageNumber + 1
            strongSelf.isLoading = false
            
            guard let newListings = result.listingsResult.value else {
                if let error = result.listingsResult.error {
                    strongSelf.processError(error, nextPageNumber: nextPageNumber)
                }
                return
            }

            strongSelf.applyNewListingInfo(hasNewListing: !newListings.isEmpty,
                                           context: result.context,
                                           verticalTracking: result.verticalTrackingInfo)
            let cellModels = strongSelf.mapListingsToCellModels(newListings, pageNumber: nextPageNumber)
            let indexes: [Int] = strongSelf.updateListingIndices(isFirstPage: isFirstPage, with: cellModels)

            strongSelf.pageNumber = nextPageNumber
            let numListing = strongSelf.numberOfListings
            let hasListings = numListing > 0
            strongSelf.isLastPage = currentRequester.isLastPage(newListings.count)
            requesterList.removeFirst()
            if hasListings {
                if strongSelf.featureFlags.shouldUseSimilarQuery(numListing: numListing)
                    && strongSelf.currentRequesterType == .search && strongSelf.searchType != nil {
                    // should only enter after search,
                    // set to nil so that we will never enter here when scrolling up and down
                    strongSelf.searchType = nil
                    strongSelf.currentRequesterIndex += 1
                    if !requesterList.isEmpty {
                        strongSelf.retrieveListings(isFirstPage: isFirstPage, with: requesterList)
                        return
                    }
                }
            } else if !requesterList.isEmpty {
                strongSelf.currentRequesterIndex += 1
                strongSelf.retrieveListings(isFirstPage: isFirstPage, with: requesterList)
                return
            }
            strongSelf.state = .data
            strongSelf.delegate?.vmDidFinishLoading(strongSelf, page: nextPageNumber, indexes: indexes)
            strongSelf.dataDelegate?.listingListVM(strongSelf, didSucceedRetrievingListingsPage: nextPageNumber,
                                                   withResultsCount: newListings.count,
                                                   hasListings: hasListings)
            strongSelf.currentRequesterIndex = 0
        }

        if isFirstPage {
            currentRequester.retrieveFirstPage(completion)
        } else {
            currentRequester.retrieveNextPage(completion)
        }
    }
    
    private func mapListingsToCellModels(_ listings: [Listing], pageNumber: UInt) -> [ListingCellModel] {
        let listingCellModels = listings.map(ListingCellModel.init)
        let cellModels = dataDelegate?.vmProcessReceivedListingPage(listingCellModels, page: pageNumber) ?? listingCellModels
        return cellModels
    }
    
    private func updateListingIndices(isFirstPage: Bool, with cellModels: [ListingCellModel]) -> [Int] {
        let indices: [Int]
        if isFirstPage {
            objects = cellModels
            refreshing = false
            indices = [Int](0 ..< (cellModels.count))
        } else {
            let currentCount = numberOfListings
            objects += cellModels
            indices = [Int](currentCount ..< (currentCount + cellModels.count))
        }
        return indices
    }
    
    private func applyNewListingInfo(hasNewListing: Bool, context: String?, verticalTracking: VerticalTrackingInfo?) {
        guard hasNewListing else { return }
        if let context = context {
            indexToTitleMapping[numberOfListings] = context
        }
        if let verticalTrackingInfo = verticalTracking {
            trackVerticalFilterResults(withVerticalTrackingInfo: verticalTrackingInfo)
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
        case .emptyCell, .dfpAdvertisement, .mopubAdvertisement, .promo, .adxAdvertisement:
            return
        }
    }
    
    func prefetchItems(atIndexes indexes: [Int]) {
        var urls = [URL]()
        for index in indexes where objects.count >= index {
            switch objects[index] {
            case .listingCell(let listing):
                if let thumbnailURL = listing.thumbnail?.fileURL {
                    urls.append(thumbnailURL)
                }
            case .emptyCell, .collectionCell, .dfpAdvertisement, .mopubAdvertisement, .mostSearchedItems, .promo, .adxAdvertisement:
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
        case .collectionCell, .emptyCell, .dfpAdvertisement, .mopubAdvertisement, .mostSearchedItems, .promo, .adxAdvertisement:
            return nil
        }
    }

    func indexFor(listingId: String) -> Int? {
        return objects.index(where: { cellModel in
            switch cellModel {
            case let .listingCell(listing):
                return listing.objectId == listingId
            case .collectionCell, .emptyCell, .dfpAdvertisement, .mopubAdvertisement, .mostSearchedItems, .promo, .adxAdvertisement:
                return false
            }
        })
    }
    
    private func featuredInfoAdditionalCellHeight(for listing: Listing, width: CGFloat, infoInImage: Bool) -> CGFloat {
        var height: CGFloat = actionButtonCellHeight(for: listing)
        height += infoInImage ? 0 : ListingCellMetrics.getTotalHeightForPriceAndTitleView(listing.title, containerWidth: width)
        return height
    }
    
    private func actionButtonCellHeight(for listing: Listing) -> CGFloat {
        let isMine = listing.isMine(myUserRepository: myUserRepository)
        return isMine ? 0.0 : ListingCellMetrics.ActionButton.totalHeight
    }
    
    private func discardedProductAdditionalHeight(for listing: Listing,
                                                  toHeight height: CGFloat) -> CGFloat {
        let minCellHeight: CGFloat = ListingCellMetrics.minThumbnailHeightWithContent
        guard listing.status.isDiscarded, height < minCellHeight else { return 0 }
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
        
        if let isFeatured = listing.featured, isFeatured, featureFlags.pricedBumpUpEnabled {
            if cellStyle == .serviceList {
                cellHeight += actionButtonCellHeight(for: listing)
            } else  {
                cellHeight += featuredInfoAdditionalCellHeight(for: listing,
                                                               width: widthConstraint,
                                                               infoInImage: featureFlags.addPriceTitleDistanceToListings == .infoInImage)
            }
        }
        
        cellHeight += discardedProductAdditionalHeight(for: listing, toHeight: cellHeight)
        
        if cellStyle == .serviceList {
            cellHeight += ListingCellMetrics.getTotalHeightForPriceAndTitleView(listing.title, containerWidth: widthConstraint)
        } else {
            cellHeight += normalCellAdditionalHeight(for: listing, width: widthConstraint,
                                                     variant: featureFlags.addPriceTitleDistanceToListings)
        }
        return CGSize(width: widthConstraint, height: cellHeight)
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
        case .adxAdvertisement(let adData):
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
        let requester = featureFlags.emptySearchImprovements.isActive ? currentActiveRequester : listingListRequester
        guard let itemsPerPage = requester?.itemsPerPage, numberOfListings > 0 else { return }
        let threshold = numberOfListings - Int(Float(itemsPerPage)*SharedConstants.listingsPagingThresholdPercentage)
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
        case .adxAdvertisement(let data):
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
                                                     adRequested: true,
                                                     categories: data.categories,
                                                     adRequest: data.adRequest,
                                                     bannerView: bannerView)
                objects[position] = ListingCellModel.dfpAdvertisement(data: newAdData)

        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .mopubAdvertisement, .promo, .adxAdvertisement:
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
                                                   adRequested: true,
                                                   categories: data.categories,
                                                   nativeAdRequest: data.nativeAdRequest,
                                                   moPubNativeAd: moPubNativeAd,
                                                   moPubView: moPubView)
            objects[position] = ListingCellModel.mopubAdvertisement(data: newAdData)
            delegate?.vmReloadItemAtIndexPath(indexPath: IndexPath(row: position, section: 0))
            
        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .dfpAdvertisement, .promo, .adxAdvertisement:
            break
        }
    }
    
    func updateAdvertisementRequestedIn(position: Int, nativeContentAd: GADNativeContentAd, contentAdView: GADNativeContentAdView) {
        guard 0..<objects.count ~= position else { return }
        let modelToBeUpdated = objects[position]
        switch modelToBeUpdated {
        case .adxAdvertisement(let data):
            guard data.adPosition == position else { return }
            contentAdView.nativeContentAd = nativeContentAd
            let newAdData = AdvertisementAdxData(adUnitId: data.adUnitId,
                                                 rootViewController: data.rootViewController,
                                                 adPosition: data.adPosition,
                                                 bannerHeight: data.bannerHeight,
                                                 adRequested: true,
                                                 categories: data.categories,
                                                 adLoader: data.adLoader,
                                                 adxNativeView: contentAdView)
            objects[position] = ListingCellModel.adxAdvertisement(data: newAdData)
            delegate?.vmReloadItemAtIndexPath(indexPath: IndexPath(row: position, section: 0))
        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .dfpAdvertisement, .mopubAdvertisement, .promo:
            break
        }
    }
}

// MARK: - Tracking

extension ListingListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason, errorCode: Int?, errorDescription: String?) {
        let event = TrackerEvent.emptyStateVisit(typePage: .listingList , reason: reason, errorCode: errorCode,
                                                 errorDescription: errorDescription)
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
                                                  adRequested: data.adRequested,
                                                  categories: data.categories,
                                                  adRequest: data.adRequest,
                                                  bannerView: bannerView)
                objects[forPosition] = ListingCellModel.dfpAdvertisement(data: newAdData)
                delegate?.vmReloadItemAtIndexPath(indexPath: IndexPath(item: forPosition, section: 0))
        case .listingCell, .collectionCell, .emptyCell, .mostSearchedItems, .mopubAdvertisement, .promo, .adxAdvertisement:
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

private extension FeatureFlaggeable {
    func shouldUseSimilarQuery(numListing: Int) -> Bool {
        return emptySearchImprovements.shouldContinueWithSimilarQueries(withCurrentListing: numListing)
    }
}
