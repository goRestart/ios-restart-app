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

    mutating func moveToNextPage() {
        next = next + 1
    }
}

struct Prefetching {
    let previousCount: Int
    let nextCount: Int
}

protocol ListingDeckViewModelDelegate: class {

}

final class ListingDeckViewModel: BaseViewModel {

    var pagination: Pagination
    fileprivate(set) var currentIndex: Int = 0 {
        didSet {
            // Just for pagination
            setCurrentIndex(currentIndex)
        }
    }
    var isNextPageAvaiable: Bool { get { return !pagination.isLast } }
    var isLoading = false

    let prefetching: Prefetching
    fileprivate var prefetchingIndexes: [Int] = []

    let objects = CollectionVariable<ListingCarouselCellModel>([])
    var objectChanges: Observable<CollectionChange<ListingCarouselCellModel>> {
        return objects.changesObservable
    }

    fileprivate let source: EventParameterListingVisitSource
    fileprivate let listingListRequester: ListingListRequester
    fileprivate var productsViewModels: [String: ListingViewModel] = [:]
    fileprivate let imageDownloader: ImageDownloaderType
    fileprivate let listingViewModelMaker: ListingViewModelMaker

    weak var delegate: ListingDeckViewModelDelegate?
    var currentListingViewModel: ListingViewModel?
    weak var navigator: ListingDetailNavigator? {
        didSet {
            currentListingViewModel?.navigator = navigator
        }
    }

    fileprivate let disposeBag = DisposeBag()

    convenience init(listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource) {
        let pagination = Pagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 1, nextCount: 3)
        self.init(listing: listing, listingListRequester: listingListRequester, source: source,
                  imageDownloader: ImageDownloader.sharedInstance,
                  listingViewModelMaker: ListingViewModel.ConvenienceMaker(),
                  pagination: pagination, prefetching: prefetching)
    }

    init(listing: Listing,
         listingListRequester: ListingListRequester,
         source: EventParameterListingVisitSource,
         imageDownloader: ImageDownloaderType, listingViewModelMaker: ListingViewModelMaker,
         pagination: Pagination, prefetching: Prefetching) {
        self.imageDownloader = imageDownloader
        self.pagination = pagination
        self.prefetching = prefetching
        self.listingListRequester = listingListRequester
        self.listingViewModelMaker = listingViewModelMaker
        self.source = source


        self.objects.appendContentsOf([listing].flatMap{$0}.map(ListingCarouselCellModel.init))
        self.pagination.isLast = false

        super.init()
        moveToProductAtIndex(0, movement: .initial)
    }

    func moveToProductAtIndex(_ index: Int, movement: CarouselMovement) {
        guard let viewModel = viewModelAt(index: index) else { return }
        currentListingViewModel?.active = false
        currentListingViewModel?.delegate = nil
        currentListingViewModel = viewModel
        //        currentListingViewModel?.delegate = self
        currentListingViewModel?.active = active
        currentIndex = index
        //        setupCurrentProductVMRxBindings(forIndex: index)
        prefetchNeighborsImages(index, movement: movement)

        // Tracking
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

    func listingCellModelAt(index: Int) -> ListingCarouselCellModel? {
        guard 0..<objectCount ~= index else { return nil }
        return objects.value[index]
    }

    fileprivate func listingAt(index: Int) -> Listing? {
        return listingCellModelAt(index: index)?.listing
    }

    private func viewModelAt(index: Int) -> ListingViewModel? {
        guard let listing = listingAt(index: index) else { return nil }
        return viewModelFor(listing: listing)
    }

    private func viewModelFor(listing: Listing) -> ListingViewModel? {
        guard let listingId = listing.objectId else { return nil }
        if let vm = productsViewModels[listingId] {
            return vm
        }
        let vm = listingViewModelMaker.make(listing: listing, visitSource: source)
        vm.navigator = navigator
        productsViewModels[listingId] = vm
        return vm
    }


    // MARK: Paginable

    func retrievePage(_ page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true

        let completion: ListingsRequesterCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let newListings = result.listingsResult.value {
                strongSelf.pagination.moveToNextPage()
                strongSelf.objects.appendContentsOf(newListings.map(ListingCarouselCellModel.init))
                strongSelf.pagination.isLast = strongSelf.listingListRequester.isLastPage(newListings.count)

                if newListings.isEmpty && strongSelf.isNextPageAvaiable {
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
            print("OH MY GOD")
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
