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

    static let sharedInstance = ImageDownloader(imageDownloader: ImageDownloader.buildImageDownloader(), useImagePool: false)
    private let imageDownloader: ImageDownloaderType

    private var currentImagesPool: [RequestReceipt] = []
    private var useImagePool: Bool
    
    init(imageDownloader: ImageDownloaderType, useImagePool: Bool) {
        self.imageDownloader = imageDownloader
        self.useImagePool = useImagePool
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

    func cancelImageDownloading(receipt: RequestReceipt) {
        imageDownloader.cancelImageDownloading(receipt)
    }

    private func addReceiptToPool(receipt: RequestReceipt?) {
        guard let receipt = receipt else { return }
        currentImagesPool.append(receipt)
        if currentImagesPool.count >= Constants.imageRequestPoolCapacity {
            guard let firstReceipt = currentImagesPool.first else { return }
            cancelImageDownloading(firstReceipt)
            currentImagesPool.removeFirst()
        }
    }

    private static func buildImageDownloader() -> ImageDownloaderType {
        return AlamofireImage.ImageDownloader.defaultInstance
    }

    static func externalBuildImageDownloader(useImagePool: Bool) -> ImageDownloader {
        return ImageDownloader(imageDownloader: AlamofireImage.ImageDownloader(), useImagePool: useImagePool)
    }
}

extension UIImageView {
    func lg_setImageWithURL(url: NSURL, placeholderImage: UIImage? = nil, completion: ImageDownloadCompletion? = nil) {
        ImageDownloader.sharedInstance.setImageView(self, url: url, placeholderImage: placeholderImage,
                                                    completion: completion)
    }
}
