//
//  ListingDeckViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

struct Pagination {
    let first: Int
    var next: Int
    var isLast: Bool

    func moveToNextPage() -> Pagination {
        let nextPage = next + 1
        return Pagination(first: first, next: nextPage, isLast: isLast)
    }

    static func makePagination(first: Int, next: Int, isLast: Bool) -> Pagination {
        return Pagination(first: first, next: next, isLast: isLast)
    }

    private init(first: Int, next: Int, isLast: Bool) {
        self.first = first
        self.next = next
        self.isLast = isLast
    }
}

struct Prefetching {
    let previousCount: Int
    let nextCount: Int
}

protocol ListingDeckViewModelDelegate: BaseViewModelDelegate {
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?)
    func vmResetBumpUpBannerCountdown()
}

final class ListingDeckViewModel: BaseViewModel {

    var pagination: Pagination
    // Just for pagination

    fileprivate(set) var currentIndex: Int = 0 { didSet { setCurrentIndex(currentIndex) } }
    var isNextPageAvailable: Bool { get { return !pagination.isLast } }
    var isLoading = false

    let prefetching: Prefetching
    fileprivate var prefetchingIndexes: [Int] = []

    let startIndex: Int
    var shouldSyncFirstListing: Bool = false
    fileprivate var trackingIndex: Int?

    let objects = CollectionVariable<ListingCardViewCellModel>([])
    var objectChanges: Observable<CollectionChange<ListingCardViewCellModel>> { return objects.changesObservable }

    let binder: ListingDeckViewModelBinder

    let navBarButtons = Variable<[UIAction]>([])
    let actionButtons = Variable<[UIAction]>([])
    let altActions = Variable<[UIAction]>([])

    // TODO: Need to deifne where we will show this info
    let status = Variable<ListingViewModelStatus>(.pending)
    let isFeatured = Variable<Bool>(false)

    let chatEnabled = Variable<Bool>(false)
    let quickAnswers = Variable<[[QuickAnswer]]>([[]])
    var directChatPlaceholder = Variable<String>("")
    let directChatMessages = CollectionVariable<ChatViewMessage>([])

    let bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)

    fileprivate let source: EventParameterListingVisitSource
    fileprivate let listingListRequester: ListingListRequester
    fileprivate let userRepository: MyUserRepository
    fileprivate var productsViewModels: [String: ListingViewModel] = [:]

    let imageDownloader: ImageDownloaderType // TODO: Fornow
    fileprivate let listingViewModelMaker: ListingViewModelMaker

    weak var delegate: ListingDeckViewModelDelegate?

    var currentListingViewModel: ListingViewModel?
    weak var navigator: ListingDetailNavigator? { didSet { currentListingViewModel?.navigator = navigator } }

    convenience init(listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource) {
        let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 1, nextCount: 3)
        self.init(productListModels: nil,
                  initialListing: listing,
                  listingListRequester: listingListRequester,
                  source: source, imageDownloader: ImageDownloader.make(usingImagePool: true),
                  listingViewModelMaker: ListingViewModel.ConvenienceMaker(),
                  myUserRepository: Core.myUserRepository,
                  pagination: pagination,
                  prefetching: prefetching,
                  shouldSyncFirstListing: false,
                  binder: ListingDeckViewModelBinder())
    }

    convenience init(productListModels: [ListingCellModel]?,
                     initialListing: Listing?,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     imageDownloader: ImageDownloaderType,
                     listingViewModelMaker: ListingViewModelMaker,
                     shouldSyncFirstListing: Bool,
                     binder: ListingDeckViewModelBinder) {
        let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 1, nextCount: 3)
        self.init(productListModels: productListModels,
                  initialListing: initialListing,
                  listingListRequester: listingListRequester,
                  source: source,
                  imageDownloader: imageDownloader,
                  listingViewModelMaker: listingViewModelMaker,
                  myUserRepository: Core.myUserRepository,
                  pagination: pagination,
                  prefetching: prefetching,
                  shouldSyncFirstListing: shouldSyncFirstListing,
                  binder: binder)
    }

    init(productListModels: [ListingCellModel]?,
         initialListing: Listing?,
         listingListRequester: ListingListRequester,
         source: EventParameterListingVisitSource,
         imageDownloader: ImageDownloaderType,
         listingViewModelMaker: ListingViewModelMaker,
         myUserRepository: MyUserRepository,
         pagination: Pagination,
         prefetching: Prefetching,
         shouldSyncFirstListing: Bool,
         binder: ListingDeckViewModelBinder) {
        self.imageDownloader = imageDownloader
        self.pagination = pagination
        self.prefetching = prefetching
        self.listingListRequester = listingListRequester
        self.listingViewModelMaker = listingViewModelMaker
        self.source = source
        self.binder = binder
        self.userRepository = myUserRepository

        if let productListModels = productListModels {
            self.objects.appendContentsOf(productListModels
                .flatMap { $0.listing }
                .flatMap { listingViewModelMaker.make(listing: $0, visitSource: source) })
            self.pagination.isLast = listingListRequester.isLastPage(productListModels.count)
        } else {
            self.objects.appendContentsOf([initialListing]
                .flatMap { $0 }
                .flatMap { listingViewModelMaker.make(listing: $0, visitSource: source) })
            self.pagination.isLast = false
        }
        if let listing = initialListing {
            startIndex = objects.value.index(where: { $0.cardListing.objectId == listing.objectId}) ?? 0
        } else {
            startIndex = 0
        }

        super.init()
        self.shouldSyncFirstListing = shouldSyncFirstListing
        binder.viewModel = self
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            // TODO: ABIOS-3105 https://ambatana.atlassian.net/browse/ABIOS-3105 prepare onboarding
            moveToProductAtIndex(startIndex, movement: .initial)
            if shouldSyncFirstListing {
                syncFirstListing()
            }
        }
        // Tracking
        currentListingViewModel?.trackVisit(.none, source: source, feedPosition: trackingFeedPosition)
    }

    func moveToProductAtIndex(_ index: Int, movement: CarouselMovement) {
        guard let viewModel = viewModelAt(index: index) else { return }
        currentListingViewModel?.active = false
        currentListingViewModel?.delegate = nil
        currentListingViewModel = viewModel
        currentListingViewModel?.delegate = self

        binder.bindTo(listingViewModel: viewModel)
        currentListingViewModel?.active = active

        currentIndex = index
        prefetchNeighborsImages(index, movement: movement)

        // Tracking
        // TODO: ABIOS-3109 https://ambatana.atlassian.net/browse/ABIOS-3109
        //        if active {
        //            let feedPosition = movement.feedPosition(for: trackingIndex)
        //            if source == .relatedListings {
        //                currentListingViewModel?.trackVisit(movement.visitUserAction,
        //                                                    source: movement.visitSource(source),
        //                                                    feedPosition: feedPosition)
        //            } else {
        //                currentListingViewModel?.trackVisit(movement.visitUserAction, source: source, feedPosition: feedPosition)
        //            }
        //        }
    }

    func didTapCardAction() {
        if let isFav = currentListingViewModel?.cardIsFavoritable, isFav {
            currentListingViewModel?.switchFavorite()
        } else {
            currentListingViewModel?.editListing()
        }
    }

    func listingCellModelAt(index: Int) -> ListingCardViewCellModel? {
        guard 0..<objectCount ~= index else { return nil }
        return objects.value[index]
    }

    fileprivate func listingAt(index: Int) -> Listing? {
        return listingCellModelAt(index: index)?.cardListing
    }

    func viewModelAt(index: Int) -> ListingViewModel? {
        guard let listing = listingAt(index: index) else { return nil }
        return viewModelFor(listing: listing)
    }

    func viewModelFor(listing: Listing) -> ListingViewModel? {
        guard let listingId = listing.objectId else { return nil }
        if let vm = productsViewModels[listingId] {
            return vm
        }
        let vm = listingViewModelMaker.make(listing: listing, visitSource: source)
        vm.navigator = navigator
        productsViewModels[listingId] = vm
        return vm
    }

    func performCollectionChange(change: CollectionChange<ChatViewMessage>) {
        switch change {
        case let .insert(index, value):
            directChatMessages.insert(value, atIndex: index)
        case let .remove(index, _):
            directChatMessages.removeAtIndex(index)
        case let .swap(fromIndex, toIndex, replacingWith):
            directChatMessages.swap(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .move(fromIndex, toIndex, replacingWith):
            directChatMessages.move(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .composite(changes):
            for change in changes {
                performCollectionChange(change: change)
            }
        }
    }

    private func syncFirstListing() {
        currentListingViewModel?.syncListing() { [weak self] in
            guard let strongSelf = self else { return }
            guard let listing = strongSelf.currentListingViewModel?.listing.value else { return }
            guard let newModel = strongSelf.viewModelFor(listing: listing) else { return }
            strongSelf.objects.replace(strongSelf.startIndex, with: newModel)
        }
    }

    // MARK: Tracking

    func bumpUpBannerShown(type: BumpUpType) {
        currentListingViewModel?.trackBumpUpBannerShown(type: type,
                                                        storeProductId: currentListingViewModel?.paymentProviderItemId)
    }

    // MARK: Paginable

    func retrievePage(_ page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true

        let completion: ListingsRequesterCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let newListings = result.listingsResult.value {
                strongSelf.pagination = strongSelf.pagination.moveToNextPage()
                let models = newListings.flatMap { strongSelf.viewModelFor(listing: $0) }
                strongSelf.objects.appendContentsOf(models)
                strongSelf.pagination.isLast = strongSelf.listingListRequester.isLastPage(newListings.count)

                if newListings.isEmpty && strongSelf.isNextPageAvailable {
                    strongSelf.retrieveNextPage()
                }
            }
        }

        if isFirstPage {
            listingListRequester.retrieveFirstPage(completion)
        } else {
            listingListRequester.retrieveNextPage(completion)
        }
    }

    func close() {
        navigator?.closeProductDetail()
    }
}

// MARK: ListingViewModelDelegate

extension ListingDeckViewModel: ListingViewModelDelegate {

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        guard let delegate = delegate else { return (UIViewController(), nil) }
        return delegate.vmShareViewControllerAndItem()
    }

    var trackingFeedPosition: EventParameterFeedPosition {
        if let trackingIndex = trackingIndex, currentIndex == startIndex {
            return .position(index: trackingIndex)
        } else {
            return .none
        }
    }

    func vmResetBumpUpBannerCountdown() {
        delegate?.vmResetBumpUpBannerCountdown()
    }

    // BaseViewModelDelegate forwarding methods

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message, completion: completion)
    }
    func vmShowLoading(_ loadingMessage: String?) {
        delegate?.vmShowLoading(loadingMessage)
    }
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        delegate?.vmHideLoading(finishedMessage, afterMessageCompletion: afterMessageCompletion)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelLabel, actions: actions)
    }
    func vmOpenInternalURL(_ url: URL) {
        delegate?.vmOpenInternalURL(url)
    }
    func vmPop() {
        delegate?.vmPop()
    }
    func vmDismiss(_ completion: (() -> Void)?) {
        delegate?.vmDismiss(completion)
    }

}

// MARK: Paginable

extension ListingDeckViewModel: Paginable {
    var objectCount: Int { return objects.value.count }

    var firstPage: Int { return pagination.first }
    var nextPage: Int { return pagination.next }
    var isLastPage: Bool { return pagination.isLast }
}

// MARK: Prefetching images

extension ListingDeckViewModel {

    func prefetchNeighborsImages(_ index: Int, movement: CarouselMovement) {
        let range: CountableClosedRange<Int>
        switch movement {
        case .initial:
            range = (index - prefetching.previousCount)...(index + prefetching.nextCount)
        case .swipeRight:
            range = (index + 1)...(index + prefetching.nextCount)
        case .swipeLeft:
            range = (index - prefetching.previousCount)...(index - 1)
        default:
            range = (index - prefetching.previousCount)...(index + prefetching.nextCount)
        }
        var imagesToPrefetch: [URL] = []
        for index in range {
            guard !prefetchingIndexes.contains(index) else { continue }
            prefetchingIndexes.append(index)
            if let imageUrl = listingAt(index: index)?.images.first?.fileURL {
                imagesToPrefetch.append(imageUrl)
            }
        }
        imageDownloader.downloadImagesWithURLs(imagesToPrefetch)
    }
}
