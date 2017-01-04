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
    func didTapOnCarouselCell(_ cell: UICollectionViewCell)
    func isZooming(_ zooming: Bool)
    func didScrollToPage(_ page: Int)
    func didPullFromCellWith(_ offset: CGFloat, bottomLimit: CGFloat)
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

    var imageDownloader: ImageDownloader =  ImageDownloader.sharedInstance

    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
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
        addSubview(collectionView)

        collectionView.keyboardDismissMode = .onDrag
        collectionView.frame = bounds
        collectionView.backgroundColor = UIColor.clear
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.isDirectionalLockEnabled = true
        collectionView.register(ProductCarouselImageCell.self, forCellWithReuseIdentifier:
            ProductCarouselImageCell.identifier)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        collectionView.addGestureRecognizer(singleTap)
    }
    
    func didSingleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didTapOnCarouselCell(self)
    }

    func configureCellWithProduct(_ product: Product, placeholderImage: UIImage?, indexPath: IndexPath,
                                  imageDownloader: ImageDownloader) {
        self.tag = (indexPath as NSIndexPath).hash
        self.product = product
        self.imageDownloader = imageDownloader
        self.placeholderImage = placeholderImage
        if let firstImageUrl = product.images.first?.fileURL, placeholderImage == nil {
            self.placeholderImage = ImageDownloader.sharedInstance.cachedImageForUrl(firstImageUrl)
        }
        collectionView.setContentOffset(CGPoint.zero, animated: false) //Resetting images
        collectionView.reloadData()
    }
    
    private func numberOfImages() -> Int {
        return product?.images.count ?? 0
    }
    
    private func imageAtIndex(_ index: Int) -> URL? {
        guard numberOfImages() > 0 else { return nil }
        guard let url = product?.images[index].fileURL else { return nil }
        return url
    }
}


// MARK: - UICollectionViewDataSource & UICollectionViewDelegate 

extension ProductCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCarouselImageCell.identifier, for: indexPath)
            guard let imageCell = cell as? ProductCarouselImageCell else { return ProductCarouselImageCell() }
            guard let imageURL = imageAtIndex(indexPath.row) else { return imageCell }

            //Required to avoid missmatching when downloading images
            let imageCellTag = (indexPath as NSIndexPath).hash
            let productCarouselTag = self.tag
            imageCell.tag = imageCellTag
            imageCell.position = indexPath.row
            imageCell.backgroundColor = UIColor.placeholderBackgroundColor(product?.objectId)
            imageCell.delegate = self

            if imageCell.imageURL != imageURL { //Avoid reloading same image in the cell
                if let placeholder = placeholderImage, indexPath.row == 0 {
                    imageCell.setImage(placeholder)
                } else {
                    imageCell.imageView.image = nil
                }

                imageDownloader.downloadImageWithURL(imageURL) { [weak self, weak imageCell] (result, url) in
                    if let value = result.value, self?.tag == productCarouselTag && cell.tag == imageCellTag {
                        imageCell?.imageURL = imageURL
                        imageCell?.setImage(value.image)
                    }
                }
            }
            
            return imageCell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ProductCarouselImageCell else { return }
        imageCell.resetZoom()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageSize = collectionView.frame.size.height;
        let numImages = numberOfImages()
        guard numImages > 0 else { return }
        let page = Int(round(collectionView.contentOffset.y / pageSize)) % numImages
        if page != currentPage {
            currentPage = page
            delegate?.isZooming(false)
            delegate?.didScrollToPage(page)
        }

        if let delegate = delegate {
            delegate.didPullFromCellWith(scrollView.contentOffset.y, bottomLimit: bottomScrollLimit)

            if !delegate.canScrollToNextPage() {
                scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.didEndDraggingCell()
    }

    var bottomScrollLimit: CGFloat {
        return max(0, collectionView.contentSize.height - collectionView.height + collectionView.contentInset.bottom)
    }
}


// MARK: - ProductCarouselImageCellDelegate

extension ProductCarouselCell: ProductCarouselImageCellDelegate {
    func isZooming(_ zooming: Bool, pageAtIndex index: Int) {
        guard index == currentPage else { return }
        delegate?.isZooming(zooming)
    }
}


// MARK: - Private methods
// MARK: > Accessibility

private extension ProductCarouselCell {
    func setAccessibilityIds() {
        self.accessibilityId = .ProductCarouselCell
        collectionView.accessibilityId = .ProductCarouselCellCollectionView
        placeholderImage?.accessibilityId = .ProductCarouselCellPlaceholderImage
    }
}
