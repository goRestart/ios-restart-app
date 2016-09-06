//
//  ImageDownloaderType.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Result
import AlamofireImage

typealias ImageWithSource = (image: UIImage, cached: Bool)
typealias ImageDownloadResult = Result<ImageWithSource, NSError>
typealias ImageDownloadCompletion = (result: ImageDownloadResult, url: NSURL) -> Void

protocol ImageDownloaderType {
    func setImageView(imageView: UIImageView, url: NSURL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?)
    func downloadImageWithURL(url: NSURL, completion: ImageDownloadCompletion?) -> RequestReceipt?
    func downloadImagesWithURLs(urls: [NSURL])
    func cachedImageForUrl(url: NSURL) -> UIImage?
    func cancelImageDownloading(receipt: RequestReceipt?)
}

extension ImageDownloaderType {
    func downloadImagesWithURLs(urls: [NSURL]) {
        urls.forEach { downloadImageWithURL($0, completion: nil) }
    }
}
