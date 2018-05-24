//
//  AlamofireImage+ImageDownloaderType.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import AlamofireImage
import Alamofire

extension AlamofireImage.ImageDownloader: ImageDownloaderType {

    func setImageView(_ imageView: UIImageView, url: URL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        imageView.af_imageDownloader = self
        let requestURL = URLRequest(url: url)
        let cached = imageIsCachedFor(urlRequest: requestURL)
        imageView.af_setImage(withURL: url, placeholderImage: placeholderImage) { response in
            let result: ImageDownloadResult
            if let image = response.result.value {
                result = ImageDownloadResult(value: (image, cached))
            } else if let error = response.result.error {
                result = ImageDownloadResult(error: ImageDownloadError.downloaderError(error: error))
            } else {
                result = ImageDownloadResult(error: ImageDownloadError.unknown)
            }
            completion?(result, url)
        }
    }

    func downloadImageWithURL(_ url: URL, completion: ImageDownloadCompletion? = nil) -> RequestReceipt? {
        let requestURL = URLRequest(url: url)
        let cached = imageIsCachedFor(urlRequest: requestURL)

        return download(requestURL) { response in
            
            let result: ImageDownloadResult
            if let image = response.result.value {
                result = ImageDownloadResult(value: (image, cached))
            } else if let error = response.result.error {
                result = ImageDownloadResult(error: ImageDownloadError.downloaderError(error: error))
            } else {
                result = ImageDownloadResult(error: ImageDownloadError.unknown)
            }
            completion?(result, url)
        }
    }

    func cachedImageForUrl(_ url: URL) -> UIImage? {
        let request = URLRequest(url: url)
        return imageCache?.image(for: request, withIdentifier: nil)
    }

    func cancelImageDownloading(_ receipt: RequestReceipt) {
        cancelRequest(with: receipt)
    }

    private func imageIsCachedFor(urlRequest: URLRequest) -> Bool {
        let cached = imageCache?.image(for: urlRequest, withIdentifier: nil) != nil
        return cached
    }
}
