import Result
import AlamofireImage

public typealias ImageWithSource = (image: UIImage, cached: Bool)
public typealias ImageDownloadResult = Result<ImageWithSource, ImageDownloadError>
public typealias ImageDownloadCompletion = (_ result: ImageDownloadResult, _ url: URL) -> Void

public enum ImageDownloadError: Error {
    case downloaderError(error: Error)
    case unknown
}

public protocol ImageDownloaderType {
    func setImageView(_ imageView: UIImageView, url: URL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?)
    @discardableResult
    func downloadImageWithURL(_ url: URL, completion: ImageDownloadCompletion?) -> RequestReceipt?
    func downloadImagesWithURLs(_ urls: [URL])
    func cachedImageForUrl(_ url: URL) -> UIImage?
    func cancelImageDownloading(_ receipt: RequestReceipt)
}

public extension ImageDownloaderType {
    func downloadImagesWithURLs(_ urls: [URL]) {
        urls.forEach { downloadImageWithURL($0, completion: nil) }
    }
}
