//
//  AlamofireImage+ImageDownloaderType.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import AlamofireImage

extension AlamofireImage.ImageDownloader: ImageDownloaderType {

    func setImageView(imageView: UIImageView, url: NSURL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        let URLRequest = NSURLRequest(URL: url)
        let cached = imageIsCachedForURLRequest(URLRequest)
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

    func downloadImageWithURL(url: NSURL, completion: ImageDownloadCompletion? = nil) -> RequestReceipt? {
        let URLRequest = NSURLRequest(URL: url)
        let cached = imageIsCachedForURLRequest(URLRequest)
        return downloadImage(URLRequest: URLRequest) { response in
            
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

    func cachedImageForUrl(url: NSURL) -> UIImage? {
        let URLRequest = NSURLRequest(URL: url)
        let identifier = URLRequest.URLRequest.URLString
        return imageCache?.imageWithIdentifier(identifier)
    }

    func cancelImageDownloading(receipt: RequestReceipt?) {
        guard let receipt = receipt else { return }
        cancelRequestForRequestReceipt(receipt)
    }
    
    private func imageIsCachedForURLRequest(URLRequest: NSURLRequest) -> Bool {
        let identifier = URLRequest.URLRequest.URLString
        let cached = imageCache?.imageWithIdentifier(identifier) != nil
        return cached
    }
}
