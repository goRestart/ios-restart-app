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
    private let featureFlags: FeatureFlaggeable

    var isChatEnabled: Bool { return viewerDisplayable.isChatEnabled }
    var isPlayable: Bool { return viewerDisplayable.isPlayable }
    var shouldShowVideos: Bool { return featureFlags.videoPosting.isActive }

    convenience init(with viewerDisplayable: PhotoViewerDisplayable,
                     source: EventParameterListingVisitSource) {
        self.init(imageDownloader: ImageDownloader.sharedInstance,
                  viewerDisplayable: viewerDisplayable,
                  tracker: TrackerProxy.sharedInstance,
                  source: source,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(imageDownloader: ImageDownloaderType,
         viewerDisplayable: PhotoViewerDisplayable,
         tracker: Tracker,
         source: EventParameterListingVisitSource,
         featureFlags: FeatureFlaggeable) {
        self.imageDownloader = imageDownloader
        self.source = source
        self.tracker = tracker
        self.viewerDisplayable = viewerDisplayable
        self.featureFlags = featureFlags
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        tracker.trackEvent(.listingVisitPhotoViewer(viewerDisplayable.listing,
                                                    source: source,
                                                    numberOfPictures: media.count))
    }

    func urlsAtIndex(_ index: Int) -> URL? {
        guard let media = mediaAtIndex(index) else { return nil }
        return media.outputs.image
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
