//
//  PostProductGalleryViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

struct ImageSelected {
    var image: UIImage? // TODO: revert to non-optional when doing https://ambatana.atlassian.net/browse/ABIOS-2195
    var index: Int  // the index in the collection

    init(image: UIImage?, index: Int) {
        self.image = image
        self.index = index
    }
}

protocol PostProductGalleryViewModelDelegate: class {
    func vmDidUpdateGallery()
    func vmDidSelectItemAtIndex(_ index: Int, shouldScroll: Bool)
    func vmDidDeselectItemAtIndex(_ index: Int)
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction])
}

enum GalleryState {
    case pendingAskPermissions, missingPermissions(String), normal, empty, loadImageError, loading
}

enum AlbumSelectionIconState {
    case down, up, hidden
}

class PostProductGalleryViewModel: BaseViewModel {

    let maxImagesSelected: Int
    var keyValueStorage: KeyValueStorage

    weak var delegate: PostProductGalleryViewModelDelegate?
    weak var galleryDelegate: PostProductGalleryViewDelegate?

    let visible = Variable<Bool>(false)

    let galleryState = Variable<GalleryState>(.normal)
    let albumTitle = Variable<String>(LGLocalizedString.productPostGalleryTab)
    let albumIconState = Variable<AlbumSelectionIconState>(.down)
    let imagesSelected = Variable<[ImageSelected]>([])
    let lastImageSelected = Variable<UIImage?>(nil)
    let imageSelectionEnabled = Variable<Bool>(true)
    let albumButtonEnabled = Variable<Bool>(true)

    var imageSelectionFull: Observable<Bool> {
        return imagesSelected.asObservable().map { [weak self] imagesSelected in
            guard let strongSelf = self else { return false }
            guard strongSelf.multiSelectionEnabled else { return false }
            return imagesSelected.count >= strongSelf.maxImagesSelected
        }
    }

    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.main.bounds.size.width -
        (PostProductGalleryViewModel.cellSpacing * (PostProductGalleryViewModel.columnCount + 1))) /
        PostProductGalleryViewModel.columnCount

    let multiSelectionEnabled: Bool

    var shouldUpdateDisabledCells: Bool = false

    private var albums: [PHAssetCollection] = []
    private var photosAsset: PHFetchResult<PHAsset>?

    private var lastImageRequestId: PHImageRequestID?

    var imagesSelectedCount: Int {
        return imagesSelected.value.count
    }

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(multiSelectionEnabled: Bool) {
        self.init(multiSelectionEnabled: multiSelectionEnabled, keyValueStorage: KeyValueStorage.sharedInstance)
    }

    required init(multiSelectionEnabled: Bool, keyValueStorage: KeyValueStorage) {
        self.multiSelectionEnabled = multiSelectionEnabled
        self.maxImagesSelected = multiSelectionEnabled ? Constants.maxImageCount : 1
        self.keyValueStorage = keyValueStorage
        super.init()
        setupRX()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if photosAsset == nil {
            checkPermissionsAndFetch()
        }
    }


    // MARK: - Public methods

    func postButtonPressed() {
        let okImages = imagesSelected.value.flatMap { $0.image }
        guard !okImages.isEmpty else { return }
        galleryDelegate?.productGalleryDidSelectImages(okImages)
    }

    var imagesCount: Int {
        return photosAsset?.count ?? 0
    }

    var cellSize: CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func imageForCellAtIndex(_ index: Int, completion: @escaping (UIImage?) -> Void) {
        let scale = UIScreen.main.scale
        let size = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        imageAtIndex(index, size: size, handler: completion)
    }

    func imageSelectedAtIndex(_ index: Int) {
        selectImageAtIndex(index, autoScroll: true)
    }

    func imageDeselectedAtIndex(_ index: Int) {
        deselectImageAtIndex(index)
    }

    func albumButtonPressed() {
        guard !galleryState.value.missingPermissions else { return }

        var actions: [UIAction] = []
        for assetCollection in albums {
            guard let title = assetCollection.localizedTitle else { continue }
            actions.append(UIAction(interface: .text(title), action: { [weak self] in
                self?.albumIconState.value = .down
                self?.selectAlbum(assetCollection)
            }))
        }
        let cancelAction = UIAction(interface: .text(LGLocalizedString.commonCancel), action: { [weak self] in
            self?.albumIconState.value = .down
        })
        albumIconState.value = .up
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }

    func infoButtonPressed() {
        switch galleryState.value {
        case .pendingAskPermissions:
            askForPermissionsAndFetch()
        case .missingPermissions:
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.openURL(settingsUrl)
        case .empty:
            galleryDelegate?.productGalleryDidPressTakePhoto()
        case .normal, .loadImageError, .loading:
            break
        }
    }


    // MARK - Private methods

    fileprivate func setupRX() {
        galleryState.asObservable().subscribeNext{ [weak self] state in
            switch state {
            case .missingPermissions:
                self?.albumTitle.value = LGLocalizedString.productPostGalleryTab
                self?.albumIconState.value = .hidden
            case .normal:
                self?.albumIconState.value = .down
            case .empty:
                self?.albumIconState.value = .hidden
            case .pendingAskPermissions, .loading, .loadImageError:
                break
            }
        }.addDisposableTo(disposeBag)

        visible.asObservable().distinctUntilChanged().filter{ $0 }
            .subscribeNext{ [weak self] _ in self?.didBecomeVisible() }
            .addDisposableTo(disposeBag)

        imagesSelected.asObservable().bindNext { [weak self] imgsSelected in
            let numImgs = imgsSelected.count
            guard let strongSelf = self else { return }
            if numImgs < 1 {
                if let title = strongSelf.keyValueStorage[.postProductLastGalleryAlbumSelected] {
                    strongSelf.albumTitle.value = title
                    strongSelf.albumIconState.value = .down
                    strongSelf.albumButtonEnabled.value = true
                }
                strongSelf.lastImageSelected.value = nil
            } else if strongSelf.multiSelectionEnabled {
                // build title with num of selected pics
                strongSelf.albumButtonEnabled.value = false
                strongSelf.albumTitle.value =  String(format: LGLocalizedString.productPostGalleryMultiplePicsSelected, numImgs)
                strongSelf.albumIconState.value = .hidden
            }
        }.addDisposableTo(disposeBag)
    }

    private static func collectAlbumsOfType(_ type: PHAssetCollectionType,
        subtype: PHAssetCollectionSubtype = .any) -> [PHAssetCollection] {
            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            var newAlbums: [PHAssetCollection] = []
            let smartCollection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype,
                options: nil)
            for i in 0..<smartCollection.count {
                let assetCollection = smartCollection[i]
                guard PHAsset.fetchAssets(in: assetCollection, options: userAlbumsOptions).count > 0 else { continue }
                newAlbums.append(assetCollection)
            }
            return newAlbums
    }

    private func checkPermissionsAndFetch() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case .authorized:
            fetchAlbums()
        case .denied:
            galleryState.value = .missingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
        case .notDetermined:
            galleryState.value = .pendingAskPermissions
        case .restricted:
            galleryState.value = .missingPermissions(LGLocalizedString.productSellPhotolibraryRestrictedError)
            break
        }
    }

    private func askForPermissionsAndFetch() {
        PHPhotoLibrary.requestAuthorization { newStatus in
            //This is required :(, callback is not on main thread so app would crash otherwise.
            DispatchQueue.main.async { [weak self] in
                if newStatus == .authorized {
                    self?.fetchAlbums()
                } else {
                    self?.galleryState.value =
                        .missingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
                }
            }
        }
    }

    private func didBecomeVisible() {
        switch galleryState.value {
        case .pendingAskPermissions:
            askForPermissionsAndFetch()
        case .normal, .empty, .loading, .loadImageError, .missingPermissions:
            break
        }
    }

    private func fetchAlbums() {
        var newAlbums = PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                                                                        subtype: .smartAlbumUserLibrary)
        newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumPanoramas))
        newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumRecentlyAdded))
        newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumBursts))
        newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumFavorites))
        if #available(iOS 9.0, *) {
            newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                subtype: .smartAlbumSelfPortraits))
            newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                subtype: .smartAlbumScreenshots))
        }
        newAlbums.append(contentsOf: PostProductGalleryViewModel.collectAlbumsOfType(.album))

        albums = newAlbums
        if albums.isEmpty {
            galleryState.value = .empty
            photosAsset = nil
        }
        selectLastAlbumSelected()
    }

    private func selectLastAlbumSelected() {
        guard !albums.isEmpty else { return }
        let lastName = keyValueStorage[.postProductLastGalleryAlbumSelected]
        for assetCollection in albums {
            if let lastName = lastName, let albumName = assetCollection.localizedTitle, lastName == albumName {
                selectAlbum(assetCollection)
                return
            }
        }
        selectAlbum(albums[0])
    }

    private func selectAlbum(_ assetCollection: PHAssetCollection) {

        defer {
            delegate?.vmDidUpdateGallery()
        }

        let title = assetCollection.localizedTitle
        if let title = title {

            keyValueStorage[.postProductLastGalleryAlbumSelected] = title
            albumTitle.value = title
        } else {
            albumTitle.value = LGLocalizedString.productPostGalleryTab
        }
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosAsset = PHAsset.fetchAssets(in: assetCollection, options: userAlbumsOptions)

        if photosAsset?.count == 0 {
            galleryState.value = .empty
        } else {
            galleryState.value = .normal
            // for multiple selection we don't select an initial image
            guard !multiSelectionEnabled else { return }
            selectImageAtIndex(0, autoScroll: false)
        }
    }

    private func selectImageAtIndex(_ index: Int, autoScroll: Bool) {
        galleryState.value = .loading
        lastImageSelected.value = nil
        delegate?.vmDidSelectItemAtIndex(index, shouldScroll: autoScroll)

        imageSelectionEnabled.value = false

        let imageRequestId = imageAtIndex(index, size: nil) { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.lastImageSelected.value = image
            strongSelf.imageSelectionEnabled.value = true

            if let image = image {
                strongSelf.shouldUpdateDisabledCells = strongSelf.multiSelectionEnabled &&
                    strongSelf.imagesSelected.value.count == strongSelf.maxImagesSelected - 1
                strongSelf.imagesSelected.value.append(ImageSelected(image: image, index: index))
                if strongSelf.multiSelectionEnabled {
                    // Block interaction when 5 images are selected
                    strongSelf.imageSelectionEnabled.value = strongSelf.imagesSelectedCount < strongSelf.maxImagesSelected
                }
                strongSelf.galleryState.value = .normal
            } else {
                // TODO: load the thumbnail if the image laoding fails
                // https://ambatana.atlassian.net/browse/ABIOS-2195
                strongSelf.imagesSelected.value.append(ImageSelected(image: image, index: index))
                if strongSelf.multiSelectionEnabled {
                    // in multiple selection, we don't want to show as selected only the images that were loaded
                    for imgSelected in strongSelf.imagesSelected.value {
                        if imgSelected.image == nil {
                            strongSelf.deselectImageAtIndex(imgSelected.index)
                        }
                    }
                }
                strongSelf.galleryState.value = .loadImageError
            }
        }
        if let lastId = lastImageRequestId, imageRequestId != lastId {
            PHImageManager.default().cancelImageRequest(lastId)
            guard !imagesSelected.value.isEmpty && !multiSelectionEnabled else { return }
            // on single selection don't let the array have more than 1 pic so we deselect the previous one
            deselectImageAtIndex(imagesSelected.value[0].index)
        }
        lastImageRequestId = imageRequestId
    }

    private func deselectImageAtIndex(_ index: Int) {
        let selectedIndexes: [Int] = imagesSelected.value.map { $0.index }
        guard let selectedImageIndex = selectedIndexes.index(of: index),
            0..<imagesSelectedCount ~= selectedImageIndex else { return }

        imageSelectionEnabled.value = multiSelectionEnabled
        shouldUpdateDisabledCells = multiSelectionEnabled && imagesSelected.value.count == maxImagesSelected

        imagesSelected.value.remove(at: selectedImageIndex)

        if selectedImageIndex == imagesSelected.value.count {
            // just deselected last image selected, we should change the previewed one to the last selected, unless is the 1st one
            let numImgs = imagesSelected.value.count
            if numImgs > 0 {
                lastImageSelected.value = imagesSelected.value[numImgs-1].image
            }
        }
        delegate?.vmDidDeselectItemAtIndex(index)
    }

    @discardableResult
    private func imageAtIndex(_ index: Int, size: CGSize?, handler: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        guard let photosAsset = photosAsset, 0..<photosAsset.count ~= index else {
            handler(nil)
            return nil
        }
        let targetSize = size ?? PHImageManagerMaximumSize
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return PHImageManager.default().requestImage(for: photosAsset[index], targetSize: targetSize, contentMode: .aspectFit,
            options: options, resultHandler: { (result, info) in
                // cancel is handled manually at method "selectImageAtIndex"
                guard let info = info, info[PHImageCancelledKey] == nil else { return }
                handler(result)
        })
    }
}


fileprivate extension GalleryState {
    var missingPermissions: Bool {
        switch self {
        case .missingPermissions, .pendingAskPermissions:
            return true
        case .normal, .empty, .loadImageError, .loading:
            return false
        }
    }
}
