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
typealias ImageDownloadResult = Result<ImageWithSource, ImageDownloadError>
typealias ImageDownloadCompletion = (_ result: ImageDownloadResult, _ url: URL) -> Void

enum ImageDownloadError: Error {
    case downloaderError(error: Error)
    case unknown
}

protocol ImageDownloaderType {
    func setImageView(_ imageView: UIImageView, url: URL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?)
    @discardableResult
    func downloadImageWithURL(_ url: URL, completion: ImageDownloadCompletion?) -> RequestReceipt?
    func downloadImagesWithURLs(_ urls: [URL])
    func cachedImageForUrl(_ url: URL) -> UIImage?
    func cancelImageDownloading(_ receipt: RequestReceipt)
}

extension ImageDownloaderType {
    func downloadImagesWithURLs(_ urls: [URL]) {
        urls.forEach { downloadImageWithURL($0, completion: nil) }
    }
}
