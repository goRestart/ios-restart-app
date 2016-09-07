//
//  StickersManager.swift
//  LetGo
//
//  Created by Eli Kohen on 06/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

class StickersManager {

    static let sharedInstance = StickersManager()

    private let stickersRepository: StickersRepository
    private let imageDownloader: ImageDownloader
    private let disposeBag = DisposeBag()
    private var cachedImageUrls = Set<String>()

    convenience init() {
        self.init(stickersRepository: Core.stickersRepository, imageDownloader: ImageDownloader.sharedInstance)
    }

    init(stickersRepository: StickersRepository, imageDownloader: ImageDownloader) {
        self.stickersRepository = stickersRepository
        self.imageDownloader = imageDownloader
    }

    func setup() {
        setupRx()
    }

    private func setupRx() {
        stickersRepository.stickers.asObservable()
            .map { [weak self] stickers in
                return stickers.map { $0.url }
                                .filter { !(self?.cachedImageUrls.contains($0) ?? true) }
                                .flatMap { NSURL(string: $0) }
            }.bindNext { [weak self] urls in
                self?.imageDownloader.downloadImagesWithURLs(urls)
                urls.forEach { self?.cachedImageUrls.insert($0.absoluteString) }
            }.addDisposableTo(disposeBag)
    }
}
