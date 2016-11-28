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


protocol PostProductGalleryViewModelDelegate: class {
    func vmDidUpdateGallery()
    func vmDidSelectItemAtIndex(index: Int, shouldScroll: Bool)
    func vmDidDeselectItemAtIndex(index: Int)
    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction])
}

enum GalleryState {
    case PendingAskPermissions, MissingPermissions(String), Normal, Empty, LoadImageError, Loading
}

enum AlbumSelectionIconState {
    case Down, Up, Hidden
}

class PostProductGalleryViewModel: BaseViewModel {

    var maxImagesSelected: Int {
        return multiSelectionEnabled ? 5 : 1
    }

    var keyValueStorage: KeyValueStorage

    weak var delegate: PostProductGalleryViewModelDelegate?
    weak var galleryDelegate: PostProductGalleryViewDelegate?

    let visible = Variable<Bool>(false)

    let galleryState = Variable<GalleryState>(.Normal)
    let albumTitle = Variable<String>(LGLocalizedString.productPostGalleryTab)
    let albumIconState = Variable<AlbumSelectionIconState>(.Down)
    let imagesSelected = Variable<[UIImage]>([])
    let positionsSelected = Variable<[Int]>([])
    let lastImageSelected = Variable<UIImage?>(nil)
    let imageSelectionEnabled = Variable<Bool>(true)
    let albumButtonEnabled = Variable<Bool>(true)

    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width -
        (PostProductGalleryViewModel.cellSpacing * (PostProductGalleryViewModel.columnCount + 1))) /
        PostProductGalleryViewModel.columnCount

    let multiSelectionEnabled: Bool

    private var albums: [PHAssetCollection] = []
    private var photosAsset: PHFetchResult?

    private var lastImageRequestId: PHImageRequestID?

    var imagesSelectedCount = Variable<Int>(0)

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(multiSelectionEnabled: Bool) {
        self.init(multiSelectionEnabled: multiSelectionEnabled, keyValueStorage: KeyValueStorage.sharedInstance)
    }

    required init(multiSelectionEnabled: Bool, keyValueStorage: KeyValueStorage) {
        self.multiSelectionEnabled = multiSelectionEnabled
        self.keyValueStorage = keyValueStorage
        super.init()
        setupRX()
    }

    override func didBecomeActive(firstTime: Bool) {
        if photosAsset == nil {
            checkPermissionsAndFetch()
        }
    }


    // MARK: - Public methods

    func postButtonPressed() {
        guard !imagesSelected.value.isEmpty else { return }
        galleryDelegate?.productGalleryDidSelectImages(imagesSelected.value)
    }

    var imagesCount: Int {
        return photosAsset?.count ?? 0
    }

    var cellSize: CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func imageForCellAtIndex(index: Int, completion: UIImage? -> Void) {
        let scale = UIScreen.mainScreen().scale
        let size = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        imageAtIndex(index, size: size, handler: completion)
    }

    func imageSelectedAtIndex(index: Int) {
        selectImageAtIndex(index, autoScroll: true)
    }

    func imageDeselectedAtIndex(index: Int) {
        deselectImageAtIndex(index)
    }

    func albumButtonPressed() {
        guard !galleryState.value.missingPermissions else { return }

        var actions: [UIAction] = []
        for assetCollection in albums {
            guard let title = assetCollection.localizedTitle else { continue }
            actions.append(UIAction(interface: .Text(title), action: { [weak self] in
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
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
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
            self?.imagesSelectedCount.value = imgsSelected.count
        }.addDisposableTo(disposeBag)

        imagesSelectedCount.asObservable().bindNext { [weak self] numImgs in
            guard let strongSelf = self else { return }
            if numImgs <= 0 {
                if let title = strongSelf.keyValueStorage.userPostProductLastGalleryAlbumSelected {
                    strongSelf.albumTitle.value = title
                    strongSelf.albumIconState.value = .Down
                    strongSelf.albumButtonEnabled.value = true
                }
            } else if strongSelf.multiSelectionEnabled {
                // build title with num of selected pics
                strongSelf.albumButtonEnabled.value = false
                strongSelf.albumTitle.value =  String(format: LGLocalizedString.productPostGalleryMultiplePicsSelected, numImgs)
                strongSelf.albumIconState.value = .Hidden
            }
        }.addDisposableTo(disposeBag)
    }

    private static func collectAlbumsOfType(type: PHAssetCollectionType,
        subtype: PHAssetCollectionSubtype = .Any) -> [PHAssetCollection] {
            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
            var newAlbums: [PHAssetCollection] = []
            let smartCollection: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(type, subtype: subtype,
                options: nil)
            for i in 0..<smartCollection.count {
                guard let assetCollection = smartCollection[i] as? PHAssetCollection else { continue }
                guard PHAsset.fetchAssetsInAssetCollection(assetCollection, options: userAlbumsOptions).count > 0
                    else { continue }
                newAlbums.append(assetCollection)
            }
            return newAlbums
    }

    private func checkPermissionsAndFetch() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case .Authorized:
            fetchAlbums()
        case .Denied:
            galleryState.value = .MissingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
        case .NotDetermined:
            galleryState.value = .PendingAskPermissions
        case .Restricted:
            galleryState.value = .MissingPermissions(LGLocalizedString.productSellPhotolibraryRestrictedError)
            break
        }
    }

    private func askForPermissionsAndFetch() {
        PHPhotoLibrary.requestAuthorization { newStatus in
            //This is required :(, callback is not on main thread so app would crash otherwise.
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                if newStatus == .Authorized {
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
        var newAlbums = PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
                                                                        subtype: .SmartAlbumUserLibrary)
        newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
            subtype: .SmartAlbumPanoramas))
        newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
            subtype: .SmartAlbumRecentlyAdded))
        newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
            subtype: .SmartAlbumBursts))
        newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
            subtype: .SmartAlbumFavorites))
        if #available(iOS 9.0, *) {
            newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
                subtype: .SmartAlbumSelfPortraits))
            newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.SmartAlbum,
                subtype: .SmartAlbumScreenshots))
        }
        newAlbums.appendContentsOf(PostProductGalleryViewModel.collectAlbumsOfType(.Album))

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
            if let lastName = lastName, albumName = assetCollection.localizedTitle where lastName == albumName {
                selectAlbum(assetCollection)
                return
            }
        }
        selectAlbum(albums[0])
    }

    private func selectAlbum(assetCollection: PHAssetCollection) {

        let title = assetCollection.localizedTitle
        if let title = title {
            keyValueStorage.userPostProductLastGalleryAlbumSelected = title
            albumTitle.value = title
        } else {
            albumTitle.value = LGLocalizedString.productPostGalleryTab
        }
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
        userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosAsset = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: userAlbumsOptions)
        delegate?.vmDidUpdateGallery()

        if photosAsset?.count == 0 {
            galleryState.value = .Empty
        } else {
            galleryState.value = .Normal
            selectImageAtIndex(0, autoScroll: false)
        }
    }

    private func selectImageAtIndex(index: Int, autoScroll: Bool) {
        galleryState.value = .Loading
        lastImageSelected.value = nil
        delegate?.vmDidSelectItemAtIndex(index, shouldScroll: autoScroll)


        let imageRequestId = imageAtIndex(index, size: nil) { [weak self] image in
            guard let strongSelf = self else { return }
            self?.lastImageSelected.value = image

            if let image = image {
                strongSelf.galleryState.value = .Normal
                strongSelf.imagesSelected.value.append(image)
                strongSelf.positionsSelected.value.append(index)

                if strongSelf.multiSelectionEnabled {
                    // Block interaction when 5 images are selected
                    strongSelf.imageSelectionEnabled.value = strongSelf.imagesSelectedCount.value < strongSelf.maxImagesSelected
                } else if strongSelf.imagesSelectedCount.value > strongSelf.maxImagesSelected {
                    // on single selection don't let the array have more than 1 pic
                    strongSelf.imagesSelected.value.removeFirst()
                    strongSelf.positionsSelected.value.removeFirst()
                }
            } else {
                strongSelf.galleryState.value = .LoadImageError
            }
        }
        if let lastId = lastImageRequestId where imageRequestId != lastId {
            PHImageManager.defaultManager().cancelImageRequest(lastId)
        }
        lastImageRequestId = imageRequestId
    }

    private func deselectImageAtIndex(index: Int) {
        guard let selectedImageIndex = positionsSelected.value.indexOf(index) where 0..<imagesSelected.value.count ~= selectedImageIndex else { return }

        imageSelectionEnabled.value = true
        imagesSelected.value.removeAtIndex(selectedImageIndex)
        positionsSelected.value.removeAtIndex(selectedImageIndex)

        if selectedImageIndex == imagesSelected.value.count {
            // just deselected last image selected, we should change the previewed one to the last selected, unless is the 1st one
            let numImgs = imagesSelected.value.count
            if numImgs > 0 {
                lastImageSelected.value = imagesSelected.value[numImgs-1]
            }
        }
        delegate?.vmDidDeselectItemAtIndex(index)
    }

    private func imageAtIndex(index: Int, size: CGSize?, handler: UIImage? -> Void) -> PHImageRequestID? {
        guard let photosAsset = photosAsset, asset = photosAsset[index] as? PHAsset else {
            handler(nil)
            return nil
        }
        let targetSize = size ?? PHImageManagerMaximumSize
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        options.networkAccessAllowed = true

        return PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit,
            options: options, resultHandler: { (result, info) in
                // cancel is handled manually at method "selectImageAtIndex"
                guard let info = info where info[PHImageCancelledKey] == nil else { return }
                handler(result)
        })
    }
}


private extension GalleryState {
    var missingPermissions: Bool {
        switch self {
        case .MissingPermissions, .PendingAskPermissions:
            return true
        case .Normal, .Empty, .LoadImageError, .Loading:
            return false
        }
    }
}
