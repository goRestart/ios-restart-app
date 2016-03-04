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

    @IBOutlet weak var imageContainerHeight: NSLayoutConstraint!
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
        }
    }
}
