import RxSwift
import LGCoreKit
import LGComponents

class StickersManager {

    static let sharedInstance = StickersManager()

    private let stickersRepository: StickersRepository
    private let imageDownloader: ImageDownloaderType
    private let disposeBag = DisposeBag()

    convenience init() {
        self.init(stickersRepository: Core.stickersRepository, imageDownloader: ImageDownloader.sharedInstance)
    }

    init(stickersRepository: StickersRepository, imageDownloader: ImageDownloaderType) {
        self.stickersRepository = stickersRepository
        self.imageDownloader = imageDownloader
    }

    func setup() {
        setupRx()
    }

    private func setupRx() {
        stickersRepository.stickers
            .map { $0.compactMap { URL(string: $0.url) }
            }.bind { [weak self] urls in
                self?.imageDownloader.downloadImagesWithURLs(urls)
            }.disposed(by: disposeBag)
    }
}
