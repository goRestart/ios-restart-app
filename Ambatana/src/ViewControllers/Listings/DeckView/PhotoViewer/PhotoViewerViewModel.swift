//
//  PhotoViewerViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
final class PhotoViewerViewModel: BaseViewModel {

    private let urls: [URL]
    let imageDownloader: ImageDownloaderType
    var itemsCount: Int { return urls.count }

    convenience init(with urls: [URL], currentIndex: Int) {
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

    func showChat() {
        // TODO: ABIOS-3107
    }
}
