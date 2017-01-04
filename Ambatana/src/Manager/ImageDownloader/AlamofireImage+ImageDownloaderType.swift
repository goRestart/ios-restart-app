//
//  AlamofireImage+ImageDownloaderType.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import AlamofireImage

extension AlamofireImage.ImageDownloader: ImageDownloaderType {

    func setImageView(_ imageView: UIImageView, url: NSURL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        let URLRequest = NSURLRequest(url: url as URL)
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

    func downloadImageWithURL(_ url: NSURL, completion: ImageDownloadCompletion? = nil) -> RequestReceipt? {
        let URLRequest = NSURLRequest(url: url as URL)
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

    func cachedImageForUrl(_ url: NSURL) -> UIImage? {
        let URLRequest = NSURLRequest(url: url as URL)
        let identifier = URLRequest.URLRequest.URLString
        return imageCache?.imageWithIdentifier(identifier)
    }

    func cancelImageDownloading(_ receipt: RequestReceipt) {
        cancelRequestForRequestReceipt(receipt)
    }
    
    private func imageIsCachedForURLRequest(_ URLRequest: NSURLRequest) -> Bool {
        let identifier = URLRequest.URLRequest.URLString
        let cached = imageCache?.imageWithIdentifier(identifier) != nil
        return cached
    }
}
