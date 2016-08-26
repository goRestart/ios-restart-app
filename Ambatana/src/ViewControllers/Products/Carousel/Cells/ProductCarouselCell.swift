//
//  ProductCarouselCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ProductCarouselCellDelegate: class {
    func didTapOnCarouselCell(cell: UICollectionViewCell)
    func didChangeZoomLevel(level: CGFloat)
    func didScrollToPage(page: Int)
    func didPullFromCellWith(offset: CGFloat, bottomLimit: CGFloat)
    func canScrollToNextPage() -> Bool
    func didEndDraggingCell()
}

class ProductCarouselCell: UICollectionViewCell {

    static let identifier = "ProductCarouselCell"
    var collectionView: UICollectionView
    
    var product: Product?
    weak var delegate: ProductCarouselCellDelegate?
    var placeholderImage: UIImage?
    private var currentPage = 0
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.itemSize = frame.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        addSubview(collectionView)

        collectionView.frame = bounds
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.directionalLockEnabled = true
        collectionView.registerClass(ProductCarouselImageCell.self, forCellWithReuseIdentifier:
            ProductCarouselImageCell.identifier)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        collectionView.addGestureRecognizer(singleTap)
    }
    
    func didSingleTap(sender: UITapGestureRecognizer) {
        delegate?.didTapOnCarouselCell(self)
    }

    func visibleCell() -> ProductCarouselImageCell? {
        return collectionView.visibleCells().first as? ProductCarouselImageCell
    }
    
    func configureCellWithProduct(product: Product, placeholderImage: UIImage?, indexPath: NSIndexPath) {
        self.tag = indexPath.hash
        self.product = product

        self.placeholderImage = placeholderImage
        if let firstImageUrl = product.images.first?.fileURL where placeholderImage == nil {
            self.placeholderImage = ImageDownloader.sharedInstance.cachedImageForUrl(firstImageUrl)
        }
        collectionView.reloadData()
    }
    
    private func numberOfImages() -> Int {
        return product?.images.count ?? 0
    }
    
    private func imageAtIndex(index: Int) -> NSURL? {
        guard numberOfImages() > 0 else { return nil }
        guard let url = product?.images[index].fileURL else { return nil }
        return url
    }
}

extension ProductCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductCarouselImageCell.identifier, forIndexPath: indexPath)
            guard let imageCell = cell as? ProductCarouselImageCell else { return ProductCarouselImageCell() }
            guard let imageURL = imageAtIndex(indexPath.row) else { return imageCell }

            //Required to avoid missmatching when downloading images
            let imageCellTag = indexPath.hash
            let productCarouselTag = self.tag
            cell.tag = imageCellTag

            let usePlaceholder = indexPath.row == 0

            if let placeholder = placeholderImage where usePlaceholder {
                imageCell.setImage(placeholder)
            } else {
                imageCell.imageView.image = nil
            }
            ImageDownloader.sharedInstance.downloadImageWithURL(imageURL) { [weak self] (result, url) in
                if let value = result.value where self?.tag == productCarouselTag && cell.tag == imageCellTag {
                    imageCell.setImage(value.image)
                }
            }
            imageCell.backgroundColor = UIColor.placeholderBackgroundColor(product?.objectId)
            imageCell.zoomLevel.subscribeNext { [weak self] level in
                self?.delegate?.didChangeZoomLevel(level)
            }.addDisposableTo(disposeBag)

            return imageCell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageSize = collectionView.frame.size.height;
        let numImages = numberOfImages()
        guard numImages > 0 else { return }
        let page = Int(round(collectionView.contentOffset.y / pageSize)) % numImages
        if page != currentPage {
            currentPage = page
            delegate?.didScrollToPage(page)
        }

        if let delegate = delegate {
            delegate.didPullFromCellWith(scrollView.contentOffset.y, bottomLimit: bottomScrollLimit)

            if !delegate.canScrollToNextPage() {
                scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.didEndDraggingCell()
    }

    var bottomScrollLimit: CGFloat {
        return max(0, collectionView.contentSize.height - collectionView.height + collectionView.contentInset.bottom)
    }
}


extension ProductCarouselCell {
    private func setAccessibilityIds() {
        self.accessibilityId = .ProductCarouselCell
        collectionView.accessibilityId = .ProductCarouselCellCollectionView
        placeholderImage?.accessibilityId = .ProductCarouselCellPlaceholderImage
    }
}
