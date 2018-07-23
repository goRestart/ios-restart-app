import Foundation
import Photos
import RxSwift
import RxCocoa
import LGComponents

struct ImageSelected {
    var image: UIImage? // ABIOS-2195
    var index: Int  // the index in the collection

    init(image: UIImage?, index: Int) {
        self.image = image
        self.index = index
    }
}

enum ImageSelection {
    case nothing, any, all
}

protocol PostListingGalleryViewModelDelegate: class {
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

class PostListingGalleryViewModel: BaseViewModel {

    let maxImagesSelected: Int
    var keyValueStorage: KeyValueStorageable
    var featureFlags: FeatureFlaggeable
    var mediaPermissions: MediaPermissions
    
    let postCategory: PostCategory?
    let isBlockingPosting: Bool

    weak var delegate: PostListingGalleryViewModelDelegate?
    weak var galleryDelegate: PostListingGalleryViewDelegate?

    let visible = Variable<Bool>(false)

    let galleryState = Variable<GalleryState>(.normal)
    let albumTitle = Variable<String>(R.Strings.productPostGalleryTab)
    let albumIconState = Variable<AlbumSelectionIconState>(.down)
    let imagesSelected = Variable<[ImageSelected]>([])
    let lastImageSelected = Variable<UIImage?>(nil)
    var imageSelectionEnabled = true
    let albumButtonEnabled = Variable<Bool>(true)

    var imageSelection: Observable<ImageSelection> {
        return imagesSelected.asObservable().map { [weak self] imagesSelected in
            guard let strongSelf = self else { return .nothing }
            
            if imagesSelected.count >= strongSelf.maxImagesSelected {
                return .all
            } else if imagesSelected.count == 0 {
                return .nothing
            } else {
                return .any
            }
        }
    }
    
    var noImageSubtitleText: String {
        if let category = postCategory, category == .realEstate {
            return R.Strings.realEstateGalleryViewSubtitleParams(maxImagesSelected)
        } else {
            return R.Strings.productPostGallerySelectPicturesSubtitleParams(maxImagesSelected)
        }
    }

    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.main.bounds.size.width -
        (PostListingGalleryViewModel.cellSpacing * (PostListingGalleryViewModel.columnCount + 1))) /
        PostListingGalleryViewModel.columnCount

    var shouldUpdateDisabledCells: Bool = false

    private var albums: [PHAssetCollection] = []
    private var photosAsset: PHFetchResult<PHAsset>?

    private var lastImageRequestId: PHImageRequestID?

    var imagesSelectedCount: Int {
        return imagesSelected.value.count
    }

    let disposeBag = DisposeBag()

    let tracker: Tracker


    // MARK: - Lifecycle

    convenience init(postCategory: PostCategory?, isBlockingPosting: Bool, maxImageSelected: Int) {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  mediaPermissions: LGMediaPermissions(),
                  maxImageSelected: maxImageSelected,
                  postCategory: postCategory,
                  isBlockingPosting: isBlockingPosting,
                  tracker: TrackerProxy.sharedInstance)
    }

    required init(keyValueStorage: KeyValueStorage,
                  featureFlags: FeatureFlags,
                  mediaPermissions: MediaPermissions,
                  maxImageSelected: Int,
                  postCategory: PostCategory?,
                  isBlockingPosting: Bool,
                  tracker: Tracker) {
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.mediaPermissions = mediaPermissions
        self.postCategory = postCategory
        self.isBlockingPosting = isBlockingPosting
        self.maxImagesSelected = maxImageSelected
        self.tracker = tracker
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
        let okImages = imagesSelected.value.compactMap { $0.image }
        guard !okImages.isEmpty else { return }
        galleryDelegate?.listingGalleryDidSelectImages(okImages)
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
        let cancelAction = UIAction(interface: .text(R.Strings.commonCancel), action: { [weak self] in
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
            galleryDelegate?.listingGalleryDidPressTakePhoto()
        case .normal, .loadImageError, .loading:
            break
        }
    }


    // MARK - Private methods

    fileprivate func setupRX() {
        let galleryStateIsNormal: Observable<Bool> = galleryState.asObservable().map {
            switch $0 {
            case .normal:
                return true
            case .missingPermissions, .empty, .pendingAskPermissions, .loading, .loadImageError:
                return false
            }
        }
        let hasImagesSelected = imagesSelected.asObservable().map { $0.count > 0 }
        Observable.combineLatest(galleryStateIsNormal, hasImagesSelected) { $0 && !$1 }.bind { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.albumIconState.value = $0 ? .down : .hidden
        }.disposed(by: disposeBag)

        galleryState.asObservable().subscribeNext{ [weak self] state in
            switch state {
            case .missingPermissions:
                self?.albumTitle.value = R.Strings.productPostGalleryTab
            case .pendingAskPermissions, .loading, .loadImageError, .normal, .empty:
                break
            }
        }.disposed(by: disposeBag)

        visible.asObservable().distinctUntilChanged().filter{ $0 }
            .subscribeNext{ [weak self] _ in self?.didBecomeVisible() }
            .disposed(by: disposeBag)

        imagesSelected.asObservable().bind { [weak self] imgsSelected in
            let numImgs = imgsSelected.count
            guard let strongSelf = self else { return }
            if numImgs < 1 {
                if let title = strongSelf.keyValueStorage[.postListingLastGalleryAlbumSelected] {
                    strongSelf.albumTitle.value = title
                    strongSelf.albumButtonEnabled.value = true
                }
                strongSelf.lastImageSelected.value = nil
            } else {
                // build title with num of selected pics
                strongSelf.albumButtonEnabled.value = false
                strongSelf.albumTitle.value = R.Strings.productPostGalleryMultiplePicsSelected(numImgs)
            }
        }.disposed(by: disposeBag)
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
        let status = mediaPermissions.libraryAuthorizationStatus
        switch (status) {
        case .authorized:
            fetchAlbums()
        case .denied:
            galleryState.value = .missingPermissions(R.Strings.productPostGalleryPermissionsSubtitle)
        case .notDetermined:
            galleryState.value = .pendingAskPermissions
        case .restricted:
            galleryState.value = .missingPermissions(R.Strings.productSellPhotolibraryRestrictedError)
            break
        }
    }

    private func askForPermissionsAndFetch() {
        
        mediaPermissions.requestLibraryAuthorization { newStatus in
            //This is required :(, callback is not on main thread so app would crash otherwise.
            DispatchQueue.main.async { [weak self] in
                if newStatus == .authorized {
                    self?.fetchAlbums()
                    self?.trackPermissionsGrant()
                } else {
                    self?.galleryState.value =
                        .missingPermissions(R.Strings.productPostGalleryPermissionsSubtitle)
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
        var newAlbums = PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                                                                        subtype: .smartAlbumUserLibrary)
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumPanoramas))
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumRecentlyAdded))
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
            subtype: .smartAlbumBursts))
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                                                                                     subtype: .smartAlbumFavorites))
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                                                                                     subtype: .smartAlbumSelfPortraits))
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.smartAlbum,
                                                                                     subtype: .smartAlbumScreenshots))
        newAlbums.append(contentsOf: PostListingGalleryViewModel.collectAlbumsOfType(.album))

        albums = newAlbums
        if albums.isEmpty {
            galleryState.value = .empty
            photosAsset = nil
        }
        selectLastAlbumSelected()
    }

    private func selectLastAlbumSelected() {
        guard !albums.isEmpty else { return }
        let lastName = keyValueStorage[.postListingLastGalleryAlbumSelected]
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

            keyValueStorage[.postListingLastGalleryAlbumSelected] = title
            albumTitle.value = title
        } else {
            albumTitle.value = R.Strings.productPostGalleryTab
        }
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosAsset = PHAsset.fetchAssets(in: assetCollection, options: userAlbumsOptions)
        
        if photosAsset?.count == 0 {
            galleryState.value = .empty
        } else {
            galleryState.value = .normal
        }
    }

    private func selectImageAtIndex(_ index: Int, autoScroll: Bool) {
        galleryState.value = .loading
        lastImageSelected.value = nil
        delegate?.vmDidSelectItemAtIndex(index, shouldScroll: autoScroll)

        imageSelectionEnabled = false

        let imageRequestId = imageAtIndex(index, size: nil) { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.lastImageSelected.value = image
            strongSelf.imageSelectionEnabled = true

            if let image = image {
                strongSelf.shouldUpdateDisabledCells = strongSelf.imagesSelected.value.count == strongSelf.maxImagesSelected - 1
                strongSelf.imagesSelected.value.append(ImageSelected(image: image, index: index))
                // Block interaction when 5 images are selected
                strongSelf.imageSelectionEnabled = strongSelf.imagesSelectedCount < strongSelf.maxImagesSelected
                strongSelf.galleryState.value = .normal
            } else {
                // ABIOS-2195
                strongSelf.imagesSelected.value.append(ImageSelected(image: image, index: index))
                // in multiple selection, we don't want to show as selected only the images that were loaded
                for imgSelected in strongSelf.imagesSelected.value {
                    if imgSelected.image == nil {
                        strongSelf.deselectImageAtIndex(imgSelected.index)
                    }
                }
                strongSelf.galleryState.value = .loadImageError
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

        imageSelectionEnabled = true

        shouldUpdateDisabledCells = imagesSelected.value.count == maxImagesSelected
        imagesSelected.value.remove(at: selectedImageIndex)
        imageSelectionEnabled = imagesSelectedCount < maxImagesSelected
        galleryState.value = .normal

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

extension PostListingGalleryViewModel {

    private func trackPermissionsGrant() {
        tracker.trackEvent(TrackerEvent.listingSellPermissionsGrant(type: .camera))
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
