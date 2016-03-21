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
    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction])
}

enum GalleryState {
    case MissingPermissions(String), Normal,  Empty
}

enum AlbumSelectionIconState {
    case Down, Up, Hidden
}

class PostProductGalleryViewModel: BaseViewModel {

    weak var delegate: PostProductGalleryViewModelDelegate?
    weak var galleryDelegate: PostProductGalleryViewDelegate?

    let galleryState = Variable<GalleryState>(.Normal)
    let albumTitle = Variable<String>(LGLocalizedString.productPostGalleryTab)
    let albumIconState = Variable<AlbumSelectionIconState>(.Hidden)
    let imageSelected = Variable<UIImage?>(nil)
    let postButtonEnabled = Variable<Bool>(true)

    let infoShown = Variable<Bool>(false)
    let infoTitle = Variable<String>("")
    let infoSubtitle = Variable<String>("")
    let infoButton = Variable<String>("")

    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width -
        (PostProductGalleryViewModel.cellSpacing * (PostProductGalleryViewModel.columnCount + 1))) /
        PostProductGalleryViewModel.columnCount

    private var albums: [PHAssetCollection] = []
    private var photosAsset: PHFetchResult?

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override init() {
        super.init()
        setupRX()
    }

    override func didBecomeActive() {
        if photosAsset == nil {
            fetchAlbums()
        }
    }

    // MARK: - Public methods

    func postButtonPressed() {
        guard let imageSelected = imageSelected.value else { return }
        galleryDelegate?.productGalleryDidSelectImage(imageSelected)
    }

    var imagesCount: Int {
        return photosAsset?.count ?? 0
    }

    var cellSize: CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func imageForCellAtIndex(index: Int, completion: UIImage? -> Void) {
        imageAtIndex(index, size: cellSize, handler: completion)
    }

    func imageSelectedAtIndex(index: Int) {
        selectImageAtIndex(index, autoScroll: true)
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
        case .MissingPermissions:
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        case .Empty:
            galleryDelegate?.productGalleryDidPressTakePhoto()
        case .Normal:
            break
        }
    }


    // MARK - Private methods

    private func setupRX() {
        galleryState.asObservable().subscribeNext{ [weak self] state in
            switch state {
            case .Empty:
                self?.infoTitle.value = LGLocalizedString.productPostEmptyGalleryTitle
                self?.infoSubtitle.value = LGLocalizedString.productPostEmptyGallerySubtitle
                self?.infoButton.value = LGLocalizedString.productPostEmptyGalleryButton
                self?.infoShown.value = true
                self?.postButtonEnabled.value = false
            case .MissingPermissions(let msg):
                self?.infoTitle.value = LGLocalizedString.productPostGalleryPermissionsTitle
                self?.infoSubtitle.value = msg
                self?.infoButton.value = LGLocalizedString.productPostGalleryPermissionsButton
                self?.albumTitle.value = LGLocalizedString.productPostGalleryTab
                self?.albumIconState.value = .Hidden
                self?.infoShown.value = true
                self?.postButtonEnabled.value = false
            case .Normal:
                self?.albumIconState.value = .Down
                self?.infoShown.value = false
                self?.postButtonEnabled.value = true
            }
        }.addDisposableTo(disposeBag)
    }

    private func fetchAlbums() {
        checkPermissions() { [weak self] in
            guard let strongSelf = self else { return }

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

            strongSelf.albums = newAlbums
            if strongSelf.albums.isEmpty {
                strongSelf.galleryState.value = .Empty
                strongSelf.photosAsset = nil
            }
            strongSelf.selectLastAlbumSelected()
        }
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

    private func checkPermissions(handler: () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case .Authorized:
            handler()
        case .Denied:
            galleryState.value = .MissingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                //This is required :(, callback is not on main thread so app would crash otherwise.
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    if newStatus == .Authorized {
                        handler()
                    } else {
                        self?.galleryState.value =
                            .MissingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
                    }
                }
            }
        case .Restricted:
            galleryState.value = .MissingPermissions(LGLocalizedString.productSellPhotolibraryRestrictedError)
            break
        }
    }

    private func selectLastAlbumSelected() {
        guard !albums.isEmpty else { return }
        let lastName = UserDefaultsManager.sharedInstance.loadLastGalleryAlbumSelected()
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
            UserDefaultsManager.sharedInstance.saveLastGalleryAlbumSelected(title)
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
        imageAtIndex(index, size: nil) { [weak self] image in
            self?.imageSelected.value = image
            self?.delegate?.vmDidSelectItemAtIndex(index, shouldScroll: autoScroll)
        }
    }

    private func imageAtIndex(index: Int, size: CGSize?, handler: UIImage? -> Void) {
        guard let photosAsset = photosAsset, asset = photosAsset[index] as? PHAsset else {
            handler(nil)
            return
        }

        let targetSize = size ?? PHImageManagerMaximumSize
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit,
            options: nil, resultHandler: { (result, _) in
                handler(result)
        })
    }
}

private extension GalleryState {
    var missingPermissions: Bool {
        switch self {
        case .MissingPermissions:
            return true
        case .Normal, .Empty:
            return false
        }
    }
}
