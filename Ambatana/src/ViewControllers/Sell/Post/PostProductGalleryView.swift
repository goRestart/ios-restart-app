//
//  PostProductGalleryView.swift
//  LetGo
//
//  Created by Eli Kohen on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import Photos

protocol PostProductGalleryViewDelegate: class {
    func productGalleryCloseButton()
    func productGalleryDidSelectImage(image: UIImage)
    func productGalleryRequestsScroll(request: Bool)
    func productGalleryDidPressTakePhoto()
}

class PostProductGalleryView: UIView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageContainerTop: NSLayoutConstraint!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionGradientView: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var postButton: UIButton!

    private var albumButtonTick = UIImageView()

    // Error & empty
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoSubtitle: UILabel!
    @IBOutlet weak var infoButton: UIButton!


    weak var delegate: PostProductGalleryViewDelegate?
    weak var parentController: UIViewController?

    var usePhotoButtonText: String? {
        set {
            postButton?.setTitle(newValue, forState: UIControlState.Normal)
        }
        get {
            return postButton?.titleForState(UIControlState.Normal)
        }
    }

    private var albums: [PHAssetCollection] = []
    private var photosAsset: PHFetchResult?
    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width -
        (PostProductGalleryView.cellSpacing * (PostProductGalleryView.columnCount + 1))) / PostProductGalleryView.columnCount
    private var headerShown = true
    private var galleryState = GalleryState.Normal {
        didSet {
            updateGalleryState()
        }
    }

    // Drag & state vars
    var dragState: GalleryDragState = .None
    var initialDragPosition: CGFloat = 0
    var currentScrollOffset: CGFloat = 0
    var collapsed = false


    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }


    // MARK: - Public methods

    override func layoutSubviews() {
        super.layoutSubviews()

        if let sublayers = collectionGradientView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.frame = collectionGradientView.bounds
            }
        }
    }

    func viewWillAppear() {
        if photosAsset == nil {
            fetchAlbums()
        }
    }

    func showHeader(show: Bool) {
        guard headerShown != show else { return }
        headerShown = show
        let destinationAlpha: CGFloat = show ? 1.0 : 0.0
        UIView.animateWithDuration(0.2) { [weak self] in
            self?.headerContainer.alpha = destinationAlpha
        }
    }

    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        delegate?.productGalleryCloseButton()
    }

    @IBAction func postButtonPressed(sender: AnyObject) {
        guard let imageSelected = selectedImage.image else { return }
        delegate?.productGalleryDidSelectImage(imageSelected)
    }

    @IBAction func albumButtonPressed(sender: AnyObject) {
        showAlbumsActionSheet()
    }


    // MARK: - Private methods

    private func setupUI() {
        NSBundle.mainBundle().loadNibNamed("PostProductGalleryView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.backgroundColor = UIColor.blackColor()
        addSubview(contentView)

        postButton.setPrimaryStyle()

        let cellNib = UINib(nibName: GalleryImageCell.reusableID, bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: GalleryImageCell.reusableID)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4.0
        }

        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = collectionGradientView.bounds
        collectionGradientView.layer.addSublayer(shadowLayer)

        setupInfoView()

        setupAlbumSelection()
    }

    private func fetchAlbums() {
        checkPermissions() { [weak self] in
            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
            let collection: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any,
                options: userAlbumsOptions)
            self?.albums = []
            var newAlbums: [PHAssetCollection] = []
            for i in 0..<collection.count {
                guard let assetCollection = collection[i] as? PHAssetCollection else { continue }
                newAlbums.append(assetCollection)
            }
            self?.albums = newAlbums
            if newAlbums.isEmpty {
                self?.photosAsset = nil
            }
            self?.selectLastAlbumSelected()
        }
    }

    private func selectItem(index: Int, scroll: Bool) {
        guard let photosAsset = photosAsset where 0..<photosAsset.count ~= index else { return }
        imageAtIndex(index, size: nil) { [weak self] image in
            self?.selectedImage.image = image

            let scrollPosition: UICollectionViewScrollPosition = scroll ? .CenteredVertically : .None
            self?.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: true,
                scrollPosition: scrollPosition)
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


// MARK: - Dragging

enum GalleryDragState {
    case None, DraggingCollection(Bool), DraggingImage
}

extension PostProductGalleryView: UIGestureRecognizerDelegate {

    var imageContainerMaxHeight: CGFloat {
        return imageContainer.height-52
    }

    var imageContainerStateThreshold: CGFloat {
        return 50
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panRecognizer.velocityInView(contentView)
        return fabs(velocity.y) > fabs(velocity.x)
    }

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(contentView)

        switch recognizer.state {
        case .Began:
            if location.y < imageContainer.height+imageContainerTop.constant {
                dragState = .DraggingImage
            } else {
                dragState = .DraggingCollection(false)
            }
            initialDragPosition = imageContainerTop.constant
            currentScrollOffset = collectionView.contentOffset.y
            delegate?.productGalleryRequestsScroll(true)
        case .Ended:
            dragState = .None
            finishAnimating()
            delegate?.productGalleryRequestsScroll(false)
        default:
            handleDrag(recognizer)
        }
    }

    private func handleDrag(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(contentView)
        let translation = recognizer.translationInView(contentView)
        switch dragState {
        case .DraggingImage:
            imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
        case .DraggingCollection(let fromTop):
            if location.y < imageContainer.height+imageContainerTop.constant {
                imageContainerTop.constant = max(min(0, -(imageContainer.height-20-location.y)), -imageContainerMaxHeight)
                collectionView.contentOffset.y = currentScrollOffset
            } else if (imageContainerTop.constant < 0) && (collectionView.contentOffset.y <= 0 || fromTop) {
                imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
                dragState = .DraggingCollection(true)
                collectionView.contentOffset.y = currentScrollOffset
            } else  {
                currentScrollOffset = collectionView.contentOffset.y
                if !fromTop {
                    recognizer.setTranslation(CGPoint(x:0, y:0), inView: contentView)
                }
            }
        case .None:
            break
        }
    }

    private func finishAnimating() {
        if collapsed {
            let shouldExpand = abs(imageContainerTop.constant) < imageContainerMaxHeight-imageContainerStateThreshold
            animateToState(collapsed: !shouldExpand, completion: nil)
        } else {
            let shouldCollapse = abs(imageContainerTop.constant) > imageContainerStateThreshold
            animateToState(collapsed: shouldCollapse, completion: nil)
        }
    }

    private func animateToState(collapsed collapsed: Bool, completion: ((Bool) -> Void)?) {
        let currentValue = imageContainerTop.constant
        imageContainerTop.constant = collapsed ? -imageContainerMaxHeight : 0
        self.collapsed = collapsed

        UIView.animateWithDuration(0.2,
            animations: { [weak self] in
                self?.contentView.layoutIfNeeded()
            }, completion: { [weak self] _ in
                completion?(currentValue != self?.imageContainerTop.constant)
            }
        )
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PostProductGalleryView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosAsset?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            guard let galleryCell = collectionView.dequeueReusableCellWithReuseIdentifier(GalleryImageCell.reusableID,
                forIndexPath: indexPath) as? GalleryImageCell else { return UICollectionViewCell() }
            imageAtIndex(indexPath.row, size: CGSize(width: cellWidth, height: cellWidth)) { image in
                galleryCell.image.image = image
            }
            return galleryCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        imageAtIndex(indexPath.row, size: nil) { [weak self] image in
            self?.animateToState(collapsed: false) { [weak self] changed in
                self?.selectItem(indexPath.row, scroll: changed)
            }
        }
    }
}


// MARK: - Info screen

enum GalleryState {
    case Normal, MissingPermissions(String), Empty
}

extension PostProductGalleryView {

    private func setupInfoView() {
        infoButton.setPrimaryStyle()
    }

    private func checkPermissions(handler: () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case .Authorized:
            handler()
        case .Denied:
            galleryState = .MissingPermissions(LGLocalizedString.productPostGalleryPermissionsSubtitle)
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .Authorized {
                    dispatch_async(dispatch_get_main_queue()) {
                        handler()
                    }
                }
            }
        case .Restricted:
            galleryState = .MissingPermissions(LGLocalizedString.productSellPhotolibraryRestrictedError)
            break
        }

    }

    private func updateGalleryState() {
        switch galleryState {
        case .MissingPermissions(let message):
            showPermissionsDisabled(message)
            albumButton.setTitle(LGLocalizedString.productPostGalleryTab, forState: UIControlState.Normal)
            postButton.hidden = true
        case .Empty:
            showEmptyGallery()
            postButton.hidden = true
        case .Normal:
            infoContainer.hidden = true
            postButton.hidden = false
        }
    }

    private func showPermissionsDisabled(mainMessage: String) {
        infoTitle.text = LGLocalizedString.productPostGalleryPermissionsTitle
        infoSubtitle.text = mainMessage
        infoButton.setTitle(LGLocalizedString.productPostGalleryPermissionsButton, forState: UIControlState.Normal)
        infoContainer.hidden = false
    }

    private func showEmptyGallery() {
        infoTitle.text = LGLocalizedString.productPostEmptyGalleryTitle
        infoSubtitle.text = LGLocalizedString.productPostEmptyGallerySubtitle
        infoButton.setTitle(LGLocalizedString.productPostEmptyGalleryButton, forState: UIControlState.Normal)
        infoContainer.hidden = false
    }

    @IBAction func onInfoButtonPressed(sender: AnyObject) {
        switch galleryState {
        case .MissingPermissions:
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        case .Empty:
            delegate?.productGalleryDidPressTakePhoto()
        case .Normal:
            break
        }
    }
}


// MARK: - Album selection 

extension PostProductGalleryView {

    func setupAlbumSelection() {
        albumButton.setTitle(LGLocalizedString.productPostGalleryTab, forState: UIControlState.Normal)

        albumButtonTick.image = UIImage(named: "ic_down_triangle")?.imageWithRenderingMode(.AlwaysTemplate)
        albumButtonTick.tintColor = UIColor.whiteColor()
        albumButtonTick.translatesAutoresizingMaskIntoConstraints = false
        albumButton.addSubview(albumButtonTick)
        let left = NSLayoutConstraint(item: albumButtonTick, attribute: .Left, relatedBy: .Equal,
            toItem: albumButton.titleLabel, attribute: .Right, multiplier: 1.0, constant: 8)
        let centerV = NSLayoutConstraint(item: albumButtonTick, attribute: .CenterY, relatedBy: .Equal,
            toItem: albumButton, attribute: .CenterY, multiplier: 1.0, constant: 2)
        albumButton.addConstraints([left,centerV])
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
        }
        albumButton.setTitle(title, forState: UIControlState.Normal)
        photosAsset = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
        collectionView.reloadData()

        selectItem(0, scroll: false)

        if photosAsset?.count == 0 {
            galleryState = .Empty
        } else {
            animateToState(collapsed: false, completion: nil)
        }
    }

    private func showAlbumsActionSheet() {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        for assetCollection in albums {
            alert.addAction(UIAlertAction(title: assetCollection.localizedTitle, style: .Default,
                handler: {  [weak self] _ in
                    self?.animateAlbumTickDirectionTop(false)
                    self?.selectAlbum(assetCollection)
                })
            )
        }
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: { [weak self] _ in
            self?.animateAlbumTickDirectionTop(false)
            }
        ))
        animateAlbumTickDirectionTop(true)
        parentController?.presentViewController(alert, animated: true, completion: nil)
    }

    private func animateAlbumTickDirectionTop(top: Bool) {
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.albumButtonTick.transform = CGAffineTransformMakeRotation(top ? CGFloat(M_PI) : 0)
        })
    }
}
