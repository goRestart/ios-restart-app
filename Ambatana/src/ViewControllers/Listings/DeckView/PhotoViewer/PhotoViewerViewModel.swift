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

    convenience init(with urls: [URL]) {
        self.init(imageDownloader: ImageDownloader.sharedInstance, urls: urls)
    }

    init(imageDownloader: ImageDownloaderType, urls: [URL]) {
        self.urls = urls
        self.imageDownloader = imageDownloader
        super.init()
    }

    func urlsAtIndex(_ index: Int) -> URL? {
        guard index >= 0 && index < urls.count else { return nil }
        return urls[index]
    }

    func dismiss() {
        navigator?.closePhotoViewer()
    }
}
