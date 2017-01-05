//
//  AlamofireImage+ImageDownloaderType.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import AlamofireImage

extension AlamofireImage.ImageDownloader: ImageDownloaderType {

    func setImageView(_ imageView: UIImageView, url: URL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        let requestURL = URLRequest(url: url)
        let cached = imageIsCachedForURLRequest(requestURL)
        imageView.af_setImageWithURL(url, placeholderImage: placeholderImage, imageTransition: .None) { response in

            let result: ResultResult<ImageWithSource, NSError>.t
            if let image = response.result.value {
                result = ResultResult<ImageWithSource, NSError>.t(value: (image, cached))
            } else if let error = response.result.error {
                result = ResultResult<ImageWithSource, NSError>.t(error: error)
            } else {
                result = ResultResult<ImageWithSource, NSError>.t(error: NSError(code: .ImageDownloadFailed))
            }
            completion?(result: result, url: url)
        }
    }

    func downloadImageWithURL(_ url: URL, completion: ImageDownloadCompletion? = nil) -> RequestReceipt? {
        let requestURL = URLRequest(url: url)
        let cached = imageIsCachedForURLRequest(requestURL)
        return downloadImage(URLRequest: requestURL) { response in
            
            let result: ResultResult<ImageWithSource, NSError>.t
            if let image = response.result.value {
                result = ResultResult<ImageWithSource, NSError>.t(value: (image, cached))
            } else if let error = response.result.error {
                result = ResultResult<ImageWithSource, NSError>.t(error: error)
            } else {
                result = ResultResult<ImageWithSource, NSError>.t(error: NSError(code: .ImageDownloadFailed))
            }
            completion?(result: result, url: url)
        }
    }

    func cachedImageForUrl(_ url: URL) -> UIImage? {
        let requestURL = URLRequest(url: url)
        let identifier = requestURL.URLRequest.URLString
        return imageCache?.imageWithIdentifier(identifier)
    }

    func cancelImageDownloading(_ receipt: RequestReceipt) {
        cancelRequestForRequestReceipt(receipt)
    }
    
    private func imageIsCachedForURLRequest(_ requestURL: URLRequest) -> Bool {
        let identifier = requestURL.URLRequest.URLString
        let cached = imageCache?.imageWithIdentifier(identifier) != nil
        return cached
    }
}
