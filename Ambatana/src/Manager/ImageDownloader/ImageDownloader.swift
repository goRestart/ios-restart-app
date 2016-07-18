//
//  ImageDownloader.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import AlamofireImage
import Result

final class ImageDownloader: ImageDownloaderType {
    static let sharedInstance = ImageDownloader(imageDownloader: ImageDownloader.buildImageDownloader())
    private let imageDownloader: ImageDownloaderType

    init(imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
    }

    func setImageView(imageView: UIImageView, url: NSURL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        imageDownloader.setImageView(imageView, url: url, placeholderImage: placeholderImage,
                                     completion: completion)
    }

    func downloadImageWithURL(url: NSURL, completion: ImageDownloadCompletion? = nil) {
        imageDownloader.downloadImageWithURL(url, completion: completion)
    }

    func cachedImageForUrl(url: NSURL) -> UIImage? {
        return imageDownloader.cachedImageForUrl(url)
    }

    private static func buildImageDownloader() -> ImageDownloaderType {
        return AlamofireImage.ImageDownloader.defaultInstance
    }
}

extension UIImageView {
    func lg_setImageWithURL(url: NSURL, placeholderImage: UIImage? = nil, completion: ImageDownloadCompletion? = nil) {
        ImageDownloader.sharedInstance.setImageView(self, url: url, placeholderImage: placeholderImage,
                                                    completion: completion)
    }
}
