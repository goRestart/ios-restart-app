//
//  ProductCarouselCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ProductCarouselCellDelegate {
    func didTapOnCarouselCell(cell: UICollectionViewCell)
    func didChangeZoomLevel(level: CGFloat)
    func didScrollToPage(page: Int)
}

class ProductCarouselCell: UICollectionViewCell {

    static let identifier = "ProductCarouselCell"
    var collectionView: UICollectionView
    
    var product: Product?
    var delegate: ProductCarouselCellDelegate?
    var placeholderImage: UIImage?
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(collectionView)
        collectionView.frame = bounds
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
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.requireGestureRecognizerToFail(doubleTap)
        collectionView.addGestureRecognizer(singleTap)
    }
    
    func didSingleTap(sender: UITapGestureRecognizer) {
        delegate?.didTapOnCarouselCell(self)
    }
    
    func didDoubleTap(sender: UITapGestureRecognizer) {
        guard let cell = collectionView.visibleCells().first as? ProductCarouselImageCell else { return }
        cell.scrollView.setZoomScale(cell.scrollView.zoomScale == 1.0 ? 2.0 : 1.0, animated: true)
    }
    
    func visibleCell() -> ProductCarouselImageCell? {
        return collectionView.visibleCells().first as? ProductCarouselImageCell
    }
    
    func configureCellWithProduct(product: Product, placeholderImage: UIImage?) {
        self.product = product
        self.placeholderImage = placeholderImage
        collectionView.reloadData()
        let indexPath = NSIndexPath(forItem: startIndex(), inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
    }
    
    private func numberOfImages() -> Int {
        return product?.images.count ?? 0
    }
    
    private func imageAtIndex(index: Int) -> NSURL? {
        guard numberOfImages() > 0 else { return nil }
        let newIndex = index % numberOfImages()
        guard let url = product?.images[newIndex].fileURL else { return nil }
        return url
    }
    
    private func startIndex() -> Int {
        let midIndex = collectionView.numberOfItemsInSection(0)/2
        return midIndex - midIndex % numberOfImages()
    }
}

extension ProductCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages() == 1 ? 1 : 10000 // Hackish infinite scroll :3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductCarouselImageCell.identifier, forIndexPath: indexPath)
            guard let imageCell = cell as? ProductCarouselImageCell else { return ProductCarouselImageCell() }
            guard let imageURL = imageAtIndex(indexPath.row) else { return imageCell }

            let usePlaceholder = indexPath.row % numberOfImages() == 0

            if usePlaceholder { imageCell.setImage(placeholderImage) }
            ImageDownloader.sharedInstance.downloadImageWithURL(imageURL) { (result, url) in
                imageCell.setImage(result.value?.image)
            }
            
            imageCell.zoomLevel.subscribeNext { [weak self] level in
                self?.delegate?.didChangeZoomLevel(level)
            }.addDisposableTo(disposeBag)

            return imageCell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageSize = collectionView.frame.size.height;
        let page = Int(collectionView.contentOffset.y / pageSize) % numberOfImages()
        delegate?.didScrollToPage(page)
    }
}
