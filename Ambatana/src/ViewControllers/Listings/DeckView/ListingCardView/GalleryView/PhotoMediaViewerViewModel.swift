import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class PhotoMediaViewerViewModel {
    private let tag: Int
    private var media: [Media] = []
    private let backgroundColor: UIColor
    private let placeholderImage: UIImage?
    private let imageDownloader: ImageDownloaderType

    fileprivate let indexRelay = BehaviorRelay<Int>(value: 0)
    let datasource: PhotoMediaViewerViewDataSource

    init(tag: Int,
         media: [Media],
         backgroundColor: UIColor,
         placeholderImage: UIImage?,
         imageDownloader: ImageDownloaderType) {
        self.tag = tag
        self.media = media
        self.backgroundColor = backgroundColor
        self.placeholderImage = placeholderImage
        self.imageDownloader = imageDownloader

        datasource = PhotoMediaViewerViewDataSource(
            media: media,
            imageDownloader: imageDownloader,
            backgroundColor: backgroundColor,
            placeholderImage: placeholderImage
        )
    }

    func setIndex(_ index: Int) {
        indexRelay.accept(index)
    }
}

extension PhotoMediaViewerViewModel: ReactiveCompatible {}
extension Reactive where Base: PhotoMediaViewerViewModel {
    var index: Driver<Int> { return base.indexRelay.asDriver() }
}
