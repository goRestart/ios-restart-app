import AlamofireImage
import Result

public final class ImageDownloader: ImageDownloaderType {

    public static let sharedInstance = ImageDownloader.make(usingImagePool: false)
    
    private let imageDownloader: ImageDownloaderType

    private var currentImagesPool: [RequestReceipt] = []
    private var useImagePool: Bool
    
    init(imageDownloader: ImageDownloaderType, useImagePool: Bool) {
        self.imageDownloader = imageDownloader
        self.useImagePool = useImagePool
    }

    public func setImageView(_ imageView: UIImageView, url: URL, placeholderImage: UIImage?,
                      completion: ImageDownloadCompletion?) {
        imageDownloader.setImageView(imageView, url: url, placeholderImage: placeholderImage,
                                     completion: completion)
    }

    @discardableResult
    public func downloadImageWithURL(_ url: URL, completion: ImageDownloadCompletion? = nil) -> RequestReceipt? {
        let receipt = imageDownloader.downloadImageWithURL(url, completion: completion)
        addReceiptToPool(receipt)
        return receipt
    }

    public func cachedImageForUrl(_ url: URL) -> UIImage? {
        return imageDownloader.cachedImageForUrl(url)
    }

    public func cancelImageDownloading(_ receipt: RequestReceipt) {
        imageDownloader.cancelImageDownloading(receipt)
    }

    private func addReceiptToPool(_ receipt: RequestReceipt?) {
        guard let receipt = receipt else { return }
        currentImagesPool.append(receipt)
        if currentImagesPool.count >= SharedConstants.imageRequestPoolCapacity {
            guard let firstReceipt = currentImagesPool.first else { return }
            cancelImageDownloading(firstReceipt)
            currentImagesPool.removeFirst()
        }
    }

    public static func make(usingImagePool: Bool) -> ImageDownloaderType {
        let afImageDownloader = AlamofireImage.ImageDownloader(configuration: makeSessionConfiguration())
        return ImageDownloader(imageDownloader: afImageDownloader, useImagePool: usingImagePool)
    }

    private static func makeSessionConfiguration() -> URLSessionConfiguration {
        let configuration = AlamofireImage.ImageDownloader.defaultURLSessionConfiguration()

        configuration.urlCache = LGUrlCache(
            memoryCapacity: SharedConstants.imagesUrlCacheMemoryCapacity,
            diskCapacity: SharedConstants.imagesUrlCacheDiskCapacity,
            diskPath: "imageCache"
        )

        return configuration
    }
}

public extension UIImageView {
    func lg_setImageWithURL(_ url: URL, placeholderImage: UIImage? = nil, completion: ImageDownloadCompletion? = nil) {
        ImageDownloader.sharedInstance.setImageView(self,
                                                    url: url,
                                                    placeholderImage: placeholderImage,
                                                    completion: completion)
    }
}


public class LGUrlCache: URLCache {
    override public func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return super.cachedResponse(for: request)
    }

    override public func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        super.storeCachedResponse(cachedResponse, for: request)
    }
}
