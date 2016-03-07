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
}

class PostProductGalleryView: UIView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageContainerTop: NSLayoutConstraint!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postButton: UIButton!

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

    private var assetCollection: PHAssetCollection?
    private var photosAsset: PHFetchResult?
    private static let columnCount: CGFloat = 4
    private static let cellSpacing: CGFloat = 4
    private let cellWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width -
        (PostProductGalleryView.cellSpacing * (PostProductGalleryView.columnCount + 1))) / PostProductGalleryView.columnCount

    // Drag & state vars
    var dragState: GalleryDragState = .None
    var initialDragPosition: CGFloat = 0
    var currentScrollOffset: CGFloat = 0
    var collapsed = false


    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        fetchCollection()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
        fetchCollection()
    }

    func viewWillAppear() {
        fetchAssets()
    }

    func viewWillDisappear() {
    }

    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        delegate?.productGalleryCloseButton()
    }

    @IBAction func postButtonPressed(sender: AnyObject) {
        guard let imageSelected = selectedImage.image else { return }
        delegate?.productGalleryDidSelectImage(imageSelected)
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
    }

    private func fetchCollection() {
        //TODO: SELECT FOLDER USING OPTIONS
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)

        if let assetCollection = collection.firstObject as? PHAssetCollection {
            self.assetCollection = assetCollection
        }
    }

    private func fetchAssets() {
        if let assetCollection = assetCollection {
            photosAsset = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
        } else {
            photosAsset = nil
        }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4.0
        }
        collectionView.reloadData()

        imageAtIndex(0, size: nil) { [weak self] image in
            self?.selectedImage.image = image
        }
    }

    private func imageAtIndex(index: Int, size: CGSize?, handler: UIImage? -> Void) {
        guard let photosAsset = photosAsset, asset = photosAsset[index] as? PHAsset else {
            handler(nil)
            return
        }

        let targetSize = size ?? PHImageManagerMaximumSize
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit,
            options: nil, resultHandler: {
                (result, info) in
                guard let image = result else {
                    handler(nil)
                    return
                }
                handler(image)
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

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(contentView)
        let translation = recognizer.translationInView(contentView)

        switch recognizer.state {
        case .Began:
            if location.y < imageContainer.height+imageContainerTop.constant {
                dragState = .DraggingImage
            } else {
                dragState = .DraggingCollection(false)
            }
            initialDragPosition = imageContainerTop.constant
            currentScrollOffset = collectionView.contentOffset.y
            return
        case .Ended:
            dragState = .None
            finishAnimating()
            return
        default:
            break
        }

        switch dragState {
        case .DraggingImage:
            imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
        case .DraggingCollection(let fromTop):
            if location.y < imageContainer.height+imageContainerTop.constant {
                imageContainerTop.constant = max(min(0, -(imageContainer.height-20-location.y)), -imageContainerMaxHeight)
                collectionView.contentOffset.y = currentScrollOffset
            } else if collectionView.contentOffset.y <= 0 || fromTop {
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
            if abs(imageContainerTop.constant) < imageContainerMaxHeight-imageContainerStateThreshold {
                animateToState(collapsed: false)
            } else {
                animateToState(collapsed: true)
            }
        } else {
            if abs(imageContainerTop.constant) > imageContainerStateThreshold {
                animateToState(collapsed: true)
            } else {
                animateToState(collapsed: false)
            }
        }
    }

    private func animateToState(collapsed collapsed: Bool) {
        if collapsed {
            imageContainerTop.constant = -imageContainerMaxHeight
        } else {
            imageContainerTop.constant = 0
        }
        self.collapsed = collapsed

        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.contentView.layoutIfNeeded()
        })
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
            self?.selectedImage.image = image
            self?.animateToState(collapsed: false)
        }
    }
}
