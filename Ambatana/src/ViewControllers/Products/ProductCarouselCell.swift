//
//  ProductCarouselCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SDWebImage

class ProductCarouselImageCell: UICollectionViewCell {
    var imageView: UIImageView
    
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        super.init(frame: frame)
        setupUI()
        backgroundColor = StyleHelper.productCellImageBgColor
    }
    
    func setupUI() {
        addSubview(imageView)
        self.imageView.frame = bounds
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.blueColor()
        self.imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProductCarouselCell: UICollectionViewCell {

    var collectionView: UICollectionView
    var product: Product?
    
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
        collectionView.registerClass(ProductCarouselImageCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.purpleColor()
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
    }
    
    func configureCellWithProduct(product: Product) {
        self.product = product
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath)
            guard let imageCell = cell as? ProductCarouselImageCell else { return ProductCarouselImageCell() }
            guard let imageURL = imageAtIndex(indexPath.row) else { return imageCell }
            imageCell.imageView.sd_setImageWithURL(imageURL)
            return imageCell
    }
}
