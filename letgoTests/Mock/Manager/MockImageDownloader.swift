//
//  MockImageDownloader.swift
//  LetGo
//
//  Created by Eli Kohen on 02/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import AlamofireImage

class MockImageDownloader: ImageDownloaderType {

    var imageDownloadResult: ImageDownloadResult?
    var cachedImageResults = [URL : UIImage]()
    var downloadImagesRequested: [URL]?

    init() {

    }

    func setImageView(_ imageView: UIImageView, url: URL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {

    }
    @discardableResult
    func downloadImageWithURL(_ url: URL, completion: ImageDownloadCompletion?) -> RequestReceipt? {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { [weak self] in
            guard let result = self?.imageDownloadResult else { return }
            completion?(result, url)
        }
        return nil
    }
    func downloadImagesWithURLs(_ urls: [URL]) {
        downloadImagesRequested = urls
    }
    func cachedImageForUrl(_ url: URL) -> UIImage? {
        return cachedImageResults[url]
    }
    func cancelImageDownloading(_ receipt: RequestReceipt) {

    }
}
