//
//  SDWebImageManager+ImageDownloaderType.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import SDWebImage

extension SDWebImageManager: ImageDownloaderType {
    func setImageView(imageView: UIImageView, url: NSURL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        imageView.sd_setImageWithURL(url, placeholderImage: placeholderImage) { (image, error, cacheType, url) in
            let result: ImageDownloadResult
            if let image = image {
                let cached = cacheType != .None
                result = ImageDownloadResult(value: (image, cached))
            } else if let error = error {
                result = ImageDownloadResult(error: error)
            } else {
                result = ImageDownloadResult(error: NSError(code: .ImageDownloadFailed))
            }
            completion?(result: result, url: url)
        }
    }
    func downloadImageWithURL(url: NSURL, completion: ImageDownloadCompletion? = nil) {
        downloadImageWithURL(url, options: [], progress: nil) {
            (image, error, cacheType, _, url) in
            let result: ImageDownloadResult
            if let image = image {
                let cached = cacheType != .None
                result = ImageDownloadResult(value: (image, cached))
            } else if let error = error {
                result = ImageDownloadResult(error: error)
            } else {
                result = ImageDownloadResult(error: NSError(code: .ImageDownloadFailed))
            }
            completion?(result: result, url: url)
        }
    }
    func cachedImageForUrl(url: NSURL) -> UIImage? {
        guard let key = cacheKeyForURL(url) else { return nil }
        return imageCache?.imageFromMemoryCacheForKey(key)
    }
}
