//
//  ProductCarouselCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductCarouselImageCell: UICollectionViewCell {
    var imageView: UIImageView
    
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        addSubview(imageView)
        self.imageView.frame = frame
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
        collectionView.alwaysBounceHorizontal = true
    }
    
    
    func configureCellWithProduct(product: Product) {
        self.product = product
        collectionView.reloadData()
    }
    
    func numberOfImages() -> Int {
        return product?.images.count ?? 1
    }
    
    func imageAtIndex(index: Int) -> NSURL? {
        let newIndex = index % numberOfImages()
        guard let 0..<numberOfImages()
    }
}

extension ProductCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int.max // Hackish infinite scroll :3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath)
        guard let imageCell = cell as? ProductCarouselImageCell else { return UICollectionViewCell() }
        guard let imageURL = product?.images[indexPath.row % numberOfImages()].fileURL else { return UICollectionViewCell() }
        imageCell.imageView.sd_setImageWithURL(imageURL)
        return imageCell
    }
}
