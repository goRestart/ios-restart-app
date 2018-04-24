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

protocol PhotoViewerDisplayable {
    var listing: Listing { get }
    var media: [Media] { get }
    var isMine: Bool { get }
    var isPlayable: Bool { get }
    var isChatEnabled: Bool { get }
}

final class PhotoViewerViewModel: BaseViewModel {

    let imageDownloader: ImageDownloaderType
    var itemsCount: Int { return media.count }

    private var media: [Media] { return viewerDisplayable.listing.media }
    var navigator: PhotoViewerNavigator?
    private let tracker: Tracker
    private let source: EventParameterListingVisitSource

    private let viewerDisplayable: PhotoViewerDisplayable

    var isChatEnabled: Bool { return viewerDisplayable.isChatEnabled }
    var isPlayable: Bool { return viewerDisplayable.isPlayable }

    convenience init(with viewerDisplayable: PhotoViewerDisplayable,
                     source: EventParameterListingVisitSource) {
        self.init(imageDownloader: ImageDownloader.sharedInstance,
                  viewerDisplayable: viewerDisplayable,
                  tracker: TrackerProxy.sharedInstance,
                  source: source)
    }

    init(imageDownloader: ImageDownloaderType,
         viewerDisplayable: PhotoViewerDisplayable,
         tracker: Tracker,
         source: EventParameterListingVisitSource) {
        self.imageDownloader = imageDownloader
        self.source = source
        self.tracker = tracker
        self.viewerDisplayable = viewerDisplayable
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        tracker.trackEvent(.listingVisitPhotoViewer(viewerDisplayable.listing,
                                                    source: source,
                                                    numberOfPictures: media.count))
    }

    func urlsAtIndex(_ index: Int) -> URL? {
        return mediaAtIndex(index)?.outputs.imageThumbnail
    }

    func mediaAtIndexIsPlayable(_ index: Int) -> Bool {
        return mediaAtIndex(index)?.isPlayable ?? false
    }

    func mediaAtIndex(_ index: Int) -> Media? {
        guard index >= 0 && index < media.count else { return nil }
        return media[index]
    }

    func didOpenChat() {
        guard active else { return }
        tracker.trackEvent(.listingVisitPhotoChat(viewerDisplayable.listing, source: source))
    }

    func dismiss() {
        navigator?.closePhotoViewer()
    }
}
