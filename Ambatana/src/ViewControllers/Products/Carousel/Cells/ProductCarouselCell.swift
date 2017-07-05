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

    fileprivate var productImages = [URL]()
    fileprivate var productBackgroundColor: UIColor?
    weak var delegate: ProductCarouselCellDelegate?
    var placeholderImage: UIImage?
    fileprivate var currentPage = 0
    fileprivate var imageScrollDirection: UICollectionViewScrollDirection = .vertical
    fileprivate var verticalScrollCounter: CGFloat = 0.0  // USed to prevent more info overscroll down with horizontal images navigator

    fileprivate var numberOfImages: Int {
        return productImages.count
    }

    var imageDownloader: ImageDownloaderType =  ImageDownloader.sharedInstance

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

    func configureCellWith(cellModel: ProductCarouselCellModel, placeholderImage: UIImage?, indexPath: IndexPath,
                           imageDownloader: ImageDownloaderType, imageScrollDirection: UICollectionViewScrollDirection) {
        self.tag = (indexPath as NSIndexPath).hash
        self.productImages = cellModel.images
        self.productBackgroundColor = cellModel.backgroundColor
        self.imageDownloader = imageDownloader
        self.placeholderImage = placeholderImage
        self.imageScrollDirection = imageScrollDirection

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = imageScrollDirection
        }

        if let firstImageUrl = productImages.first, placeholderImage == nil {
            self.placeholderImage = imageDownloader.cachedImageForUrl(firstImageUrl)
        }
        collectionView.setContentOffset(CGPoint.zero, animated: false) //Resetting images
        collectionView.reloadData()
    }

    func returnToFirstImage() {
        guard productImages.count > 1 else { return }
        let scrollPosition = imageScrollDirection == .horizontal ? UICollectionViewScrollPosition.left : UICollectionViewScrollPosition.top
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: scrollPosition, animated: false)
    }

    fileprivate func imageAtIndex(_ index: Int) -> URL? {
        guard 0..<productImages.count ~= index else { return nil }
        return productImages[index]
    }
}


// MARK: - UICollectionViewDataSource & UICollectionViewDelegate 

extension ProductCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
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
            imageCell.backgroundColor = productBackgroundColor
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
        let pageSize = imageScrollDirection == .horizontal ? collectionView.frame.size.width : collectionView.frame.size.height
        guard pageSize > 0, numberOfImages > 0 else { return }
        
        let collectionContentOffset: CGFloat

        if imageScrollDirection == .horizontal {
            verticalScrollCounter = verticalScrollCounter + scrollView.contentOffset.y
            collectionContentOffset = scrollView.contentOffset.x
            // in horizontal image scrolling, collection should not be able to move upwards.
            if verticalScrollCounter > 0 {
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0.0), animated: false)
            }
        } else {
            collectionContentOffset = scrollView.contentOffset.y
        }
        
        let page = Int(round(collectionContentOffset / pageSize)) % numberOfImages
        if page != currentPage {
            currentPage = page
            delegate?.isZooming(false)
            delegate?.didScrollToPage(page)
        }

        if let delegate = delegate {
            // informs the delegate how much to move the carousel elements "more info", chat textfield & buttons.
            delegate.didPullFromCellWith(scrollView.contentOffset.y, bottomLimit: bottomScrollLimit)

            if !delegate.canScrollToNextPage() {
                if imageScrollDirection == .horizontal {
                    // we want to stay in the current picture
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                } else {
                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        verticalScrollCounter = 0.0
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

fileprivate extension ProductCarouselCell {
    func setAccessibilityIds() {
        self.accessibilityId = .productCarouselCell
        collectionView.accessibilityId = .productCarouselCellCollectionView
        placeholderImage?.accessibilityId = .productCarouselCellPlaceholderImage
    }
}
