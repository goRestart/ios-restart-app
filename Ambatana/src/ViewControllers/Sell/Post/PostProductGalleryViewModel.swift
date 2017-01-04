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
    var image: UIImage
    var index: Int  // the index in the collection

    init(image: UIImage, index: Int) {
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
    case pendingAskPermissions, MissingPermissions(String), normal, empty, loadImageError, loading
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

    let galleryState = Variable<GalleryState>(.Normal)
    let albumTitle = Variable<String>(LGLocalizedString.productPostGalleryTab)
    let albumIconState = Variable<AlbumSelectionIconState>(.Down)
    let imagesSelected = Variable<[ImageSelected]>([])
    let lastImageSelected = Variable<UIImage?>(nil)
    let imageSelectionEnabled = Variable<Bool>(true)
    let albumButtonEnabled = Variable<Bool>(true)

    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.main.bounds.size.width -
        (PostProductGalleryViewModel.cellSpacing * (PostProductGalleryViewModel.columnCount + 1))) /
        PostProductGalleryViewModel.columnCount

    let multiSelectionEnabled: Bool

    var shouldUpdateDisabledCells: Bool = false

    private var albums: [PHAssetCollection] = []
    private var photosAsset: PHFetchResult<AnyObject>?

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
        guard !imagesSelected.value.isEmpty else { return }
        galleryDelegate?.productGalleryDidSelectImages(imagesSelected.value.map { $0.image })
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
                self?.albumIconState.value = .Down
                self?.selectAlbum(assetCollection)
            }))
        }
        let cancelAction = UIAction(interface: .Text(LGLocalizedString.commonCancel), action: { [weak self] in
            self?.albumIconState.value = .Down
        })
        albumIconState.value = .Up
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }

    func infoButtonPressed() {
        switch galleryState.value {
        case .PendingAskPermissions:
            askForPermissionsAndFetch()
        case .MissingPermissions:
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        case .Empty:
            galleryDelegate?.productGalleryDidPressTakePhoto()
        case .Normal, .LoadImageError, .Loading:
            break
        }
    }


    // MARK - Private methods

    private func setupRX() {
        galleryState.asObservable().subscribeNext{ [weak self] state in
            switch state {
            case .MissingPermissions:
                self?.albumTitle.value = LGLocalizedString.productPostGalleryTab
                self?.albumIconState.value = .Hidden
            case .Normal:
                self?.albumIconState.value = .Down
            case .Empty:
                self?.albumIconState.value = .Hidden
            case .PendingAskPermissions, .Loading, .LoadImageError:
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
                if let title = strongSelf.keyValueStorage.userPostProductLastGalleryAlbumSelected {
                    strongSelf.albumTitle.value = title
                    strongSelf.albumIconState.value = .Down
                    strongSelf.albumButtonEnabled.value = true
                }
                strongSelf.lastImageSelected.value = nil
            } else if strongSelf.multiSelectionEnabled {
                // build title with num of selected pics
                strongSelf.albumButtonEnabled.value = false
                strongSelf.albumTitle.value =  String(format: LGLocalizedString.productPostGalleryMultiplePicsSelected, numImgs)
                strongSelf.albumIconState.value = .Hidden
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
                guard let assetCollection = smartCollection[i] as? PHAssetCollection else { continue }
                guard PHAsset.fetchAssets(in: assetCollection, options: userAlbumsOptions).count > 0
                    else { continue }
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
            galleryState.value = .MissingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
        case .notDetermined:
            galleryState.value = .PendingAskPermissions
        case .restricted:
            galleryState.value = .MissingPermissions(LGLocalizedString.productSellPhotolibraryRestrictedError)
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
                        .MissingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
                }
            }
        }
    }

    private func didBecomeVisible() {
        switch galleryState.value {
        case .PendingAskPermissions:
            askForPermissionsAndFetch()
        case .Normal, .Empty, .Loading, .LoadImageError, .MissingPermissions:
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
            galleryState.value = .Empty
            photosAsset = nil
        }
        selectLastAlbumSelected()
    }

    private func selectLastAlbumSelected() {
        guard !albums.isEmpty else { return }
        let lastName = keyValueStorage.userPostProductLastGalleryAlbumSelected
        for assetCollection in albums {
            if let lastName = lastName, let albumName = assetCollection.localizedTitle, lastName == albumName {
                selectAlbum(assetCollection)
                return
            }
        }
        selectAlbum(albums[0])
    }

    private func selectAlbum(_ assetCollection: PHAssetCollection) {

        let title = assetCollection.localizedTitle
        if let title = title {
            keyValueStorage.userPostProductLastGalleryAlbumSelected = title
            albumTitle.value = title
        } else {
            albumTitle.value = LGLocalizedString.productPostGalleryTab
        }
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosAsset = PHAsset.fetchAssets(in: assetCollection, options: userAlbumsOptions)
        delegate?.vmDidUpdateGallery()

        if photosAsset?.count == 0 {
            galleryState.value = .Empty
        } else {
            galleryState.value = .Normal
            // for multiple selection we don't select an initial image
            guard !multiSelectionEnabled else { return }
            selectImageAtIndex(0, autoScroll: false)
        }
    }

    private func selectImageAtIndex(_ index: Int, autoScroll: Bool) {
        galleryState.value = .Loading
        lastImageSelected.value = nil
        delegate?.vmDidSelectItemAtIndex(index, shouldScroll: autoScroll)


        let imageRequestId = imageAtIndex(index, size: nil) { [weak self] image in
            guard let strongSelf = self else { return }
            self?.lastImageSelected.value = image

            if let image = image {
                strongSelf.galleryState.value = .Normal
                strongSelf.shouldUpdateDisabledCells = strongSelf.multiSelectionEnabled &&
                    strongSelf.imagesSelected.value.count == strongSelf.maxImagesSelected - 1
                strongSelf.imagesSelected.value.append(ImageSelected(image: image, index: index))
                if strongSelf.multiSelectionEnabled {
                    // Block interaction when 5 images are selected
                    strongSelf.imageSelectionEnabled.value = strongSelf.imagesSelectedCount < strongSelf.maxImagesSelected
                } else if strongSelf.imagesSelectedCount > strongSelf.maxImagesSelected {
                    // on single selection don't let the array have more than 1 pic
                    strongSelf.deselectImageAtIndex(strongSelf.imagesSelected.value[0].index)
                }
            } else {
                strongSelf.galleryState.value = .LoadImageError
            }
        }
        if let lastId = lastImageRequestId, imageRequestId != lastId {
            PHImageManager.default().cancelImageRequest(lastId)
        }
        lastImageRequestId = imageRequestId
    }

    private func deselectImageAtIndex(_ index: Int) {
        let selectedIndexes: [Int] = imagesSelected.value.map { $0.index }
        guard let selectedImageIndex = selectedIndexes.index(of: index),
            0..<imagesSelectedCount ~= selectedImageIndex else { return }

        imageSelectionEnabled.value = true
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

    private func imageAtIndex(_ index: Int, size: CGSize?, handler: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        guard let photosAsset = photosAsset, let asset = photosAsset[index] as? PHAsset else {
            handler(nil)
            return nil
        }
        let targetSize = size ?? PHImageManagerMaximumSize
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit,
            options: options, resultHandler: { (result, info) in
                // cancel is handled manually at method "selectImageAtIndex"
                guard let info = info, info[PHImageCancelledKey] == nil else { return }
                handler(result)
        })
    }
}


private extension GalleryState {
    var missingPermissions: Bool {
        switch self {
        case .MissingPermissions, .pendingAskPermissions:
            return true
        case .normal, .empty, .loadImageError, .loading:
            return false
        }
    }
}
