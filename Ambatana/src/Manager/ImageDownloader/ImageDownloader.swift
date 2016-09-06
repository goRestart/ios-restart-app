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

    private var currentImagesPool: [RequestReceipt] = []
    
    init(imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
    }

    func setImageView(imageView: UIImageView, url: NSURL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        imageDownloader.setImageView(imageView, url: url, placeholderImage: placeholderImage,
                                     completion: completion)
    }

    func downloadImageWithURL(url: NSURL, completion: ImageDownloadCompletion? = nil) -> RequestReceipt? {
        let receipt = imageDownloader.downloadImageWithURL(url, completion: completion)
        addReceiptToPool(receipt)
        return receipt
    }

    func cachedImageForUrl(url: NSURL) -> UIImage? {
        return imageDownloader.cachedImageForUrl(url)
    }

    func cancelImageDownloading(receipt: RequestReceipt? = nil) {
        imageDownloader.cancelImageDownloading(receipt)
    }

    private func addReceiptToPool(receipt: RequestReceipt?) {
        guard let receipt = receipt else { return }
        if currentImagesPool.count < Constants.imageRequestPoolCapacity {
            currentImagesPool.append(receipt)
        } else {
            cancelImageDownloading(currentImagesPool.first)
            currentImagesPool.removeFirst()
            currentImagesPool.append(receipt)
        }
    }

    private static func buildImageDownloader() -> ImageDownloaderType {
        return AlamofireImage.ImageDownloader.defaultInstance
    }

    static func externalBuildImageDownloader() -> ImageDownloader {
        return ImageDownloader(imageDownloader: AlamofireImage.ImageDownloader())
    }
}

extension UIImageView {
    func lg_setImageWithURL(url: NSURL, placeholderImage: UIImage? = nil, completion: ImageDownloadCompletion? = nil) {
        ImageDownloader.sharedInstance.setImageView(self, url: url, placeholderImage: placeholderImage,
                                                    completion: completion)
    }
}
