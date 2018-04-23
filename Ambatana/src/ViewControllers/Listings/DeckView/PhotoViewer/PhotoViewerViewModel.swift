//
//  PhotoViewerViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

final class PhotoViewerViewModel: BaseViewModel {

    let imageDownloader: ImageDownloaderType
    var itemsCount: Int { return urls.count }

    private let urls: [URL]
    var navigator: DeckNavigator?
    private let tracker: Tracker
    private let listingViewModel: ListingViewModel
    private var listing: Listing { return listingViewModel.listing.value }
    private let source: EventParameterListingVisitSource

    var isChatEnabled: Bool { return !listingViewModel.isMine }

    convenience init(with listingViewModel: ListingViewModel,
                     source: EventParameterListingVisitSource) {
        self.init(imageDownloader: ImageDownloader.sharedInstance,
                  listingViewModel: listingViewModel,
                  tracker: TrackerProxy.sharedInstance,
                  source: source)
    }

    init(imageDownloader: ImageDownloaderType,
         listingViewModel: ListingViewModel,
         tracker: Tracker,
         source: EventParameterListingVisitSource) {
        self.urls = listingViewModel.productImageURLs.value
        self.imageDownloader = imageDownloader
        self.source = source
        self.tracker = tracker
        self.listingViewModel = listingViewModel
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        tracker.trackEvent(.listingVisitPhotoViewer(listing, source: source, numberOfPictures: urls.count))
    }

    func urlsAtIndex(_ index: Int) -> URL? {
        guard index >= 0 && index < urls.count else { return nil }
        return urls[index]
    }

    func didOpenChat() {
        guard active else { return }
        tracker.trackEvent(.listingVisitPhotoChat(listing, source: source))
    }

    func dismiss() {
        navigator?.closePhotoViewer()
    }
}
